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

contract MessengerImage is Ownable {
    address public ensAddress =0x084b1c3C81545d370f3634392De611CaaBFf8148 ;
    mapping(bytes32 => string) public ensName;
    address local = 0xA7d7A55E943B877c39AB59566fb1296b10aA4d29;
    bytes32 localNode = node(local);

    constructor(){
        ensName[localNode] = "deupty.eth";
    }

    function  setENS(address ens) public{
        ensAddress = ens;
    }
    
    function getENSname(address user) public view returns (string memory){
        bytes32 node = node(user);
        ensResolver resolver = ensResolver(ensAddress);
        return resolver.name(node);
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
        //need to get node value from address.
        //bytes32 ensnode =  0xf2a487af97f360672bc1fd07ea792e607c1b727a35796a88fd4ac96359432c80;
        bytes32 ensnode = node(0xA7d7A55E943B877c39AB59566fb1296b10aA4d29);

        //ensResolver resolver = ensResolver(ensAddress);
        //string memory name = resolver.name(ensnode);
        owner = ensName[localNode];
        //bytes memory tempEmptyStringTest = bytes(name); // Uses memory
        //if (tempEmptyStringTest.length == 0) {
            ///owner = name;
        //}
       /* 
        ensResolver resolver = ensResolver(address(0xA2C122BE93b0074270ebeE7f6b7292C7deB45047));
        owner = resolver.name(0x6dcd869a3418d0034862d4d53292e407680fa9d6a896ba17d3f684e1edf5461b);
*/
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
    
    function node(address addr) public pure returns (bytes32) {
        bytes32 ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;
        return keccak256(abi.encodePacked(ADDR_REVERSE_NODE, sha3HexAddress(addr)));
    }

    function sha3HexAddress(address addr) private pure returns (bytes32 ret) {
        addr;
        ret; // Stop warning us about unused variables
        assembly {
            let lookup := 0x3031323334353637383961626364656600000000000000000000000000000000

            for { let i := 40 } gt(i, 0) { } {
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
            }

            ret := keccak256(0, 40)
        }
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