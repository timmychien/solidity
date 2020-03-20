pragma solidity ^0.5.0;
import "./Factory.sol";
import"./MultiSigCard.sol";
contract multiSigCardFactory is Factory{
    
    function create(address[]memory _owners, uint _required)public returns(address card){
        card =address(new MultiSigCard(_owners,_required));
        register(card);
    }
}
