// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibERC20Storage} from "../libraries/LibERC20Storage.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

contract ERC20Facet {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice Initialize the Token Name, Symbol, and Decimals
    function initERC20(string memory _name, string memory _symbol, uint8 _decimals) external {
        LibDiamond.enforceIsContractOwner();
        LibERC20Storage.ERC20Storage storage ds = LibERC20Storage.layout();
        require(bytes(ds.name).length == 0, "ERC20Facet: already initialized");
        
        ds.name = _name;
        ds.symbol = _symbol;
        ds.decimals = _decimals;
    }

    function nameERC20() external view returns (string memory) {
        return LibERC20Storage.layout().name;
    }

    function symbolERC20() external view returns (string memory) {
        return LibERC20Storage.layout().symbol;
    }

    function decimals() external view returns (uint8) {
        return LibERC20Storage.layout().decimals;
    }

    function totalSupply() external view returns (uint256) {
        return LibERC20Storage.layout().totalSupply;
    }

    function balanceOf(address _account) external view returns (uint256) {
        return LibERC20Storage.layout().balances[_account];
    }

    function transfer(address _to, uint256 _amount) external returns (bool) {
        _transfer(msg.sender, _to, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) external view returns (uint256) {
        return LibERC20Storage.layout().allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount) external returns (bool) {
        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function transferFromERC20(address _from, address _to, uint256 _amount) external returns (bool) {
        LibERC20Storage.ERC20Storage storage ds = LibERC20Storage.layout();
        uint256 currentAllowance = ds.allowances[_from][msg.sender];
        require(currentAllowance >= _amount, "ERC20Facet: transfer amount exceeds allowance");
        
        unchecked {
            _approve(_from, msg.sender, currentAllowance - _amount);
        }
        _transfer(_from, _to, _amount);
        return true;
    }

    /// @notice Public minting function for testing purposes
    function mintERC20(address _to, uint256 _amount) external {
        require(_to != address(0), "ERC20Facet: mint to the zero address");
        LibERC20Storage.ERC20Storage storage ds = LibERC20Storage.layout();

        ds.totalSupply += _amount;
        ds.balances[_to] += _amount;
        
        emit Transfer(address(0), _to, _amount);
    }

    // --- Internal Helpers ---

    function _transfer(address _from, address _to, uint256 _amount) internal {
        require(_from != address(0), "ERC20Facet: transfer from the zero address");
        require(_to != address(0), "ERC20Facet: transfer to the zero address");
        
        LibERC20Storage.ERC20Storage storage ds = LibERC20Storage.layout();
        uint256 fromBalance = ds.balances[_from];
        require(fromBalance >= _amount, "ERC20Facet: transfer amount exceeds balance");
        
        unchecked {
            ds.balances[_from] = fromBalance - _amount;
            ds.balances[_to] += _amount;
        }

        emit Transfer(_from, _to, _amount);
    }

    function _approve(address _owner, address _spender, uint256 _amount) internal {
        require(_owner != address(0), "ERC20Facet: approve from the zero address");
        require(_spender != address(0), "ERC20Facet: approve to the zero address");

        LibERC20Storage.layout().allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }
}