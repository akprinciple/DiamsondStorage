// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibMultisigStorage {

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
        assembly {
            ds.slot := 0
        }
    }
}