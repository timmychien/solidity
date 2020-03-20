/**
 *Submitted for verification at Etherscan.io on 2020-01-19
*/

pragma solidity ^0.5.0;
contract usercardinfo{
    event Confirmation(address indexed sender, uint indexed transactionId,uint value);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId,uint value);
    event ExecutionFailure(uint indexed transactionId);
    event EnterCardinfo(string PAN, string EXPIR_DTE,string SVC);
    event Revealcardinfo(string _PAN, string  _EXPIR_DTE,string _SVC);
    event RequestFailure(uint indexed transactionId);
     /*
     *  Storage
     */
    mapping (uint => CardinfoRequest) public cardtrans;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    //
    address[] public owners;
    uint public required;
    uint public transactionCount;
    string PAN;
    string EXPIR_DTE;
    string SVC;
    struct CardinfoRequest{
        string purpose;
        address destination;
        uint value;
        bool executed;
    }

    struct Cardinfo {
        string PAN;
        string EXPIR_DTE;
        string SVC;
    } 
    Cardinfo cardinfo;
    constructor(uint _required)public{
        require( _required <= 3
            && _required != 0
        );
        required=_required;
    }
    /*
     *  Modifiers
     */
   
    modifier RequestExists(uint transactionId) {
        require(cardtrans[transactionId].destination !=address(0));
        _;
    }

    modifier requestconfirmed(uint transactionId, address owner) {
        require(confirmations[transactionId][owner]);
        _;
    }
    modifier notConfirmed(uint transactionId, address owner) {
        require(!confirmations[transactionId][owner]);
        _;
    }
    modifier notNull(address _address) {
        require(_address != address(0));
        _;
    }

    /*
     * Public functions
     */
    function addcardinfo(string memory _PAN, string memory _EXPIR_DTE,string memory _SVC)
        private
    {
         emit EnterCardinfo(_PAN,_EXPIR_DTE,_SVC);
    }
    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @return Returns transaction ID.
     
    function submitRequest(address destination,string memory purpose, uint value)public returns (uint transactionId)
    {
        transactionId =requestCardinfo(purpose,destination,value);
        confirmRequest(transactionId,value);
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmRequest(uint transactionId,uint value)
        public
        RequestExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId,value);
    }

    /// @dev Allows an owner to revoke a confirmation for a transaction.
    /// @param transactionId Transaction ID.
    function revokeConfirmation(uint transactionId)
        public
        requestconfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = false;
       emit Revocation(msg.sender, transactionId);
    }
    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId Transaction ID.
   function isConfirmed(uint transactionId)
        public
        view
        returns (bool)
    {
       uint count = 0;
        for (uint i=0; i<owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }
    /*
     * Internal functions
     */
    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @return Returns transaction ID.
    function requestCardinfo(string memory purpose, address destination,uint value) 
        internal
        notNull(destination)
        returns(uint transactionId)
    {
        transactionId = transactionCount;
        cardtrans[transactionId] = CardinfoRequest({
            destination: destination,
            purpose: purpose,
            value: value,
            executed: false
        });
        transactionCount += 1;
        emit Submission(transactionId);
    }
    /*
     * Web3 call functions
     */
    /// @dev Returns number of confirmations of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Number of confirmations.
    function getConfirmationCount(uint transactionId)
        public
        view
        returns (uint count)
    {
        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
    }

    /// @dev Returns total number of transactions after filers are applied.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Total number of transactions after filters are applied.
    function getTransactionCount(bool pending, bool executed)
        public
        view
        returns (uint count)
    {
        for (uint i=0; i<transactionCount; i++)
            if (pending && !cardtrans[i].executed
                || executed && cardtrans[i].executed)
                count += 1;
    }

    /// @dev Returns array with owner addresses, which confirmed transaction.
    /// @param transactionId Transaction ID.
    /// @return Returns array of owner addresses.
    function getConfirmations(uint transactionId)
        public
        view
        returns (address[] memory _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i=0; i<count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }

    /// @dev Returns list of transaction IDs in defined range.
    /// @param from Index start position of transaction array.
    /// @param to Index end position of transaction array.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Returns array of transaction IDs.
    function getTransactionIds(uint from, uint to, bool pending, bool executed)
        public
        view
        returns (uint[]memory _transactionIds)
    {
        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint i;
        for (i=0; i<transactionCount; i++)
            if ( pending && !cardtrans[i].executed
                || executed && cardtrans[i].executed)
            {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint[](to - from);
        for (i=from; i<to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }

    function returncardinfo(uint transactionId)
        internal
        requestconfirmed(transactionId, msg.sender)
        returns(string memory _PAN, string memory _EXPIR_DTE,string memory _SVC)
    {
        if(isConfirmed(transactionId)){
            emit Revealcardinfo(_PAN, _EXPIR_DTE, _SVC);
        }else{
            emit RequestFailure(transactionId);
        }
    }
}
