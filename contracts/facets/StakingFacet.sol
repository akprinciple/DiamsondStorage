// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibStakingStorage} from "../libraries/LibStakingStorage.sol";

contract StakingFacet {
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    function stake() external payable {
        LibStakingStorage.StakingStorage storage ds = LibStakingStorage.layout();
        require(msg.value > 0, "StakingFacet: Amount must be greater than 0");
        
        ds.balances[msg.sender] += msg.value;
        ds.totalStaked += msg.value;

        emit Staked(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external {
        LibStakingStorage.StakingStorage storage ds = LibStakingStorage.layout();
        require(_amount > 0, "StakingFacet: Amount must be greater than 0");
        require(ds.balances[msg.sender] >= _amount, "StakingFacet: Insufficient staked balance");

        ds.balances[msg.sender] -= _amount;
        ds.totalStaked -= _amount;

        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "StakingFacet: Transfer failed");

        emit Withdrawn(msg.sender, _amount);
    }

    function getStakedBalance(address _user) external view returns (uint256) {
        return LibStakingStorage.layout().balances[_user];
    }

    function getTotalStaked() external view returns (uint256) {
        return LibStakingStorage.layout().totalStaked;
    }
}
