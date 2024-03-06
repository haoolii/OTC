// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

contract OTC {
    enum TransactionStatus {
        Pending,
        Approved,
        Success,
        Cancelled
    }

    struct Transaction {
        bytes32 id;
        address owner;
        address receiver;
        address token;
        uint256 amount;
        bytes32 targetId;
        TransactionStatus status;
    }

    uint256 public nextTransactionId;
    mapping(bytes32 => bool) public uniqueKeys;
    bytes32[] public allKeys;

    mapping(bytes32 => Transaction) public transactions;
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    function createTransaction(
        address _token,
        uint256 _amount,
        address _receiver,
        bytes32 _targetId
    ) external {
        bytes32 transactionId = getNextTransactionId();
        Transaction memory transaction;
        transaction.id = transactionId;
        transaction.owner = msg.sender;
        transaction.token = _token;
        transaction.amount = _amount;
        transaction.receiver = _receiver;
        transaction.status = TransactionStatus.Pending;

        if (_targetId != bytes32(0)) {
            transaction.targetId = _targetId;
        }

        transactions[transactionId] = transaction;
        uniqueKeys[transactionId] = true;
        allKeys.push(transactionId);
    }

    function generateUniqueKey(uint256 dataKey)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(dataKey));
    }

    function getNextTransactionId() internal returns (bytes32) {
        bytes32 transactionId = generateUniqueKey(nextTransactionId);
        nextTransactionId++;
        return transactionId;
    }

    function getAllKeys() public view returns (bytes32[] memory) {
        return allKeys;
    }

    function getTransaction(bytes32 _id)
        public
        view
        returns (Transaction memory)
    {
        return transactions[_id];
    }

    function cancelTransaction(bytes32 _id) external {
        Transaction storage transaction = transactions[_id];
        require(
            msg.sender == transaction.owner,
            "you don't own this transaction"
        );
        transaction.status = TransactionStatus.Cancelled;
    }

    function approveTransaction(bytes32 _id) external {
        Transaction storage transaction = transactions[_id];
        require(
            msg.sender == transaction.owner,
            "you don't own this transaction"
        );
        transaction.status = TransactionStatus.Approved;
    }

    function completeTransaction(bytes32 _id) external {
        Transaction storage transaction = transactions[_id];
        require(
            msg.sender == transaction.owner,
            "you don't own this transaction"
        );
        transaction.status = TransactionStatus.Success;
    }

    function withdraw(bytes32 id) public view returns (string memory) {
        Transaction memory transaction = getTransaction(id);

        if (transaction.status == TransactionStatus.Success) {
            if (msg.sender == transaction.receiver) {
                return "winthdraw success";
            } else {
                return "you can't withdraw";
            }
        }

        if (transaction.status == TransactionStatus.Cancelled) { 
            if (msg.sender == transaction.owner) {
                return "winthdraw success";
            } else {
                return "you can't withdraw";
            }
        }

        return "stauts can't withdraw";
        
    }
}
