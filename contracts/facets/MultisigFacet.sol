// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibMultisigStorage} from "../libraries/LibMultisigStorage.sol";

contract MultisigFacet {
    event SubmitTransaction(address indexed owner, uint indexed txIndex, address indexed to, uint value, bytes data);
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    modifier onlyOwner() {
        require(LibMultisigStorage.layout().isOwner[msg.sender], "MultisigFacet: not owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < LibMultisigStorage.layout().transactions.length, "MultisigFacet: tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!LibMultisigStorage.layout().transactions[_txIndex].executed, "MultisigFacet: tx already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!LibMultisigStorage.layout().isConfirmed[_txIndex][msg.sender], "MultisigFacet: tx already confirmed");
        _;
    }

    function initMultisig(address[] memory _owners, uint _numConfirmationsRequired) external {
        LibMultisigStorage.MultisigStorage storage ds = LibMultisigStorage.layout();
        require(ds.owners.length == 0, "MultisigFacet: already initialized");
        require(_owners.length > 0, "MultisigFacet: owners required");
        require(
            _numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length,
            "MultisigFacet: invalid number of required confirmations"
        );

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "MultisigFacet: invalid owner");
            require(!ds.isOwner[owner], "MultisigFacet: owner not unique");

            ds.isOwner[owner] = true;
            ds.owners.push(owner);
        }
        ds.numConfirmationsRequired = _numConfirmationsRequired;
    }

    function submitTransaction(address _to, uint _value, bytes memory _data) external onlyOwner returns (uint256) {
        LibMultisigStorage.MultisigStorage storage ds = LibMultisigStorage.layout();
        uint txIndex = ds.transactions.length;

        ds.transactions.push(LibMultisigStorage.Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numConfirmations: 0
        }));

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
        return txIndex;
    }

    function confirmTransaction(uint _txIndex) external onlyOwner txExists(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex) {
        LibMultisigStorage.MultisigStorage storage ds = LibMultisigStorage.layout();
        LibMultisigStorage.Transaction storage transaction = ds.transactions[_txIndex];

        transaction.numConfirmations += 1;
        ds.isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function executeTransaction(uint _txIndex) external onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        LibMultisigStorage.MultisigStorage storage ds = LibMultisigStorage.layout();
        LibMultisigStorage.Transaction storage transaction = ds.transactions[_txIndex];

        require(transaction.numConfirmations >= ds.numConfirmationsRequired, "MultisigFacet: cannot execute tx");

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "MultisigFacet: tx failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint _txIndex) external onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        LibMultisigStorage.MultisigStorage storage ds = LibMultisigStorage.layout();
        LibMultisigStorage.Transaction storage transaction = ds.transactions[_txIndex];

        require(ds.isConfirmed[_txIndex][msg.sender], "MultisigFacet: tx not confirmed");

        transaction.numConfirmations -= 1;
        ds.isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function getOwners() external view returns (address[] memory) {
        return LibMultisigStorage.layout().owners;
    }

    function getTransaction(uint _txIndex) external view txExists(_txIndex) returns (address to, uint value, bytes memory data, bool executed, uint numConfirmations) {
        LibMultisigStorage.Transaction storage transaction = LibMultisigStorage.layout().transactions[_txIndex];
        return (transaction.to, transaction.value, transaction.data, transaction.executed, transaction.numConfirmations);
    }
}
