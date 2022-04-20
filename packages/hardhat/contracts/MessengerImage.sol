// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";
//import "hardhat/console.sol";

abstract contract ensResolver {
    mapping(bytes32 => string) public name;
}

abstract contract nodeContract {
    function node(address addr) public virtual pure returns (bytes32);
}

/**
* @title jpegMeImage
* @author royce.eth
* @notice On Chain NFT Messenging App SVG image generation contract
 */
contract MessengerImage is Ownable {

    //max image line length before line split
    uint constant maxLength = 35;
    address public ensAddress =0xA2C122BE93b0074270ebeE7f6b7292C7deB45047;
    address public nodeAddress = 0x084b1c3C81545d370f3634392De611CaaBFf8148;

    //SVG strings contain the constant components of the generatice message graphics code
    string constant svg1 = '<svg xmlns="http://www.w3.org/2000/svg" width="350" height="350">  <style>  .text { font-family: "Source Code Pro",monospace; font-size: 14px; text-wrap:200px; } .sender {font-size: 20px; font-weight:bold} .msgText{fill: white; } .reply {stroke-width:1;stroke:rgb(0,168,255); fill:white} .fill {fill:url(#grad1)} </style>  <rect width="100%" height="100%" fill="white" />    <defs>     <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="0%">       <stop offset="0%" style="stop-color:rgb(58, 208, 91 )" />       <stop offset="100%" style="stop-color:rgb(0,168,255)" />     </linearGradient>   </defs>  <rect class="fill" width="320" height="200" x="15" y="15" rx="10" ry="10" />';
    string constant svg2 = '<polygon points="320,215 300,215 297,230" style="fill:rgb(0,168,255)" /> <text class="text sender fill" x="320" y="250"  text-anchor="end" >';
    string constant svg3 = '</text> <a href="https://www.jpegMessage.me" target="_blank"> <rect class="reply" width="320" height="30" x="15" y="300" rx="5" ry="5" /> <text class="text" fill="rgb(0,168,255)" x="30" y="320" font-weight="bold" font-style="italic" >Reply online @ jpegMe.xyz</text> <text class="text sender" fill="rgb(0,168,255)" x="325" y="321" text-anchor="end" >></text></a></svg>';
    string constant text1 = '<text x="27" y="40" class="msgText text">';
    string constant text2 = '<text x="27" y="60" class="msgText text">';
    string constant text3 = '<text x="27" y="80" class="msgText text">';
    string constant text4 = '<text x="27" y="100" class="msgText text">';
    string constant text5 = '<text x="27" y="120" class="msgText text">';
    string constant textPost = '</text>';

    function  setENSContract(address _ens) public onlyOwner{
        ensAddress = _ens;
    }

    function getENSname(address _user) public view returns (string memory name){
        nodeContract noder = nodeContract(nodeAddress);
        bytes32 userNode = noder.node(_user);
        ensResolver resolver = ensResolver(ensAddress);
        name = resolver.name(userNode);
    }

    /**
    * @notice Takes a message and returns a message limited to a certain length, and the remaining message
    * @dev You need to run this function multiple times if your string remaining is still greater than the max desired length
    * @param message The message you want to break up into a fixed length line
    * @return string The shortened line without broken words
    * @return string The remaining message minus the cut line
     */
    function parseMessage(string memory message) internal pure returns (string memory, string memory){//break up the message into lines for the svg
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
                //console.log("reached one");
                line = substring(message, 0, maxLength);//copy line
                message = substring(message, maxLength, bytes(message).length);//remove line from message

            }
        }
        return(message,line);
    }

    /**
    * @notice Creates SVG message image to be show as a wallet NFT 
    * @param _tokenId The tokenID of the NFT, not used
    * @param _message The message to display
    * @param _sender The sender of the message
    * @return string The SVG image text encoded
     */
    function buildImage(uint _tokenId, string memory _message, address _sender) external view returns(string memory){
        
        //create message lines
        string memory line1;
        string memory line2;
        string memory line3;
        string memory line4;
        string memory line5;

        //break message up into lines
        (_message, line1) = parseMessage(_message);
        (_message, line2) = parseMessage(_message);
        (_message, line3) = parseMessage(_message);
        (_message, line4) = parseMessage(_message);
        (_message, line5) = parseMessage(_message);

        //combine lines with SVG tags into one string
        _message = string(abi.encodePacked(text1, line1, textPost));
        _message = string(abi.encodePacked(_message, text2, line2, textPost));
        _message = string(abi.encodePacked(_message, text3, line3, textPost));
        _message = string(abi.encodePacked(_message, text4, line4, textPost));
        _message = string(abi.encodePacked(_message, text5, line5, textPost));

        string memory owner = toAsciiString(_sender);

        // build address abbreviation as user name, ex 0xf39...2266
        owner = string(abi.encodePacked(
            '0x',
            substring(owner,0,3),
            '...',
            endOfString(owner,4)
            )
        );

        //Try and fetch ENS name
        string memory name = getENSname(_sender);
        bytes memory tempEmptyStringTest = bytes(name); // Uses memory

        //overwrite abbreviation with ENS name when available
        if (tempEmptyStringTest.length != 0) {
            owner = name;
        }
        //console.log("owner", owner);
        //Finish compiling image
        string memory image = 
            Base64.encode(
                bytes(
                    abi.encodePacked(
                        svg1,
                        _message,
                        svg2,
                        owner,
                        svg3
                    )
                )
            );
        //console.log("image data");
        //console.log( "data:image/svg+xml;base64,%s",image);        
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

    //boom
    function selfDestruct(address adr) public onlyOwner {
        selfdestruct(payable(adr));
    }
}