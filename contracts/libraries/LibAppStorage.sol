// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibAppStorage {
    bytes32 internal constant APP_STORAGE_POSITION = keccak256("diamond.app.storage");

    struct AppStorage {
        string name;
        string symbol;
        mapping(uint256 => address) ownerOf;
        mapping(address => uint256) balanceOf;
        mapping(uint256 => address) tokenApprovals;
        mapping(address => mapping(address => bool)) operatorApprovals;
    }

    function appStorage() internal pure returns (AppStorage storage s) {
        bytes32 position = APP_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}
