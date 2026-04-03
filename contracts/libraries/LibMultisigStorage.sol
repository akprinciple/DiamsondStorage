// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibMultisigStorage {
    bytes32 internal constant MULTISIG_STORAGE_POSITION = keccak256("diamond.multisig.storage");

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numConfirmations;
    }

    struct MultisigStorage {
        address[] owners;
        mapping(address => bool) isOwner;
        uint256 numConfirmationsRequired;
        Transaction[] transactions;
        mapping(uint256 => mapping(address => bool)) isConfirmed;
    }

    function layout() internal pure returns (MultisigStorage storage ds) {
        bytes32 position = MULTISIG_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}