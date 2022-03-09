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
pragma experimental ABIEncoderV2;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";
import "hardhat/console.sol";
//import "github.com/Arachnid/solidity-stringutils/strings.sol";


//mainnet main ens registry 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e
//leia.eth node 0x6dcd869a3418d0034862d4d53292e407680fa9d6a896ba17d3f684e1edf5461b
//mainnet default reverse router 0xA2C122BE93b0074270ebeE7f6b7292C7deB45047
// reverse registrar node getter

abstract contract ensResolver {
    mapping(bytes32 => string) public name;
}

abstract contract nodeContract {
    function node(address addr) public virtual pure returns (bytes32);
}

contract MessengerImage is Ownable {

    uint constant maxLength = 35;
    address public ensAddress =0xA2C122BE93b0074270ebeE7f6b7292C7deB45047;
    address public nodeAddress = 0x084b1c3C81545d370f3634392De611CaaBFf8148;

    function  setENSContract(address ens) public{
        ensAddress = ens;
    }

    function getENSname(address user) public view returns (string memory name){
        nodeContract noder = nodeContract(nodeAddress);
        bytes32 userNode = noder.node(user);
        ensResolver resolver = ensResolver(ensAddress);
        name = resolver.name(userNode);
    }
        

        function parseMessage(string memory message) internal view returns (string memory, string memory){//break up the message into lines for the svg
            bytes memory msgBytes = bytes(message);
            string memory line;
            
            if(msgBytes.length == 0){ //no text to parse
                return ("","");
            }

            if(msgBytes.length<maxLength){ // last line of message so return is as the last line
                return("", message);
            }

            for(uint i = maxLength; i>0; i--) { //multiple lines remaining
                if(msgBytes[i] == " "){
                    line = substring(message, 0, i);//copy line
                    message = substring(message, i+1, bytes(message).length);//remove line from message
                    break;
                }
                if(i==1){
                    console.log("reached one");
                    line = substring(message, 0, maxLength);//copy line
                    message = substring(message, maxLength, bytes(message).length);//remove line from message

                }
            }
            return(message,line);
        }

        string constant svg1 = '<svg xmlns="http://www.w3.org/2000/svg" width="350" height="350"> <style> .text { font-family: "Source Code Pro",monospace; font-size: 14px; text-wrap:200px; } .sender {font-size: 20px; font-weight:bold} .msgText{fill: white; } .reply {stroke-width:1;stroke:url(#grad1);fill:white} .fill {fill:url(#grad1)} </style> <rect width="100%" height="100%" fill="white" /> <defs> <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="0%"> <stop offset="0%" style="stop-color:#0066cc;stop-opacity:0.9" /> <stop offset="100%" style="stop-color:blue;stop-opacity:0.6" /> </linearGradient> </defs> <rect class="fill" width="320" height="200" x="15" y="15" rx="10" ry="10" /> ';
        string constant svg2 = '<polygon points="320,215 300,215 297,230" style="fill:blue;fill-opacity:0.6" /> <text class="text sender fill" x="320" y="250"  text-anchor="end" >';
        string constant svg3 = '</text> <a href="https://www.jpegMessage.me" target="_blank"> <rect class="reply" width="320" height="30" x="15" y="300" rx="5" ry="5" /> <text class="text fill" x="30" y="320" font-style="italic" >Reply @ jpegMessage.Me</text> <text class="fill text sender" x="325" y="321" text-anchor="end" >></text> </a> </svg>';
        string constant text1 = '<text x="27" y="40" class="msgText text">';
        string constant text2 = '<text x="27" y="60" class="msgText text">';
        string constant text3 = '<text x="27" y="80" class="msgText text">';
        string constant text4 = '<text x="27" y="100" class="msgText text">';
        string constant text5 = '<text x="27" y="120" class="msgText text">';
        string constant textPost = '</text>';

    function buildImage(uint _tokenId, string memory message, address _owner) external view returns(string memory){
        //message = "Hello I would like to buy your ENS name Ford.ens please. Just respond on OpenSean or a tweet @ford thankyou for your consideration!";
        string memory line1;
        string memory line2;
        string memory line3;
        string memory line4;
        string memory line5;

        //console.log("OG message :", message);
        (message, line1) = parseMessage(message);
        (message, line2) = parseMessage(message);
        (message, line3) = parseMessage(message);
        (message, line4) = parseMessage(message);
        (message, line5) = parseMessage(message);

        message = string(abi.encodePacked(text1, line1, textPost));
        message = string(abi.encodePacked(message, text2, line2, textPost));
        message = string(abi.encodePacked(message, text3, line3, textPost));
        message = string(abi.encodePacked(message, text4, line4, textPost));
        message = string(abi.encodePacked(message, text5, line5, textPost));
        /*console.log("line 1:", line1);
        console.log("line 2:", line2);
        console.log("line 3:", line3);
        console.log("line 4:", line4);
        console.log("line 5:", line5);
        console.log("message :", message);
        */

        string memory owner = toAsciiString(_owner);
        // build address abbreviation as user name, ex 0xf39...2266
        owner = string(abi.encodePacked(
            '0x',
            substring(owner,0,3),
            '...',
            endOfString(owner,4)
            )
        );

        string memory name = getENSname(_owner);
        bytes memory tempEmptyStringTest = bytes(name); // Uses memory
        if (tempEmptyStringTest.length != 0) {
            owner = name;
        }

        //console.log(localNode);
        console.log("owner", owner);

        string memory image = 
            Base64.encode(
                bytes(
                    abi.encodePacked(
                        svg1,
                        message,
                        svg2,
                        owner,
                        svg3
                    )
                )
            );
        console.log( "data:image/svg+xml;base64,%s",image);        
        return image;
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

    function selfDestruct(address adr) public onlyOwner {
        selfdestruct(payable(adr));
    }
}