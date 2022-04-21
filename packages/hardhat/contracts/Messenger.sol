// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";
//import "hardhat/console.sol";

abstract contract messengerImage {
    function buildImage(uint _tokenId, string memory message, address sender) external virtual view returns(string memory);
}

/**
* @title jpegMe
* @author royce.eth
* @notice On Chain NFT Messenging App
 */
contract Messenger is ERC721, ERC721Burnable, Ownable {
    
    /**
    * @notice Emmits an event when either mint function is called. Can be emitted without an actual NFT being minted.
    * @param sender Sender of the Message
    * @param to Receipient of the Message
    * @param value The text body content of the message
    * @param nft true if mint was called and a NFT was created/updated, false if mintEvent was called and no on-chain data altered
     */
    event SentMessage(address indexed sender, address indexed to, string value, bool nft);

    using Strings for uint;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    mapping(address => Message) public addressToMessage;
    uint public stringLimit = 175; //like a tweet
    uint public fee;
    address public metaAddress;

    //Message struct is user centric rather than tokenId centric because each user can only have one message and it just gets updated.
    struct Message {
        bool optOut;
        address sender;
        string value;
        uint tokenId;
    }

    constructor() ERC721("jpegMe", "JEM") {}

    /**
    * @notice Create a mint event without actually minting an NFT
     */
    function mintEvent(address _to, string memory _userText) public payable {
        require(addressToMessage[_to].optOut == false, "User has opted out of receiving messasges");
        emit SentMessage(msg.sender, _to, _userText, false);
    }

    /**
    * @notice Mint a new NFT message or update an existing one, and emit the NFT event.
     */
    function mint(address _to, string memory _userText) public payable {
        bytes memory strBytes = bytes(_userText);
        require(strBytes.length <= stringLimit, "String input exceeds message limit");
        require(addressToMessage[_to].optOut == false, "User has opted out of receiving messasges");


        if (userHasNFT(_to) && msg.sender != owner()) {
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

    function _beforeTokenTransfer(address _from, address _to, uint256 tokenId)
        internal virtual override
    {
        super._beforeTokenTransfer(_from, _to, tokenId);
        //if you transfer a message, transfer message to new user and update the from, delete senders message record
        bool minting = (_from == address(0)); //!_exists(tokenId); //if token doesn't already exist, its being minted
        
        //Case: User is transferring an existing NFT (didn't call mint) 
        if(!minting){
            //Case: User is transferring NFT to user who already has one and we will prevent them in case it overwites a genesis theme
            require(!userHasNFT(_to), "Wallet already has a Message and can only have one, please burn or transfer the old message first");
            //console.log("We are transferring a token that isn't being minted");
            //update tokenID in addressToMessage for new message owner
            addressToMessage[_to].tokenId = addressToMessage[_from].tokenId;

            //remove old record but maintaing optout status
            bool optOut = addressToMessage[_from].optOut;
            delete addressToMessage[_from]; // could delete old data, or leave it to me updated upon next mint. Leaving it will make transferring more expensive and mionting cheaper next time.
            addressToMessage[_from].optOut = optOut; 
        } 
    }
    
    function buildImage(uint256 _tokenId) private view returns (string memory) {
        Message memory currentMessage = addressToMessage[ownerOf(_tokenId)];
        //string memory owner = toAsciiString(currentMessage.sender);
        messengerImage mymessengerImage = messengerImage(metaAddress);
        return mymessengerImage.buildImage(_tokenId, currentMessage.value, currentMessage.sender);
    }

    function buildMetadata(uint256 _tokenid)
        private
        view
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"Message #',
                                _tokenid.toString(),
                                '", "description":"JpegMe is a simple app that enables users to send wallet to wallet messages in visual NFT format, entirely on chain.",',
                                '"image": "',
                                'data:image/svg+xml;base64,',
                                buildImage(_tokenid),
                                '"',
                                '}'
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
    }
    
    function setMetaAddress(address _metaAddress) external onlyOwner {
        metaAddress =  _metaAddress;
    }

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