// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./LIToken.sol";

//Skapa den här kontrakten som en pool istället och den här poolen har alltså sin egna address.
//Poolen ska därefter kunna kallas från en annan Kontrakt som ska vara själva Dex och ta hand om varje pool som exisiterar.
//Därför gör om denna kontrakt så att den är kopplad till eth msg.value() istället för "weth" sen skapa den riktiga Dex "manage" kontrakten.
//I Dex kontraktet spara alla olika pools i en mapping och kalla deras funktioner med hjälp av en 

contract Pool is IERC20, LIToken {
    LIToken public lpToken;

    fallback() external payable {}
    receive() external payable {}

    address public erc20TokenAddress;
    mapping(address => uint256) WethMapping;
    event tokenSwap(address indexed token, address indexed swapper, string indexed swap, uint256 _amount);
    event liquidityPool( uint256 indexed amount, address indexed provider, uint256 indexed reserve);

    event balancesCheck(address _from, uint256 indexed totalSupply, uint256 indexed ethBalance, uint256 indexed ethBackToUser, uint256 liquidityBackToUser);
    event balanceCall(uint256 indexed _amount, uint256 indexed _secondamount);


    constructor(address _erc20TokenAddress) {
        require(_erc20TokenAddress != address(0));
        erc20TokenAddress = _erc20TokenAddress;
        lpToken = new LIToken();
    }

    function getReserve() public payable returns(uint256) {
        uint256 balaceGet = IERC20(erc20TokenAddress).balanceOf(address(this));
        return balaceGet;
    }

     function getEthReserve() public payable returns(uint256) {
        return address(this).balance;
    }

     function getinputAmountFee(uint256 _amount) public payable returns(uint256) {
        uint256 inputAmountFee = _amount * 99;
        return inputAmountFee;
    }

    function getfullEthReserve() public payable returns(uint256) {
        uint256 fullEthReserve = getEthReserve() * 100;
        return fullEthReserve;
       
    }

     function getLiquidityStatus(uint _amount) public payable returns(uint256, uint256) {
         uint256 _ethReserve = address(this).balance - _amount;
        uint256 amountStatus = (_amount * getReserve()) / (_ethReserve);
        return (amountStatus, _amount);   
    }

function addLiquidity (uint _amount, address _sender) public payable returns (address, uint256, uint256, uint256, address, uint256, uint256) {
    uint256 _ethReserve = address(this).balance - msg.value;
    if(getReserve() == 0){
        lpToken.mint(_sender, _amount);
        IERC20(erc20TokenAddress).transferFrom(_sender, address(this), _amount);
        return (_sender, lpToken._totalSupply(), getReserve(), address(this).balance, address(lpToken), lpToken._balanceOf(_sender), getReserve());
    }else{

    require(_amount >= (msg.value * getReserve()) / (_ethReserve), "not accepted liquidity less then the minimum amount accepted");
    /*IERC20(erc20TokenAddress).approve(address(this), acceptedLiquidityAmount);*/
    IERC20(erc20TokenAddress).transferFrom(_sender, address(this), (msg.value * getReserve()) / (_ethReserve));
    
    lpToken.mint(_sender, (lpToken._totalSupply() * msg.value) / (_ethReserve));    
    // emit balancesCheck(_sender, _amount, acceptedLiquidityAmount, _ethReserve, msg.value);

    return (_sender, lpToken._totalSupply(), (lpToken._totalSupply() * msg.value) / (_ethReserve), address(this).balance, address(lpToken), lpToken._balanceOf(_sender), getReserve());
    }
}
    // remove liquidity
    function removeLiquidity(uint _amount, address _sender) public payable returns (address, uint256, uint256, uint256, address, uint256, uint256) {
        require(_amount >= 0, "small amount");  
        lpToken.burn(_sender, _amount);
        IERC20(erc20TokenAddress).approve(address(this), (IERC20(erc20TokenAddress).balanceOf(address(this)) * _amount) / lpToken._totalSupply());
        IERC20(erc20TokenAddress).transferFrom(address(this), _sender, (IERC20(erc20TokenAddress).balanceOf(address(this)) * _amount) / lpToken._totalSupply());
        _sender.call{value: address(this).balance * _amount / lpToken._totalSupply()}("");
        return (_sender, lpToken._totalSupply(), _amount, address(this).balance, address(lpToken),  lpToken._balanceOf(_sender), getReserve());
    }

    function getSwapAmountEth(uint256 _amount) public payable returns (uint256){
        uint256 erc20Reserve = getReserve();
        uint256 ethReserve = address(this).balance - _amount;
        uint256 inputAmountFee = _amount * 99;
        uint256 fullEthReserve = ethReserve * 100;
        require(ethReserve > 0 && erc20Reserve > 0, "invalide reserve amount");
        uint256 outputAmount = (inputAmountFee * erc20Reserve) / (_amount + fullEthReserve);
        emit balanceCall(_amount, outputAmount);
        return outputAmount;
    }


    function getSwapAmountDai(uint256 _amount) public returns (uint256){
        uint256 erc20Reserve = getReserve();
        uint256 ethReserve = address(this).balance;
        uint256 inputAmountFee = _amount * 99;
        uint256 fullErc20Reserve = erc20Reserve * 100;
        require(erc20Reserve > 0 && ethReserve > 0, "invalide reserve amount");
        uint256 outputAmount = (inputAmountFee * ethReserve) / (_amount + fullErc20Reserve);


        // uint256 erc20Reserve = getReserve();
        // uint256 ethReserve = address(this).balance - msg.value;
        // uint256 inputAmountFee = msg.value * 99;
        // uint256 fullEthReserve = ethReserve * 100;
        // require(ethReserve > 0 && erc20Reserve > 0, "invalide reserve amount");
        // uint256 outputAmount = (inputAmountFee * erc20Reserve) / (msg.value + fullEthReserve);



        //emit balancesCheck (ethReserve, erc20Reserve ,inputAmountFee, outputAmount);
        emit balanceCall(outputAmount, fullErc20Reserve);
        return outputAmount;
    }


    function getSwapAmountEthSecond(uint256 _amount) public payable returns (uint256, uint256){
        uint256 erc20Reserve = getReserve();
        uint256 ethReserve = address(this).balance - _amount;
        uint256 inputAmountFee = _amount * 99;
        uint256 fullEthReserve = ethReserve * 100;

        require(ethReserve > 0 && erc20Reserve > 0, "invalide reserve amount");
        uint256 outputAmount = (inputAmountFee * erc20Reserve) / (_amount + fullEthReserve);
        // require(outputAmount >= _amount, "to little toEth for swapping");
        emit balanceCall(_amount, outputAmount);
        return (outputAmount, _amount);
    }

    function swapEthToToken(uint256 _amount, uint256 _estimateamount, address _sender) public payable{
        uint256 erc20Reserve = getReserve();
        uint256 ethReserve = address(this).balance - msg.value;
        uint256 inputAmountFee = msg.value * 99;
        uint256 fullEthReserve = ethReserve * 100;
        require(ethReserve > 0 && erc20Reserve > 0, "invalide reserve amount");
        uint256 outputAmount = (inputAmountFee * erc20Reserve) / (msg.value + fullEthReserve);
        //uint256 totalAmountwithfee = (outputAmount * 99) / 100;
        // require(outputAmount >= _amount, "to little amount for swapEthToToken");
        IERC20(erc20TokenAddress).approve(address(this), _estimateamount);
        IERC20(erc20TokenAddress).transferFrom(address(this), _sender, _estimateamount);
        emit tokenSwap(erc20TokenAddress, _sender, "eth/token", _amount);
    }
 
    function swapTokenToEth(uint256 _amount, uint256 _ethBackToUser ,address _sender) public payable{
        uint256 erc20Reserve = getReserve();
        uint256 ethReserve = address(this).balance;
        uint256 inputAmountFee = msg.value * 99;
        uint256 fullErc20Reserve = erc20Reserve * 100;
        require(erc20Reserve > 0 && ethReserve > 0, "invalide reserve amount");
        uint256 outputAmount = (inputAmountFee * ethReserve) / (msg.value + fullErc20Reserve);
        //uint256 totalAmountwithfee = (outputAmount * 99) / 100;
        require(outputAmount >= _ethBackToUser, "to little amount for swapping");
        IERC20(erc20TokenAddress).approve(_sender, msg.value);
        IERC20(erc20TokenAddress).transferFrom(_sender, address(this), msg.value);
        (bool call, bytes memory data) = _sender.call{value: _ethBackToUser}("");
        //emit transferSwap(outputAmount, data, call);
        emit tokenSwap(erc20TokenAddress, _sender, "token/eth", outputAmount);
        emit balancesCheck (_sender, ethReserve, fullErc20Reserve ,inputAmountFee, outputAmount);
    }


    
}

