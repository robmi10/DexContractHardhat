// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./LiquidityToken.sol";

//Skapa den här kontrakten som en pool istället och den här poolen har alltså sin egna address.
//Poolen ska därefter kunna kallas från en annan Kontrakt som ska vara själva Dex och ta hand om varje pool som exisiterar.
//Därför gör om denna kontrakt så att den är kopplad till eth msg.value() istället för "weth" sen skapa den riktiga Dex "manage" kontrakten.
//I Dex kontraktet spara alla olika pools i en mapping och kalla deras funktioner med hjälp av en 

contract Pool is IERC20, LiquidityToken {
    LiquidityToken public lpToken;

    fallback() external payable {}
    receive() external payable {}

    address public erc20TokenAddress;
    mapping(address => uint256) WethMapping;
    event tokenSwap(address indexed token, address indexed swapper, string indexed swap, uint256 _amount);
    //event liquidityPool( uint256 indexed amount, address indexed provider, uint256 indexed reserve);
    //event liquidityWidthdraw( uint256 indexed _amount, address indexed _to);
    //event addressBalance(address indexed token, uint256 indexed _amount, address indexed _address);
    event balancesCheck(uint256 indexed totalSupply, uint256 indexed ethBalance, uint256 indexed ethBackToUser, uint256 liquidityBackToUser);
    event balanceCall(uint256 indexed _amount, uint256 indexed _secondamount);
  //  event userInPoolAddress(address indexed _caller);
    //event transferSwap(uint256 _amount, bytes data, bool call);

    constructor(address _erc20TokenAddress) {
        require(_erc20TokenAddress != address(0));
        erc20TokenAddress = _erc20TokenAddress;
        lpToken = new LiquidityToken();
    }

    function getReserve() public payable returns(uint256) {
        uint256 balaceGet = IERC20(erc20TokenAddress).balanceOf(address(this));
       // emit balanceCall(balaceGet);
        return balaceGet;
    }
    /*function getEthReserve() public payable returns(uint256) {
        uint256 balaceGet = address(this).balance;
        emit balanceCall(balaceGet);
        return address(this).balance;
    }
    function getAddress() public payable returns (address){
        return erc20TokenAddress;
    }
    function getLiquidityAddress() public payable returns (address){
        return address(lpToken);
    }*/

    function addLiquidity (uint _amount, address _sender) public payable{
        uint256 daiReserve = getReserve();
        
        if(daiReserve == 0){
            lpToken.mint(_sender, _amount);
            IERC20(erc20TokenAddress).transferFrom(_sender, address(this), _amount);
           // emit liquidityPool( _amount, _sender, 1);
        }else{
        uint256 _ethReserve = address(this).balance - msg.value;
        uint256 acceptedLiquidityAmount = (msg.value * daiReserve) / (_ethReserve);
        require(_amount >= acceptedLiquidityAmount, "not accepted liquidity less then the minimum amount accepted");
        /*IERC20(erc20TokenAddress).approve(address(this), acceptedLiquidityAmount);*/
        IERC20(erc20TokenAddress).transferFrom(_sender, address(this), acceptedLiquidityAmount);
        uint256 mintokens = (lpToken._totalSupply() * msg.value) / (_ethReserve);
        lpToken.mint(_sender, _amount);
       // emit liquidityPool( mintokens, _sender, 2);
        emit balancesCheck(mintokens, acceptedLiquidityAmount, _ethReserve, msg.value);
        // emit liquidityPool(10, _sender, 2);
        }
    }
    // remove liquidity
    function removeLiquidity(uint _amount, address _sender) public {
        require(_amount >= 0, "to little amount");  
        uint256 ethReserve = address(this).balance;
        uint256 totalSupply = lpToken._totalSupply();
        uint256 erc20TokenReserve = IERC20(erc20TokenAddress).balanceOf(address(this));
        uint256 ethBackToUser = (ethReserve * _amount) / totalSupply;
        uint256 ldtokenBackToUser = (erc20TokenReserve * _amount) / totalSupply;
        lpToken.burn(_sender, _amount);
        IERC20(erc20TokenAddress).approve(address(this), ldtokenBackToUser);
        IERC20(erc20TokenAddress).transferFrom(address(this), _sender, ldtokenBackToUser);
        (bool call, bytes memory data) = _sender.call{value: ethBackToUser}("");
       
       // emit liquidityPool(_amount, _sender, ldtokenBackToUser);
        emit balancesCheck (totalSupply, ethReserve ,ethBackToUser, ldtokenBackToUser);
    }
   

     function getSwapAmountEth(uint256 _amount) public payable returns (uint256){
        uint256 erc20Reserve = getReserve();
        uint256 ethReserve = address(this).balance - _amount;
        uint256 inputAmountFee = _amount * 99;
        uint256 fullEthReserve = ethReserve * 100;

        require(ethReserve > 0 && erc20Reserve > 0, "invalide reserve amount");
        uint256 outputAmount = (inputAmountFee * erc20Reserve) / (_amount + fullEthReserve);
       // emit balancesCheck (ethReserve, _amount ,inputAmountFee, outputAmount);
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
        //emit balancesCheck (ethReserve, erc20Reserve ,inputAmountFee, outputAmount);
        emit balanceCall(outputAmount, fullErc20Reserve);
        return outputAmount;
    }

    function swapEthToToken(uint256 _amount, address _sender) public payable{
        uint256 erc20Reserve = getReserve();
        uint256 ethReserve = address(this).balance - msg.value;
        uint256 inputAmountFee = msg.value * 99;
        uint256 fullEthReserve = ethReserve * 100;
        require(ethReserve > 0 && erc20Reserve > 0, "invalide reserve amount");
        uint256 outputAmount = (inputAmountFee * erc20Reserve) / (msg.value + fullEthReserve);
        //uint256 totalAmountwithfee = (outputAmount * 99) / 100;
        require(outputAmount >= _amount, "to little amount for swapping");
        IERC20(erc20TokenAddress).approve(address(this), outputAmount);
        IERC20(erc20TokenAddress).transferFrom(address(this), _sender, outputAmount);
        emit tokenSwap(erc20TokenAddress, _sender, "eth/token", outputAmount);
    }

    function swapTokenToEth(uint256 _amount, uint256 _ethBackToUser ,address _sender) public payable{
        uint256 erc20Reserve = getReserve();
        uint256 ethReserve = address(this).balance;
        uint256 inputAmountFee = _amount * 99;
        uint256 fullErc20Reserve = erc20Reserve * 100;
        require(erc20Reserve > 0 && ethReserve > 0, "invalide reserve amount");
        uint256 outputAmount = (inputAmountFee * ethReserve) / (_amount + fullErc20Reserve);
        //uint256 totalAmountwithfee = (outputAmount * 99) / 100;
        require(outputAmount >= _ethBackToUser, "to little amount for swapping");
        IERC20(erc20TokenAddress).approve(_sender, outputAmount);
        IERC20(erc20TokenAddress).transferFrom(_sender, address(this), outputAmount);
        (bool call, bytes memory data) = _sender.call{value: outputAmount}("");
        //emit transferSwap(outputAmount, data, call);
        emit tokenSwap(erc20TokenAddress, _sender, "token/eth", outputAmount);
        emit balancesCheck (ethReserve, fullErc20Reserve ,inputAmountFee, outputAmount);
    }
}
