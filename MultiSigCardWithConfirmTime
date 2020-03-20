pragma solidity ^0.5.0;
import "./MultiSigCard.sol";
contract MultiSigCardWithConfirmTime is MultiSigCard{
    event ConfirmTimeChange(uint _confirmtimeLimit);
    //event Execution(uint indexed transactionId);
    //event ExecutionFailure(uint indexed transactionId);
    uint public confirmtimeLimit;
    uint public starttime;
    uint public confirmtime;
    function ()payable external{
        
    }
    constructor(uint _required,uint _confirmtimeLimit) public MultiSigCard( _required){
        confirmtimeLimit = _confirmtimeLimit;
    }
   
    function changeConfirmTime (uint _confirmtimeLimit)public onlyCard {
        confirmtimeLimit=_confirmtimeLimit;
        emit ConfirmTimeChange(_confirmtimeLimit);
    }
    function executeTransaction(uint _transactionId,uint value)
        public
        ownerExists(msg.sender)
        confirmed(_transactionId, msg.sender,value)
        notExecuted(_transactionId)
    {
        Transaction storage txn = transactions[_transactionId];
        bool _confirmed = isConfirmed(_transactionId,value);
        
        if (_confirmed ||isInTime(confirmtime)) {
            emit Execution(_transactionId,value);
            txn.executed = true;}
             else{
                emit ExecutionFailure(_transactionId);
                txn.executed = false;
            }
        }
        function isInTime(uint _confirmtimeLimit) public returns(bool){
        confirmtime=now;
        if(now-starttime<=_confirmtimeLimit ){
            return true;
        }else{
           return false;
        }
    }
}
    
   
