// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {String} from "../../../primitives/String.sol";
import {Base64} from "../../../encoding/Base64.sol";
import {UInt} from "../../../primitives/UInt.sol";
// import "thefactory/utils/primitives/Primitives.sol";

library NFTDescriptor {
    using String for uint256;
    using UInt for uint256;

    struct ConstructTokenURIParams {
        uint256 tokenId;
        bool isLocked;
        uint256 positionValue;
    }

    function constructTokenURI(
        ConstructTokenURIParams memory params
    ) public pure returns (string memory) {
        string memory name = generateName(params);
        string memory image = Base64.encode(bytes(generateSVGImage(params)));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name,
                                '", "description":"Dynamic NFT representing real-time liquidity flow and valuation of a Pachira Position.", "image": "',
                                "data:image/svg+xml;base64,",
                                image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function generateName(
        ConstructTokenURIParams memory params
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "Pachira Position #",
                    params.tokenId._toString()
                )
            );
    }

    function generateSVGImage(
        ConstructTokenURIParams memory params
    ) internal pure returns (string memory) {
        string memory header = generateSVGHeader();
        string memory body = generateSVGContent(params);
        string memory footer = "</g></svg>";
        return string(abi.encodePacked(header, body, footer));
    }

    function generateSVGHeader() internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<svg width="290" height="500" viewBox="0 0 290 500" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
                    "<defs>",
                    '<linearGradient id="grad" x1="0%" y1="0%" x2="0%" y2="100%">',
                    '<stop offset="0%" stop-color="#1E1E1E" stop-opacity="1" />',
                    '<stop offset="100%" stop-color="#333333" stop-opacity="1" />',
                    "</linearGradient>",
                    '<filter id="glow" x="-50%" y="-50%" width="200%" height="200%">',
                    '<feGaussianBlur in="SourceGraphic" stdDeviation="10" result="blur" />',
                    '<feColorMatrix in="blur" type="matrix" values="1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 18 -7" result="glow" />',
                    '<feBlend in="SourceGraphic" in2="glow" />',
                    "</filter>",
                    "</defs>",
                    '<rect width="290px" height="500px" fill="url(#grad)" />',
                    '<g filter="url(#glow)">'
                )
            );
    }

    function generateSVGContent(
        ConstructTokenURIParams memory params
    ) internal pure returns (string memory) {
        string memory lockSymbol = params.isLocked ? unicode"🔒" : unicode"🔓";
        return
            string(
                abi.encodePacked(
                    '<text x="50%" y="100" fill="white" font-family="Courier New" font-size="36px" text-anchor="middle">',
                    "ID: ",
                    params.tokenId._toString(),
                    "</text>",
                    '<text x="50%" y="200" fill="white" font-family="Courier New" font-size="50px" text-anchor="middle">',
                    lockSymbol,
                    "</text>",
                    '<text x="50%" y="300" fill="white" font-family="Courier New" font-size="48px" text-anchor="middle">',
                    params.positionValue._toString(),
                    "</text>",
                    '<text x="50%" y="350" fill="white" font-family="Courier New" font-size="48px" text-anchor="middle">',
                    "BAL_WLP",
                    "</text>"
                )
            );
    }
}
