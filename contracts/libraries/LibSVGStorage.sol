// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibSVGStorage {
    bytes32 constant SVG_STORAGE_POSITION = keccak256("diamond.standard.svg.storage");

    struct SVGStorage {
        string bgColor;
        string textColor;
    }

    function layout() internal pure returns (SVGStorage storage ds) {
        bytes32 position = SVG_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}