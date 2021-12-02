pragma solidity^0.5.0;
contract ERC20{
    function transferFrom(address sender,address recipient,uint amount)public returns(bool){
        
    }
    function approve(address spender, uint amount) public returns (bool) {
       
    }
    function transfer(address recipient, uint amount) public returns (bool){
        
    }
    function balanceOf(address account) public view returns (uint){
        
    }
   
}
contract gliese{
    ERC20 usdt=ERC20(usdtAddress);
    uint public totalUser=0;
    uint public totalOpex=0;
    uint it=0;
    uint count=0;
    address opexAddress;
    address usdtAddress;
    mapping(address=>uint)public balances;
    mapping(uint=>address)public userList;
    constructor(address opexAddress_,address usdtAddress_)public{
        opexAddress=opexAddress_;
        usdtAddress=usdtAddress_;
    }
    function getTotalUSDT()public view returns(uint){
        uint totalBalance=ERC20(usdtAddress).balanceOf(address(this));
        return totalBalance;
    }
    function put(uint amount)public returns(bool){
        transfer_(msg.sender,address(this),amount);
        if(balances[msg.sender]==0){
            totalUser=totalUser+1;
            userList[count]=msg.sender;
            count=count+1;
        }
        balances[msg.sender]+=amount;
        totalOpex+=amount;
        return true;
    }
    function airdrop()public returns(bool){
        ERC20 usdt=ERC20(usdtAddress);
        ERC20 opex=ERC20(opexAddress);
        uint totalReturns=100000000;
        uint totalBalance=ERC20(usdtAddress).balanceOf(address(this));
        for(it=0;it<totalUser;it++){
            uint reward=uint((balances[userList[it]]*totalBalance)/totalOpex);
            uint Returns=uint(balances[userList[it]]*totalReturns/totalOpex);
            ERC20(usdt).transfer(userList[it],reward);
            ERC20(opex).transfer(userList[it],balances[userList[it]]);
            ERC20(opex).transfer(userList[it],Returns);
            delete balances[userList[it]];
            delete userList[it];
        }
        totalUser=0;
        totalOpex=0;
        count=0;
        it=0;
        return true;
    }
    function transfer_(address owner,address recipient,uint amount)internal returns (bool){
        ERC20 opex=ERC20(opexAddress);
        opex.transferFrom(owner,recipient,amount);
        return true;
  }
}