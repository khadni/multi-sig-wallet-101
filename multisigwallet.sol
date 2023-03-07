// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @title MultiSig
 * @dev A contract for multi-signature wallets, allowing owners to create transactions that must be approved by
 * a certain number of other owners before execution. 
 */
contract MultiSig {
    // Owners of the wallet
    address[] public owners;
    // Number of required signatures to approve a transaction
    uint public required;

    // Struct representing a transaction
    struct Transaction{
        address destination;
        uint value;
        bool executed;
        bytes data;
    }

    // Array of all transactions
    Transaction[] public transactions;

    // Mapping of confirmations for each transaction
    mapping (uint => mapping (address => bool)) public confirmations;

    /**
     * @dev Constructor function for the MultiSig contract.
     * @param _owners Array of addresses representing the owners of the wallet.
     * @param _required Number of required signatures to approve a transaction.
     */
    constructor(address[] memory _owners, uint _required) {
        // Validate input parameters
        require (_owners.length > 0, "There should be at least one owner.");
        require(_required > 0, "There should be at least one signature required.");
        require(_required <= _owners.length, "Signatures required exceed the number of owners.");
        
        // Initialize owners and required variables
        owners = _owners;
        required = _required;
    }

    // Allow contract to receive Ether
    receive() payable external {}

    /**
     * @dev Function to get the total number of transactions created.
     * @return totalTxns Total number of transactions created.
     */
    function transactionCount() public view returns (uint totalTxns) {
        return transactions.length;
    }

    /**
     * @dev Function to add a new transaction.
     * @param _destination Address of the contract or account that will receive the transaction.
     * @param _value Amount of Ether to be sent with the transaction.
     * @param _data Data to be included in the transaction.
     * @return txnId ID of the new transaction.
     */
    function addTransaction(address _destination, uint _value, bytes memory _data) internal returns (uint txnId) {
        // Create new transaction and add it to the array of transactions
        transactions.push(Transaction(_destination, _value, false, _data));
        // Return the ID of the new transaction
        return (transactions.length - 1);
    }

    /**
     * @dev Submits a new transaction for confirmation and execution.
     * @param _destination The destination address of the transaction.
     * @param _value The value of the transaction in wei.
     * @param _data The data payload of the transaction.
     */
    function submitTransaction(address _destination, uint _value, bytes memory _data) external {
        uint txnId = addTransaction(_destination, _value, _data);
        confirmTransaction(txnId);
    }

    /**
     * @dev Function to confirm a transaction.
     * @param txnId ID of the transaction to confirm.
     */
    function confirmTransaction(uint txnId) public {
        // Check if the caller is an owner of the wallet
        bool isOwner;
        for (uint i = 0 ; i < owners.length ; i++) {
            if (owners[i] == msg.sender){
                isOwner = true;
            }
        }
        require (isOwner, "You're not an owner and cannot confirm a transaction.");

        // Mark the caller as confirmed for the given transaction
        confirmations[txnId][msg.sender] = true;

        // If the transaction is confirmed by enough owners, execute it
        if (isConfirmed(txnId)){
            executeTransaction(txnId);
        }
    }

    /**
     * @dev Returns whether a transaction has been confirmed by the required number of owners.
     * @param txnId The transaction ID.
     * @return A boolean representing whether the transaction has been confirmed.
     */
    function isConfirmed(uint txnId) public view returns (bool) {
        uint countConfirmations; // Counter for the number of confirmations received
        for (uint i = 0 ; i < owners.length ; i++){ // Loop through all owners
            if (confirmations[txnId][owners[i]] == true){ // Check if the owner has confirmed the transaction
                countConfirmations++; // Increment the confirmation counter
            }
        }
        if (countConfirmations >= required){ // Check if the required number of confirmations have been received
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns the number of confirmations for a given transaction.
     * @param txnId The transaction ID.
     * @return A uint representing the number of confirmations.
     */
    function getConfirmationsCount(uint txnId) public view returns (uint) {
        uint count;
        for (uint i = 0 ; i < owners.length ; i++){
            if (confirmations[txnId][owners[i]]){
                count++;
            }
        }
        return count;
    }

    /**
     * @dev Executes a confirmed transaction.
     * @param txnId The transaction ID.
     */
    function executeTransaction(uint txnId) public {
        // Check if the transaction has been confirmed by the required number of owners
        require(isConfirmed(txnId), "The txn has not been confirmed yet.");

        // Get the transaction information
        Transaction storage _tx = transactions[txnId];
            
        // Send the transaction to the specified address with the specified value and data
        (bool success, ) = _tx.destination.call{ value: _tx.value }(_tx.data);
        // Check if the transaction was successful
        require(success, "Failed to execute transaction");

        // Mark the transaction as executed
        _tx.executed = true;
    }
}