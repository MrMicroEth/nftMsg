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
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";
import "hardhat/console.sol";

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

    function buildImage(uint _tokenId, string memory value, address _owner) external view returns(string memory){

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
                        '<svg xmlns="http://www.w3.org/2000/svg" preserveaspectratio="xminymin meet" viewbox="0 0 350 350">',
                        '<style>.base { fill: white; font-family: serif; font-size: 14px; text-wrap:200px; }</style>',
                        '<rect width="100%" height="100%" fill="black" />',
                        '<text x="50%" y="10" dominant-baseline="middle" text-anchor="middle" class="base">',
                        'On Chain Messenger',
                        '</text> ',
                        '<text x="10" y="40" class="base">',
                        owner,
                        ': ', 
                        value,
                        '</text>',
                        '</svg>'
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