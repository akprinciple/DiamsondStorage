// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibERC20Storage {

    struct ERC20Storage {
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
    }

    function layout() internal pure returns (ERC20Storage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}