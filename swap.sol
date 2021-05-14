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
    ERC20 public token1;
    ERC20 public token2; 
    constructor(address _token1,address _token2)public{
        token1=ERC20(_token1);
        token2=ERC20(_token2);
    }
    function swapFromtoken1(uint _amount,address to)public{
        require(token1.allowance(to,address(this))>=_amount,"token1 allowance to low");
        _safeTransferFrom(token1,to,address(this),_amount);
        token2.transfer(msg.sender,amount);
    }
    function swapFromOPEX(uint _amount,address to)public{
        require(opex.allowance(token2,address(this))>=_amount,"token2 allowance to low");
        _safeTransferFrom(token2,to,address(this),_amount);
        token1.transfer(msg.sender,amount);
    }
    function _safeTransferFrom(ERC20 token,address sender,address recipient,uint amount)private{
        bool sent=token.transferFrom(sender,recipient,amount);
        require(sent,"Token transfer failed");
    }
}