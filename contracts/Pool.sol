// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./LIToken.sol";
import "hardhat/console.sol";

contract Pool is IERC20, LIToken {
    LIToken public lpToken;
    fallback() external payable {}
    receive() external payable {}
    address public erc20TokenAddress;
    mapping(address => uint256) WethMapping;
    event tokenSwap(address indexed token, address indexed swapper, string indexed swap, uint256 _amount);
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

function addLiquidity (uint _amount, address _sender) public payable returns (address, uint256, uint256, uint256, address, uint256, uint256) {
    uint256 _ethReserve = address(this).balance - msg.value;
    if(getReserve() == 0){
        lpToken.mint(_sender, _amount);
        IERC20(erc20TokenAddress).transferFrom(_sender, address(this), _amount);
        return (_sender, lpToken._totalSupply(), getReserve(), address(this).balance, address(lpToken), lpToken._balanceOf(_sender), getReserve());
    }else{

    require(_amount >= (msg.value * getReserve()) / (_ethReserve), "not accepted liquidity less then the minimum amount accepted");
    IERC20(erc20TokenAddress).transferFrom(_sender, address(this), (msg.value * getReserve()) / (_ethReserve));
    lpToken.mint(_sender, (lpToken._totalSupply() * msg.value) / (_ethReserve));    

    return (_sender, lpToken._totalSupply(), (lpToken._totalSupply() * msg.value) / (_ethReserve), address(this).balance, address(lpToken), lpToken._balanceOf(_sender), getReserve());
    }
}
    function removeLiquidity(uint _amount, address _sender) public payable returns (address, uint256, uint256, uint256, address, uint256, uint256) {
        uint256 lpTokenBalance = lpToken._balanceOf(_sender);
        require(_amount >= 0, "small amount");  
        lpToken.burn(_sender, _amount);
        IERC20(erc20TokenAddress).approve(address(this), (IERC20(erc20TokenAddress).balanceOf(address(this)) * _amount) / lpToken._totalSupply());
        IERC20(erc20TokenAddress).transferFrom(address(this), _sender, (IERC20(erc20TokenAddress).balanceOf(address(this)) * _amount) / lpToken._totalSupply());
        (bool call, bytes memory data) = _sender.call{value: address(this).balance * _amount / lpToken._totalSupply()}("");
        require(call, "Failed to send Ether");
        return (_sender, lpToken._totalSupply(), _amount, address(this).balance, address(lpToken),  lpTokenBalance, getReserve());
    }

    function getSwapTokenToEth(uint256 _amount) public payable returns (uint256){
        uint256 erc20Reserve = getReserve();
        uint256 ethReserve = address(this).balance + msg.value;
        uint256 inputAmountFee = _amount * 99;
        uint256 fullErc20Reserve = erc20Reserve * 100;
        require(erc20Reserve > 0 && ethReserve > 0, "invalid reserve");
        uint256 outputAmount = (inputAmountFee * ethReserve) / (inputAmountFee + fullErc20Reserve);
        emit balanceCall(outputAmount, fullErc20Reserve);
        return outputAmount;
    }

    function getSwapEthToToken(uint256 _amount) public payable returns (uint256){
        uint256 erc20Reserve = getReserve();
        uint256 ethReserve = address(this).balance;
        uint256 inputAmountFee = _amount * 99;
        uint256 fullEthReserve = ethReserve * 100;
        require(ethReserve > 0 && erc20Reserve > 0, "invalide reserve amount");
        uint256 outputAmount = (inputAmountFee * erc20Reserve) / (inputAmountFee + fullEthReserve);
        emit balanceCall(_amount, outputAmount);
        return outputAmount;
    }

    function swapEthToToken(uint256 _estimateamount, address _sender) public payable{
        uint256 erc20Reserve = getReserve();
        uint256 ethReserve = address(this).balance - msg.value;
        uint256 inputAmountFee = msg.value * 99;
        uint256 fullEthReserve = ethReserve * 100;
        require(ethReserve > 0 && erc20Reserve > 0, "invalide reserve amount");
        uint256 outputAmount = (inputAmountFee * erc20Reserve) / (inputAmountFee + fullEthReserve);
        IERC20(erc20TokenAddress).approve(address(this), _estimateamount);
        IERC20(erc20TokenAddress).transferFrom(address(this), _sender, _estimateamount);
    }
 
    function swapTokenToEth(uint256 _ethBackToUser ,address _sender) public payable{

        uint256 erc20Reserve = getReserve();
        uint256 ethReserve = address(this).balance;
        uint256 inputAmountFee = msg.value * 99;
        uint256 fullErc20Reserve = erc20Reserve * 100;
        require(erc20Reserve > 0 && ethReserve > 0, "invalide reserve amount");
        uint256 outputAmount = (inputAmountFee * ethReserve) / (inputAmountFee + fullErc20Reserve);
        require(outputAmount >= _ethBackToUser, "to little amount for swapping");

        IERC20(erc20TokenAddress).approve(_sender, _ethBackToUser);
        IERC20(erc20TokenAddress).transferFrom(_sender, address(this), _ethBackToUser);
        (bool call, bytes memory data) = _sender.call{value: outputAmount}("");
        require(call, "Failed to send Ether");
    }    
}

