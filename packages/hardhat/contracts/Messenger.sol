//__/\\\\\\\\\\\\\\\_________________________________________________________________________________/\\\\\\\\\______/\\\\\\\\\\\\____
// _\/\\\///////////________________________________________________________________________________/\\\///////\\\___\/\\\////////\\\__
//___\/\\\_____________________________/\\\\\\\\___/\\\_____________________________________________\/\\\_____\/\\\___\/\\\______\//\\\_
//____\/\\\\\\\\\\\______/\\/\\\\\\____/\\\////\\\_\///___/\\/\\\\\\_______/\\\\\\\\______/\\\\\\\\__\/\\\\\\\\\\\/____\/\\\_______\/\\\_
//_____\/\\\///////______\/\\\////\\\__\//\\\\\\\\\__/\\\_\/\\\////\\\____/\\\/////\\\___/\\\/////\\\_\/\\\//////\\\____\/\\\_______\/\\\_
//______\/\\\_____________\/\\\__\//\\\__\///////\\\_\/\\\_\/\\\__\//\\\__/\\\\\\\\\\\___/\\\\\\\\\\\__\/\\\____\//\\\___\/\\\_______\/\\\_
//_______\/\\\_____________\/\\\___\/\\\__/\\_____\\\_\/\\\_\/\\\___\/\\\_\//\\///////___\//\\///////___\/\\\_____\//\\\__\/\\\_______/\\\__
//________\/\\\\\\\\\\\\\\\_\/\\\___\/\\\_\//\\\\\\\\__\/\\\_\/\\\___\/\\\__\//\\\\\\\\\\__\//\\\\\\\\\\_\/\\\______\//\\\_\/\\\\\\\\\\\\/___
//_________\///////////////__\///____\///___\////////___\///__\///____\///____\//////////____\//////////__\///________\///__\////////////_____
//______________________________________________________________________________________________________________________parker@engineerd.io____
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";
import "hardhat/console.sol";
//ropsten smiling.eth
//address 0xdf74136E00724Bf2BfAd6583d79F2a2A371Ca0B0
//node 0xf2a487af97f360672bc1fd07ea792e607c1b727a35796a88fd4ac96359432c80
//resolver 0x084b1c3C81545d370f3634392De611CaaBFf8148
abstract contract messengerImage {
    function buildImage(uint _tokenId, string memory message, address sender) external virtual view returns(string memory);
}

contract Messenger is ERC721, ERC721Burnable, Ownable {

    event SentMessage(address indexed sender, address indexed to, string value, bool nft);

    using Strings for uint;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    bool public paused = false;
    mapping(address => Message) public addressToMessage;
    uint public stringLimit = 175; //like a tweet
    uint public fee;
    address public genesisMetaAddress;
    address public metaAddress;
    //enum messageStatus {active, read, deleted, archived }
    uint public genesisLimit;

    struct Message {
        bool optOut;
        //messageStatus status;
        address sender;
        string value;
        uint tokenId;
    }//data struct is user centric rather than tokenId centric because each user can only have one message and it just gets updated.

    constructor() ERC721("onChainMsg", "OCM") {}

    function mintEvent(address _to, string memory _userText) public payable {
        require(addressToMessage[_to].optOut == false, "User has opted out of receiving messasges");
        emit SentMessage(msg.sender, _to, _userText, false);
    }

    // public
    function mint(address _to, string memory _userText) public payable {
        bytes memory strBytes = bytes(_userText);
        require(strBytes.length <= stringLimit, "String input exceeds message limit");
        require(addressToMessage[_to].optOut == false, "User has opted out of receiving messasges");


        if (userHasNFT(_to) && !isGenesis(msg.sender) && msg.sender != owner()) {
            require(msg.value >= fee, "eth value is below expected fee");
        }

        //update the receipients record
        addressToMessage[_to].sender = msg.sender; 
        addressToMessage[_to].value = _userText; 

        //if the receiver doesn't have an NFT record yet, mint one
        if(!userHasNFT(_to)){
            _tokenIdCounter.increment();
            uint256 _tokenId = _tokenIdCounter.current();
            addressToMessage[_to].tokenId = _tokenId; 
            _safeMint(_to, _tokenId);
        }      
        
        emit SentMessage(msg.sender, _to, _userText, true);
    }

    function _beforeTokenTransfer(address from, address _to, uint256 tokenId)
        internal virtual override
    {
        super._beforeTokenTransfer(from, _to, tokenId);
        //if you transfer a message, transfer message to new user and update the from, delete senders message record
        //console.log("tokenId exists", _exists(tokenId));
        //console.log("current", _tokenIdCounter.current());
        bool minting = (from == address(0)); //!_exists(tokenId); //if token doesn't already exist, its being minted

        
        
        //Case: User is transferring an existing NFT (didn't call mint) 
        if(!minting){
            //Case: User is transferring NFT to user who already has one and we will prevent them in case it overwites a genesis theme
            require(!userHasNFT(_to), "Wallet already has a Message and can only have one, please burn or transfer the old message first");
            //console.log("We are transferring a token that isn't being minted");
            //console.log(ownerOf(tokenId));
            //console.log(msg.sender);
            //bool optOut = addressToMessage[to].optOut;
            //addressToMessage[to] = addressToMessage[from];
            //addressToMessage[to].optOut = optOut; 
            addressToMessage[_to].tokenId = addressToMessage[from].tokenId;

            bool optOut = addressToMessage[from].optOut;
            delete addressToMessage[from]; // could delete old data, or leave it to me updated upon next mint. Leaving it will make transferring more expensive and mionting cheaper next time.
            addressToMessage[from].optOut = optOut; 
        }else {
            //console.log("We are minting");
        } 
    }
    
    function increaseThemeLimit(uint _delta) external onlyOwner {
        genesisLimit += _delta;
    }

    function updateStringLimit(uint _newLimit) external onlyOwner {
        stringLimit = _newLimit;
    }

    function tokenSupply() public view returns(uint){
        return _tokenIdCounter.current();
    }

    function updateFee(uint _fee) external onlyOwner {
        fee = _fee;
    }

    function userHasNFT(address _to) public view returns(bool) {
        return addressToMessage[_to].tokenId != 0;
    }

    function changeOptOut() public {
        addressToMessage[msg.sender].optOut = !addressToMessage[msg.sender].optOut;
        //burn(_tokenId);
    }
    
    function setGenesisMetaAddress(address _metaAddress) external onlyOwner {
        genesisMetaAddress =  _metaAddress;
    }
    
    function setMetaAddress(address _metaAddress) external onlyOwner {
        metaAddress =  _metaAddress;
    }

    function isGenesis(address _address) public view returns (bool) {
        return (addressToMessage[_address].tokenId !=0 && addressToMessage[_address].tokenId <= genesisLimit);
    }
    
    function buildImage(uint256 _tokenId) private view returns (string memory) {
        Message memory currentMessage = addressToMessage[ownerOf(_tokenId)];
        //string memory owner = toAsciiString(currentMessage.sender);
        messengerImage mymessengerImage = messengerImage(metaAddress);
        if(metaAddress == address(0) || isGenesis(msg.sender)){
            mymessengerImage = messengerImage(genesisMetaAddress);
        }
        return mymessengerImage.buildImage(_tokenId, currentMessage.value, currentMessage.sender);
    }

    function buildMetadata(uint256 _tokenid)
        private
        view
        returns (string memory)
    {
        //Message memory currentMessage = wordsToTokenId[_tokenid];
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"Message #"',
                                _tokenid.toString(),
                                '", "description":"On Chain Messenger is a simple app that enables users to send wallet to wallet messages in visual NFT format, entirely on chain.",',
                                '"image": "',
                                "data:image/svg+xml;base64,",
                                buildImage(_tokenid),
                                '"'
                                "}"
                            )
                        )
                    )
                )
            );
    }

    function tokenURI(uint256 _tokenid)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenid),
            "erc721metadata: uri query for nonexistent token"
        );
        return buildMetadata(_tokenid);
    }

    //only owner
    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }

    function selfDestruct(address adr) public onlyOwner {
        selfdestruct(payable(adr));
    }
}