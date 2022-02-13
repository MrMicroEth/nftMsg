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

contract YourContract is ERC721, ERC721Burnable, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    bool public paused = false;
    mapping(address => Message) public addressToMessage;
    uint256 public stringLimit = 280; //like a tweet
    uint256 fee = 0;
    //enum messageStatus {active, read, deleted, archived }

    struct Message {
        string value;
        bool optOut;
        //messageStatus status;
        address sender;
    }

    constructor() ERC721("onChainMsg", "OCM") {}

    // public
    function mint(address _to, string memory _userText) public payable {
        bytes memory strBytes = bytes(_userText);
        require(strBytes.length <= stringLimit, "String input exceeds limit.");
        require(addressToMessage[_to].optOut == false, "User has opted out of receiving messasges");

        Message memory newMessage = Message(
            _userText,
            //messageStatus.active,
            false,
            msg.sender
        );

        if (msg.sender != owner()) {
            require(msg.value >= fee);
        }

        addressToMessage[_to] = newMessage; //Add word to mapping @tokenId

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal virtual override
    {
        super._beforeTokenTransfer(from, to, tokenId);
        //if you transfer a message, transfer message to new user and update the from, delete senders message record
        if(tokenId != tokenIdCounter.current()){
            Message oldMessage = addressToMessage[from];
            addressToMessage[to] = oldMessage;
            addressToMessage[to].sender = from;
            //delete addressToMessage[from];
        }

    }

    function updateFee(uint _fee) external onlyOwner {
        fee =  _fee;
    }

    function setOptOut(bool _value) public {
        addressToMessage[msg.sender].optOut = _value;
        //burn(_tokenId);
    }

    function buildImage(uint256 _tokenId) private view returns (string memory) {
        Message memory currentMessage = addressToMessage[ownerOf(_tokenId)];
        string memory owner = toAsciiString(currentMessage.sender);
        // build address abbreviation as user name, ex 0xf39...2266
        owner = string(abi.encodePacked(
            '0x',
            substring(owner,0,3),
            '...',
            endOfString(owner,4)
            )
        );
        console.log(owner);

        string memory image = 
            Base64.encode(
                bytes(
                    abi.encodePacked(
                        '<svg xmlns="http://www.w3.org/2000/svg" preserveaspectratio="xminymin meet" viewbox="0 0 350 350">',
                        '<style>.base { fill: white; font-family: serif; font-size: 14px; text-wrap:200px; }</style>',
                        '<rect width="100%" height="100%" fill="black" />',
                        '<text x="50%" y="10" dominant-baseline="middle" text-anchor="middle" class="base">',
                        'On Chain Messenger',
                        '</text> ',
                        '<text x="10" y="40" class="base">',
                        owner,
                        ': ', 
                        currentMessage.value,
                        '</text>',
                        '</svg>'
                    )
                )
            );
        console.log( "data:image/svg+xml;base64,%s",image);        
        return image;
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

    //string helper function for getting end of wallet abbreviation
    function endOfString(string memory str, uint startIndex ) internal pure returns (string memory) {
        return substring(str, bytes(str).length - startIndex, bytes(str).length);  
    }

    //string helper function for getting wallet abbreviation
    function substring(string memory str, uint startIndex, uint endIndex) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for(uint i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string(result);
    }

    //convert address to string
    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function selfDestruct(address adr) public ownlyOwner {
        selfdestruct(payable(adr));
    }
}