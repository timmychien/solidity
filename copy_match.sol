pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

library SafeMath {  
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
library DateTime {
        /*
         *  Date and Time utilities for ethereum contracts
         *
         */
        struct _DateTime {
                uint16 year;
                uint8 month;
                uint8 day;
                uint8 hour;
                uint8 minute;
                uint8 second;
                uint8 weekday;
        }

        uint constant DAY_IN_SECONDS = 86400;
        uint constant YEAR_IN_SECONDS = 31536000;
        uint constant LEAP_YEAR_IN_SECONDS = 31622400;

        uint constant HOUR_IN_SECONDS = 3600;
        uint constant MINUTE_IN_SECONDS = 60;

        uint16 constant ORIGIN_YEAR = 1970;

        function isLeapYear(uint16 year) internal pure returns (bool) {
                if (year % 4 != 0) {
                        return false;
                }
                if (year % 100 != 0) {
                        return true;
                }
                if (year % 400 != 0) {
                        return false;
                }
                return true;
        }

        function leapYearsBefore(uint year) internal pure returns (uint) {
                year -= 1;
                return year / 4 - year / 100 + year / 400;
        }

        function getDaysInMonth(uint8 month, uint16 year) internal pure returns (uint8) {
                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                        return 31;
                }
                else if (month == 4 || month == 6 || month == 9 || month == 11) {
                        return 30;
                }
                else if (isLeapYear(year)) {
                        return 29;
                }
                else {
                        return 28;
                }
        }

        function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory dt) {
                uint secondsAccountedFor = 0;
                uint buf;
                uint8 i;

                // Year
                dt.year = getYear(timestamp);
                buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
                secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

                // Month
                uint secondsInMonth;
                for (i = 1; i <= 12; i++) {
                        secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
                        if (secondsInMonth + secondsAccountedFor > timestamp) {
                                dt.month = i;
                                break;
                        }
                        secondsAccountedFor += secondsInMonth;
                }

                // Day
                for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
                        if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                                dt.day = i;
                                break;
                        }
                        secondsAccountedFor += DAY_IN_SECONDS;
                }

                // Hour
                dt.hour = getHour(timestamp);

                // Minute
                dt.minute = getMinute(timestamp);

                // Second
                dt.second = getSecond(timestamp);

                // Day of week.
                dt.weekday = getWeekday(timestamp);
        }

        function getYear(uint timestamp) internal pure returns (uint16) {
                uint secondsAccountedFor = 0;
                uint16 year;
                uint numLeapYears;

                // Year
                year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
                numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
                secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

                while (secondsAccountedFor > timestamp) {
                        if (isLeapYear(uint16(year - 1))) {
                                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                secondsAccountedFor -= YEAR_IN_SECONDS;
                        }
                        year -= 1;
                }
                return year;
        }

        function getMonth(uint timestamp) internal pure returns (uint8) {
                return parseTimestamp(timestamp).month;
        }

        function getDay(uint timestamp) internal pure returns (uint8) {
                return parseTimestamp(timestamp).day;
        }

        function getHour(uint timestamp) internal pure returns (uint8) {
                return uint8((timestamp / 60 / 60) % 24);
        }

        function getMinute(uint timestamp) internal pure returns (uint8) {
                return uint8((timestamp / 60) % 60);
        }

        function getSecond(uint timestamp) internal pure returns (uint8) {
                return uint8(timestamp % 60);
        }

        function getWeekday(uint timestamp) internal pure returns (uint8) {
                return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day) internal pure returns (uint timestamp) {
                return toTimestamp(year, month, day, 0, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) internal pure returns (uint timestamp) {
                return toTimestamp(year, month, day, hour, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) internal pure returns (uint timestamp) {
                return toTimestamp(year, month, day, hour, minute, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) internal pure returns (uint timestamp) {
                uint16 i;

                // Year
                for (i = ORIGIN_YEAR; i < year; i++) {
                        if (isLeapYear(i)) {
                                timestamp += LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                timestamp += YEAR_IN_SECONDS;
                        }
                }

                // Month
                uint8[12] memory monthDayCounts;
                monthDayCounts[0] = 31;
                if (isLeapYear(year)) {
                        monthDayCounts[1] = 29;
                }
                else {
                        monthDayCounts[1] = 28;
                }
                monthDayCounts[2] = 31;
                monthDayCounts[3] = 30;
                monthDayCounts[4] = 31;
                monthDayCounts[5] = 30;
                monthDayCounts[6] = 31;
                monthDayCounts[7] = 31;
                monthDayCounts[8] = 30;
                monthDayCounts[9] = 31;
                monthDayCounts[10] = 30;
                monthDayCounts[11] = 31;

                for (i = 1; i < month; i++) {
                        timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
                }

                // Day
                timestamp += DAY_IN_SECONDS * (day - 1);

                // Hour
                timestamp += HOUR_IN_SECONDS * (hour);

                // Minute
                timestamp += MINUTE_IN_SECONDS * (minute);

                // Second
                timestamp += second;

                return timestamp;
        }
}
// import "./SafeMath.sol";
// import "./DateTime.sol";
		
/*  版本說明
    版本: 0.3.0
    主要內容:
    1. 取消 addrHolder 為strategy 的參數, 因為每一個策略為一個智能合約, 無須分辨
    2. 將委託下單的紀錄 copyTrades, 獨立於 commit 變數之外
    3. 增加每月交易紀錄的結構 copyRecord (以策略角度的紀錄)
    4. 增加計算每月交易報酬的功能: calcMonthlyReturnRate
    5. 增加查詢資料的功能: getStrategy取得策略資訊
        getNumCommits取得總媒合數, getCommitId取得媒合同一跟單人的序號, getCommit取得媒合資訊
        getReceipt取得特定續跟單序號的紀錄, getAllReceipts取得所有跟單的紀錄
    6. 引入 DateTime.sol 取得 uinx 時間轉為年月日的功能
*/

//  標的: 策略程式
/*
	部署人: 
	1. 擁有者		proxyOwner -> 程式部署人
	2. 驗證程式雜湊 function valid_hash() is owner: 
	3. 確認買賣訊號 function signal() is owner: 驗證雜湊數為真則同意
	4. 計算投資報酬 function rate_of_return () is owner: 提供跟單人
	5. 計算月投資	function monthly_return() is owner: 公告於網頁
	6. 收取平台手續費 (雙方)
 */
 
 contract CopyMatch{
    using SafeMath for uint;
    using DateTime for DateTime._DateTime;
    
	uint256 public numCommits; //媒合成功次數
	uint256 public numCopyTraders; //媒合成功人數
	uint256 public MatchFeeCopyTrader = 1500;
	uint256 public MatchFeeHolder=1000;
	//uint256 DeployFee=500;
//  參與者: 1. 部署人(代理合約) 2. 策略程式撰寫人 3. 跟單人 4.平台擁有人
	address public addrProxyOwner;
	address public addrProxy;
	address	public owner;

/*
	策略程式撰寫人 addrHolder
	1. 設定跟單條件(建立策略) 前端輸入 -> function createStrategy
	2. 取消策略程式 function inactiveStrategy
	3. 重新激活策略 function activeStrategy
	//4. 負擔部署費 DeployFee
	5. 收取顧問費 frontVarFee, frontFixFee, backFee
	6. 負擔媒合費 MatchFeeHolder
 */
 	address public addrHolder;
 	bool public isHolder = false; //true => 為 holder
 	string public symbol; //策略程式代號
 	bool public hasStrategy; //是否曾經建立策略 (策略條件修改視為新策略)
 	//策略程式
	struct Strategy{
		bool 	boolActive;		//true =>策略持續
		bytes32	hashStrategy;	//策略程式雜湊數
		uint256 minAmount;		//最低投資金額
		uint256 maxAmount;		//最大投資限額, 若未定則為9,999,999,999,999
		uint256 frontVarFee;	//前置顧問費, 依投資金額
		uint256 frontFixFee;	//前置顧問費, 固定金額
		uint256 backFee;		//後收顧問費, 依利潤
	}
	Strategy public strategy; //strategy
	
/*  
	跟單人: addrCopyTrader (局部變數, 作為函數參數輸入)
	1. 媒合跟單: 策略程式 投資金額, 投資時間, 停止條件 前端 -> function createCommmit
	2. 查詢投資內容 function SQL: 前端request -> 後端 -> event -> 後端 response -> 前端
	3. 管理投資帳戶 呼叫 proxy.GetBalance, .Deposit (入金), .Withdral (出金) 
*/

	//成交合約
	struct	Commit{					
		bool		boolCommit ;		//媒合與否
		uint 		startTime;		//開始期間
		uint 		endTime;		//結束期間
		uint 		commitAmount;	//跟單金額
		uint 		commitFees;		//成交手續費
		uint 		usedAmount;		//累計已投資金額 require (usedAmount <=commitAmount)
		uint 		commitReturn;	//本次交易總收入(含本金)
		uint 		totalReturn;	//本次委託下單報酬率
		uint 		numCopies;		//實際委託下單累計次數
		string 	otherData;		//其他資訊			
	}
	//commit[跟單人位址][id 次數]
    mapping(address => mapping(uint => Commit)) public commit; 
	mapping(address => uint) public commitId; //id 跟隨序號, 媒合同一投資人與此智能合約的次數
	mapping(uint => address) public groupTrader; //所有跟單者的位址

	//跟單結果
	struct copyReceipt{
		uint time;		//開始
		uint Amount;	//金額 +為賣出, -為買入
	}
	//copyTrades[跟單人位址addrCopyTrader][第幾次序號id][下單次數numCopies]
    mapping(address => mapping(uint => mapping(uint => copyReceipt))) public copyTrades;

	//交易紀錄 record[年度][月份][日]
	struct copyRecord {
	    uint inject; //投入金額
	    uint outcome; //贖回金額
	}
	mapping(uint => mapping(uint => mapping(uint => copyRecord))) public historyRecord;

	event eventCreateStrategy(address addrProxy, address addrHolder, string symbol, bytes32 hashStrategy,
		uint256 minAmount,uint256 maxAmount,
		uint256 frontVarFee,uint256 frontFixFee,uint256 backFee, uint256 timestamp);	
	event eventInActive(string symbol, address addrHolder, uint256 timestamp);	
	event eventActive(string symbol, address addrHolder, uint256 timestamp);	
	event eventStartCommit(uint numCommits, address addrCopyTrader, uint commitId, uint amount, uint timestamp);
	event eventEndCommit(uint numCommits, address addrCopyTrader, uint commitId, uint endAmount, uint256 timestamp1, uint256 timestamp2);
	event eventMonthlyReturn(uint MonthlyReturn, uint timestamp);
	event eventCopy(uint commitId, address copytrader, uint amount, bool signal, uint timestamp);
    event eventCloseCopy(uint256 numCopies, uint256 timestamp);
    event eventFallbackTrigged(bytes data);
    
    //test
    event eventConstructor(address addrProxyOwner, uint numCommits, bool isHolder, bool hasStrategy, uint numCopyTraders);

	modifier onlyOwner(){
		require(msg.sender == addrProxyOwner);
		_;
	}
	modifier onlyHolder(){
		require(isHolder);
		_;
	}
	modifier notHolder(){
		require(isHolder != true );
		_;
	}
	modifier onlyFirst(){
		require(hasStrategy == false);
		_;
	}

	constructor () public {
	    addrProxyOwner = msg.sender; //後端以代理人帳號部署
	    //addrProxy = proxy;
	    numCommits = 0;
	    //addrHolder = holder;
	    isHolder = true; //由代理合約判斷是否為holder
	    hasStrategy = false;
	    numCopyTraders = 0;
	    emit eventConstructor(addrProxyOwner, numCommits, isHolder, hasStrategy, numCopyTraders);
	    
	}
	//createStrategy
    //hashStrategy傳入要加 "0x"
	function createStrategy (address proxy, address holder, string memory sbl, bytes32 hashStrategy, 
		uint minAmount, uint maxAmount, 
		uint frontVarFee, uint frontFixFee, uint backFee) onlyFirst public returns(bool) {
		require(msg.sender==addrProxyOwner);
		
		//初始化
		addrProxy = proxy;
		addrHolder = holder;
		symbol = sbl;
		

		strategy.hashStrategy = hashStrategy;
		strategy.minAmount=minAmount;
		strategy.maxAmount=maxAmount;
		strategy.frontVarFee=frontVarFee;
		strategy.frontFixFee=frontFixFee;
		strategy.backFee=backFee;
		strategy.boolActive=true; //已經建立策略程式
		
		hasStrategy = true;
		
		emit eventCreateStrategy(addrProxy, addrHolder, symbol, hashStrategy, minAmount, maxAmount,frontVarFee,frontFixFee,backFee, now);	
	
		strategy.boolActive=true;
		return true;
	}
	//取消策略程式
	function inActiveStrategy () onlyHolder public returns(bool) {
        require(msg.sender==addrProxyOwner || msg.sender==addrProxy);
	    require(strategy.boolActive);
	    
		strategy.boolActive=false;

		emit eventInActive(symbol, addrHolder, now);	
	
		return true;
	}
	//重新激活策略程式
	function ActiveStrategy () onlyHolder public returns(bool) {
        require(msg.sender==addrProxyOwner || msg.sender==addrProxy);
	    require(strategy.boolActive==false);
	    
		strategy.boolActive=true;

		emit eventActive(symbol, addrHolder, now);	
	
		return true;
	}
	//建立媒合資訊
    function createCommit(address addrCopyTrader,  uint id,
        uint amount, string memory otherData) /*notHolder*/ public returns(bool) {
        require(msg.sender==addrProxyOwner || msg.sender==addrProxy);
 		//commitId[addrCopyTrader]預設為0
 		if(id==0){
 		    id=id+1;
 		}
 		require(strategy.boolActive);
 		require(commit[addrCopyTrader][id].boolCommit!=true);
 		Commit memory hasOnGoingCommit;
    	
    	hasOnGoingCommit.boolCommit = true;
    	//計數+1
    	commitId[addrCopyTrader] = id+1;
    	hasOnGoingCommit.startTime = now;
    	hasOnGoingCommit.endTime = now ;
    	if (id==1){
    	    numCopyTraders = numCopyTraders.add(1);
    	    groupTrader[numCopyTraders] = addrCopyTrader;
    	}
    	uint256 b=calcFees(amount);
    	
    	//ERC865.transferFrom(addrCopyTrader, proxyOwner, a);
    	//ERC865.transferFrom(proxyOwner, addrHolder, b.sub(MatchFee));
    	//移轉跟單資金及媒合費至媒合平台
    	uint a = amount;
    	a = a.add(b); //投資金額amount + 顧問費b +媒合手續費 MatchFeeCopyTrader
    	a = a.add(MatchFeeCopyTrader);
        //a已改成後端計算,這邊只是說有這個計算而已
        /*
        bytes memory method_1 = abi.encodeWithSignature("transferFrom(address,address,uint256)", addrCopyTrader, addrProxy, a);
    	addrProxy.call(method_1);
    	//媒合平台移轉顧問費(扣除媒合費)至策略程式撰寫人
        bytes memory method_2 = abi.encodeWithSignature("transferFrom(address,address,uint256)", addrProxy, addrHolder, b.sub(MatchFeeHolder));
    	addrProxy.call(method_2);
    	*/
    	
    	hasOnGoingCommit.commitAmount =amount;
    	hasOnGoingCommit.commitFees = b;
    	hasOnGoingCommit.usedAmount = 0;
    	hasOnGoingCommit.commitReturn = hasOnGoingCommit.commitAmount; 
    	hasOnGoingCommit.totalReturn = 0;
    	hasOnGoingCommit.numCopies = hasOnGoingCommit.numCopies.add(1);
    	hasOnGoingCommit.otherData = otherData;
    	commit[addrCopyTrader][id] = hasOnGoingCommit;
    	uint startTime=hasOnGoingCommit.startTime;
    	
    	emit eventStartCommit(numCommits, addrCopyTrader, id, amount, startTime);

        //historyRecord
        uint16 y=DateTime.getYear(startTime);
        uint8 m=DateTime.getMonth(startTime);
        uint d=DateTime.getDay(startTime);
        historyRecord[y][m][d].inject=historyRecord[y][m][d].inject.add(amount);

    	hasOnGoingCommit.boolCommit =false;
    	numCommits = numCommits.add(1) ;
    	return true;
    }
        //endAmount = 全部賣出的金額
    function endCommit (address addrCopyTrader,  uint id,
    	uint256 endAmount) public returns(bool){
        require(msg.sender==addrProxyOwner || msg.sender==addrProxy);
	    
	    require(commit[addrCopyTrader][id].boolCommit);
		Commit memory hasOnGoingCommit;
		//如果不增加這行,沒有放數值的Commit struct會預設為0,反而會覆蓋掉原來的資料
    	hasOnGoingCommit = commit[addrCopyTrader][id];
    	hasOnGoingCommit.boolCommit = false;

    	hasOnGoingCommit.endTime = now ;
    	uint256 s;
    	uint256 b;
    	(s,b)=calcBack(commit[addrCopyTrader][id].commitAmount, endAmount);
    	
    	//erc865
    	//proxy(proxyOwner).transferFrom(proxyOwner, addrHolder, b);
    	//proxy(proxyOwner).transferFrom(proxyOwner, addrCopyTrader, endAmount.sub(b));
    	/*
        bytes memory method_1 = abi.encodeWithSignature("transferFrom(address,address,uint256)", addrProxy, addrHolder, b);
    	addrProxy.call(method_1);
        bytes memory method_2 = abi.encodeWithSignature("transferFrom(address,address,uint256)", addrProxy, addrCopyTrader, endAmount.sub(b));
    	addrProxy.call(method_2);
        */
        
    	hasOnGoingCommit.commitFees = hasOnGoingCommit.commitFees.add(b);
    	hasOnGoingCommit.usedAmount = 0;
    	hasOnGoingCommit.commitReturn = endAmount.sub(b); 
    	hasOnGoingCommit.otherData = "The end of commit, started:" ; //尚缺將時間轉為文字
    	require(copyEnd(addrCopyTrader,id));
    	commit[addrCopyTrader][id] = hasOnGoingCommit;
    	
    	//-----------Stack too deep error,所以多加這幾行
    	address addrCopyTrader_var = addrCopyTrader;
    	uint id_var = id;
    	//---------------------------------------------------
    	
    	emit eventEndCommit(numCommits, addrCopyTrader, id_var, endAmount, commit[addrCopyTrader_var][id_var].startTime, hasOnGoingCommit.endTime);
    	
    	//historyRecord
    	uint endTime = hasOnGoingCommit.endTime;
        uint16 y=DateTime.getYear(endTime);
        uint8 m=DateTime.getMonth(endTime);
        uint d=DateTime.getDay(endTime);
        historyRecord[y][m][d].outcome=historyRecord[y][m][d].outcome.add(endAmount);
        
    	return true;
    }

    function calcFees(uint256 _amount) internal view returns(uint256){
        uint256 fees=((strategy.frontVarFee.mul(_amount))).div(100).
        			  add(strategy.frontFixFee);
        return fees;
    }

    function calcBack(uint256 _amount, uint256 _returns) internal view returns(uint256,uint256){
        uint256 sign_bit;//增加判斷正負值,0為正數,1為負數,避免uint算出負數
    	uint256 fees;
    	if(_returns>=_amount){
	        fees = (strategy.backFee.mul((_returns.sub(_amount)))).div(100);
	        sign_bit = 0;
    	}
    	else{
    	    fees = 0; //賠錢不收費用
    	    sign_bit = 1;
    	}
    	return (sign_bit,fees);
    }
 	function calcReturnRate(uint256 _init, uint256 _end) internal pure returns(uint256){
 		uint256 r=(_end.sub(_init)).mul(100).div(_init);
 		return r;
 	}
 	//_mv為尚未贖回的市價, 由券商提提供
 	function calcMonthlyReturnRate(uint16 _year, uint8 _month, uint _mv) internal view returns (uint256, uint256){
 	    uint dInM = DateTime.getDaysInMonth(_month, _year);
 	    uint inject; 
 	    uint outcome;
 	    uint t_inject=0;
 	    uint t_outcome=0;
 	    uint m_inject=0;
 	    uint m_outcome=0;
 	    uint multiplier = 0;
 	    for (uint i = 1; i <= dInM; i++) {
            inject = historyRecord[_year][_month][i].inject;
            outcome =historyRecord[_year][_month][i].outcome;
            multiplier = multiplier.add(dInM.add(1).sub(i));
            m_inject = m_inject.add(inject.mul(multiplier)); //第一天乘全月日數, 以後每減1日
            m_outcome = m_outcome.add(outcome.mul(multiplier));
            t_inject = t_inject.add(inject);
            t_outcome = t_outcome.add(outcome);
        }
        m_outcome=m_outcome.add(_mv); 
        t_inject=t_inject.mul(dInM);
        t_outcome=t_outcome.mul(dInM);
        uint r = m_outcome.sub(m_inject);
        uint t=t_outcome.sub(t_inject);
        r = t.mul(100).div(r);
        return (r, dInM);
 	}
 	//複製下單資訊
 	function createCopy(uint amount, bytes32 hashvalue, bool signal, address addrCopyTrader, uint id) onlyHolder public returns(bool){
		// trading = true, start copy; trading = false, end copy
        require(msg.sender==addrProxyOwner || msg.sender==addrProxy);
                
		bytes32 _hashvalue=strategy.hashStrategy;
		require ((hashvalue == _hashvalue), 'the strategy is wrong');
		Commit memory hasOnGoingCommit = commit[addrCopyTrader][id];
		uint numCopies=hasOnGoingCommit.numCopies;
		copyReceipt memory _copyTrades = copyTrades[addrCopyTrader][id][numCopies];
		uint256	residual = hasOnGoingCommit.commitReturn;
		residual = residual.sub(hasOnGoingCommit.usedAmount);
		
		if (signal) {										//買
			require (residual >= amount); //剩餘可用投資 >= 本次下單金額
	    	hasOnGoingCommit.usedAmount = hasOnGoingCommit.usedAmount.add(amount); 
			_copyTrades.time = now;
			_copyTrades.Amount = amount;	//本次買入金額
			hasOnGoingCommit.commitReturn = hasOnGoingCommit.commitReturn.sub(amount);  		//投資金額減少 amount 數
		} else {	//賣
			hasOnGoingCommit.usedAmount = hasOnGoingCommit.usedAmount.sub(amount); 
			_copyTrades.time = now;
			_copyTrades.Amount = _copyTrades.Amount.sub(amount); //負數為賣出金額
			hasOnGoingCommit.commitReturn = hasOnGoingCommit.commitReturn.add(amount);		//投資金額增加 amount 數
		}
        hasOnGoingCommit.numCopies = hasOnGoingCommit.numCopies.add(1);
        commit[addrCopyTrader][id] = hasOnGoingCommit;
        copyTrades[addrCopyTrader][id][numCopies].time = _copyTrades.time;
        copyTrades[addrCopyTrader][id][numCopies].Amount = _copyTrades.Amount;
	    emit eventCopy(commitId[addrCopyTrader], addrCopyTrader, amount, signal, _copyTrades.time);

	    return true;
	}
	//結束跟單, _addr為跟單人位址, _id為跟單人的跟單序號
	function copyEnd (address _addr, uint _id) internal  returns (bool){
        require(msg.sender==addrProxyOwner || msg.sender==addrProxy);
		Commit memory hasOnGoingCommit = commit[_addr][_id];
		uint numCopies=hasOnGoingCommit.numCopies;
		copyReceipt memory _copyTrades = copyTrades[_addr][_id][numCopies];
		
	    require(hasOnGoingCommit.boolCommit);
		_copyTrades.time=now;
		_copyTrades.Amount = 0;
        copyTrades[_addr][_id][numCopies].time = _copyTrades.time;
        copyTrades[_addr][_id][numCopies].Amount = _copyTrades.Amount;
		emit eventCloseCopy(numCopies, _copyTrades.time);
		return true;
	}
//-------移除
    function getStrategy() onlyOwner public view returns (Strategy memory){
        return strategy;
    
    }
    function getNumCommits() onlyOwner public view returns (uint){
    	return numCommits;
    }
    
    function getCommitId(address addr) onlyOwner public view returns (uint){
        uint r=commitId[addr];
        return r;
    }
//--------
    /*
    function getCommit(address addr, uint id) onlyOwner public view returns (Commit memory, copyReceipt memory) {
            
        Commit memory h=commit[addr][id];
        uint numCopies = h.numCopies;
        copyReceipt memory c=copyTrades[addr][id][numCopies];
        return (h,c);
    }
    */
    //---------可能要改成以下,stack too deep,只好把otherData砍掉
    function getCommit(address addr, uint id) onlyOwner public view returns (bool boolCommit,uint startTime,uint endTime,uint commitAmount,uint commitFees,uint usedAmount,uint commitReturn,uint totalReturn,uint numCopies,uint time,uint Amount) {
        address addr1=addr;
        uint id1=id;
        
        Commit memory h=commit[addr1][id1];
        
        
        uint numCopies = h.numCopies;
        copyReceipt memory c=copyTrades[addr1][id1][numCopies];
        return (h.boolCommit,h.startTime,h.endTime,h.commitAmount,h.commitFees,h.usedAmount,h.commitReturn,h.totalReturn,h.numCopies,c.time,c.Amount);
    }
    //-------移除
    function getReceipt(address addr, uint id, uint numCopies) onlyOwner public view returns (copyReceipt memory){
        return copyTrades[addr][id][numCopies];
    }
    //-------
  
    function getAllReceipts(address _addr, uint _id, uint _numCopies) onlyOwner public view returns (copyReceipt[] memory){
    
        copyReceipt[] memory h;
        for (uint i = 1; i < _numCopies.add(1); i++) {
            h[i] = getReceipt(_addr, _id, i);
        }
        return h;
    }
    
	//fallback function
	function() external payable {
	    emit eventFallbackTrigged(msg.data);
	}
	
	function kill() public onlyOwner {
        selfdestruct(address(uint160(addrProxyOwner)));
    }
    
 }