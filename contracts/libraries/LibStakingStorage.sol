// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibStakingStorage {
    bytes32 internal constant STAKING_STORAGE_POSITION = keccak256("diamond.staking.storage");

    struct StakingStorage {
        mapping(address => uint256) balances;
        uint256 totalStaked;
    }

    function layout() internal pure returns (StakingStorage storage ds) {
        bytes32 position = STAKING_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}