// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library DiamondStorage {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct Storage {
        uint256 valueFacetA;
        uint256 valueFacetB;
    }

    function diamondStorage() internal pure returns (Storage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}