// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibSVGStorage} from "../libraries/LibSVGStorage.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

contract SVGFacet {
    event SVGColorsUpdated(string bgColor, string textColor);

    function setSVGColors(string memory _bgColor, string memory _textColor) external {
        LibDiamond.enforceIsContractOwner();
        LibSVGStorage.SVGStorage storage ds = LibSVGStorage.layout();
        
        ds.bgColor = _bgColor;
        ds.textColor = _textColor;
        
        emit SVGColorsUpdated(_bgColor, _textColor);
    }

    function generateSVG(uint256 tokenId) external view returns (string memory) {
        LibSVGStorage.SVGStorage storage ds = LibSVGStorage.layout();
        
        string memory bg = bytes(ds.bgColor).length > 0 ? ds.bgColor : "#1e1e1e";
        string memory txt = bytes(ds.textColor).length > 0 ? ds.textColor : "white";
        
        return string(
            abi.encodePacked(
                "<svg xmlns='http://www.w3.org/2000/svg' width='200' height='200'>",
                "<rect width='200' height='200' fill='", bg, "'/>",
                "<text x='20' y='100' fill='", txt, "' font-family='sans-serif' font-size='20'>",
                "Token #", _toString(tokenId),
                "</text></svg>"
            )
        );
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) { digits++; temp /= 10; }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}