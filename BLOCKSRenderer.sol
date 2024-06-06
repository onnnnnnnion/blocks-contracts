// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./library/ColorLib.sol";
import "./library/Base64.sol";

contract BlocksRenderer is Ownable{

    string public _contractURI;
    IERC721 public token;

    mapping(uint => bool) zorbMode;
    
    constructor(IERC721 _token) {
        token = _token;
    }
    
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        address owner = token.ownerOf(tokenId);

        bytes[5] memory colors = ColorLib.gradientForAddress(owner);
        string memory output;
        string memory attributes = "";

        bytes memory background = colors[tokenId % 5];
        string memory mode = "";

        if(zorbMode[tokenId]){
            background = "black";
            mode = zorbForAddress(owner);
        }

        output = string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: Helvetica; font-size: 30px; }</style><rect width="100%" height="100%" fill="',
            background,
            '"/><text x="33%" y="50%" class="base">',
            Strings.toString(tokenId),
            '</text>',
            mode,
            '</svg>'
        ));

        if (tokenId <= 3226325) {  // 24 hours from first mint
            attributes = ', "attributes": [{"trait_type": "Day", "value": "1"}]';
        }

        string memory json = Base64.encode(bytes(string(abi.encodePacked(
            '{"name": "Block #',
            Strings.toString(tokenId),
            '", "description": "Blocks are an experiment in collecting NFT-native Blocks on the Zora network. Each block can be claimed by the first person to mint during a given block, which claims the token for that block. Inspired by first.lol", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(output)),
            '"',
            attributes,
            '}'
        ))));

        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    function switchMode(uint tokenId) external {
        require (token.ownerOf(tokenId) == msg.sender, "Not owner of token");
        zorbMode[tokenId] = !zorbMode[tokenId];
    }

    function contractURI() external view returns (string memory) {
        return _contractURI;
    }

    function setContractURI(string memory uri) external onlyOwner {
        _contractURI = uri;
    }

    function zorbForAddress(address user) internal pure returns (string memory) {
        bytes[5] memory colors = ColorLib.gradientForAddress(user);

        string memory svg = string(
            abi.encodePacked(
                '<svg x="4%" y="4%" width="40" height="40" viewBox="0 0 110 110"><defs>'
                '<radialGradient id="gzr" gradientTransform="translate(66.4578 24.3575) scale(75.2908)" gradientUnits="userSpaceOnUse" r="1" cx="0" cy="0%">'
                '<stop offset="15.62%" stop-color="',
                colors[0],
                '" /><stop offset="39.58%" stop-color="',
                colors[1],
                '" /><stop offset="72.92%" stop-color="',
                colors[2],
                '" /><stop offset="90.63%" stop-color="',
                colors[3],
                '" /><stop offset="100%" stop-color="',
                colors[4],
                '" /></radialGradient></defs><g transform="translate(5,5)">'
                '<path d="M100 50C100 22.3858 77.6142 0 50 0C22.3858 0 0 22.3858 0 50C0 77.6142 22.3858 100 50 100C77.6142 100 100 77.6142 100 50Z" fill="url(#gzr)" /><path stroke="rgba(0,0,0,0.075)" fill="transparent" stroke-width="1" d="M50,0.5c27.3,0,49.5,22.2,49.5,49.5S77.3,99.5,50,99.5S0.5,77.3,0.5,50S22.7,0.5,50,0.5z" />'
                "</g></svg>"
            )
        );

        return svg;
    }
}
