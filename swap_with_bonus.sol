pragma solidity ^0.5.0;
interface ERC20{
    function totalSupply()external view returns (uint256);
    function balanceOf(address account)external view returns (uint256);
    function transfer(address recipient,uint256 amount)external returns (bool);
    function allowance(address owner,address spender)external returns (uint256);
    function approve(address spender,uint256 amount)external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount)external returns (bool);
    
    event Transfer(address indexed from,address indexed to,uint256 value);
    event Approve(address indexed owner,address indexed spender,uint256 value);
}
contract TokenSwap{
    ERC20 public usdt;
    ERC20 public opex;
    address public owner;
    uint public exchangeRate=90;
    uint totalBonus=0;
    uint bonus;
    address []dailyTrader;
    uint totalTrader=0;
    mapping(uint=>mapping(address => uint))toOPEXbalances;
    modifier onlyOwner(address caller){
        require(caller==owner);
        _;
    }
    constructor(address _token1,address _token2)public{
        usdt=ERC20(_token1);
        opex=ERC20(_token2);
        owner=msg.sender;
    }
    function changeRate(uint newRate)public onlyOwner(msg.sender){
        exchangeRate=newRate;
    }
    function getRate()public view returns(uint){
        return exchangeRate;
    }
    function swapFromUSDT(uint _amount,address to)public{
        uint _returnAmount=uint((_amount*100)/exchangeRate);
        require(usdt.allowance(to,address(this))>=_amount,"USDT allowance to low");
        _safeTransferFrom(usdt,to,address(this),_amount);
        opex.transfer(msg.sender,_returnAmount);
        if(totalTrader==0){dailyTrader[totalTrader]=to;totalTrader+=1;}
        else//totalTrader>=1
        {
            for(uint i=0;i<totalTrader;i++){
                if(dailyTrader[i]==to){
                    toOPEXbalances[i][to]+=_amount;
                }
            }
            toOPEXbalances[totalTrader][to]+=_amount;
        }
        totalBonus+=uint(_amount*8/100);
        //toOPEXbalances[][to]+=_amount;
    }
    function swapFromOPEX(uint _amount,address to)public{
        uint _returnAmount=uint(_amount*exchangeRate/100);
        require(opex.allowance(to,address(this))>=_amount,"OPEX allowance to low");
        _safeTransferFrom(opex,to,address(this),_amount);
        usdt.transfer(msg.sender,_returnAmount);
    }
    function _safeTransferFrom(ERC20 token,address sender,address recipient,uint amount)private{
        bool sent=token.transferFrom(sender,recipient,amount);
        require(sent,"Token transfer failed");
    }
    function getTotalTrader()public view returns(uint){
        return totalTrader;
    }
    function randomAirdrop(uint num)public onlyOwner(msg.sender)returns(bool){
        uint dailyBalance=toOPEXbalances[num][dailyTrader[num]];
        if(dailyBalance<1000){
            bonus=uint((totalBonus*10)/100);
            usdt.transfer(dailyTrader[num],bonus);
        }else if(dailyBalance>100&&dailyBalance<5000){
            bonus=uint((totalBonus*45)/100);
            usdt.transfer(dailyTrader[num],bonus);
        }else//dailyBalance>10000
        {
            bonus=totalBonus;
            usdt.transfer(dailyTrader[num],bonus);
        }
        return true;
    }
}
