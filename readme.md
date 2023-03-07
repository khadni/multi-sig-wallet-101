# MultiSig Contract

A smart contract for multi-signature wallets, allowing owners to create transactions that must be approved by a certain number of other owners before execution.

## **Usage**

### **Creating a MultiSig Wallet**

To create a new multi-signature wallet, you need to deploy a new instance of the **`MultiSig`** contract on the Ethereum network. The constructor of the contract takes two parameters:

- An array of addresses representing the owners of the wallet.
- The number of required signatures to approve a transaction.

### **Sending Ether to the Wallet**

You can send Ether to the multi-signature wallet by simply sending a transaction to the contract's address.

### **Creating a New Transaction**

To create a new transaction, call the **`submitTransaction`** function on the contract, passing in the following parameters:

- The destination address of the transaction.
- The value of the transaction in wei.
- The data payload of the transaction.

### **Confirming a Transaction**

To confirm a transaction, call the **`confirmTransaction`** function on the contract, passing in the ID of the transaction you want to confirm.

### **Executing a Transaction**

Once a transaction has been confirmed by the required number of owners, it can be executed by calling the **`executeTransaction`** function on the contract, passing in the ID of the transaction you want to execute.

### **Checking Transaction Status**

You can check the status of a transaction by calling the **`isConfirmed`** function on the contract, passing in the ID of the transaction you want to check. This function will return a boolean value indicating whether the transaction has been confirmed by the required number of owners.

You can also check the number of confirmations for a transaction by calling the **`getConfirmationsCount`** function on the contract, passing in the ID of the transaction you want to check.

## \***\*Credits\*\***

This project was built as a part of the Alchemy University Ethereum Bootcamp.
