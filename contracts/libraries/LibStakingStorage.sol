// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibStakingStorage {

    struct StakingStorage {
        mapping(address => uint256) balances;
        uint256 totalStaked;
    }

    function layout() internal pure returns (StakingStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}