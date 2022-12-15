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
    address public lpTokenAddress;
    address public erc20TokenAddress;
    mapping(address => uint256) WethMapping;
    event tokenSwap(address indexed token, address indexed swapper, string indexed swap);
    event liquidityPool( uint256 indexed amount, address indexed provider);
    event liquidityWidthdraw( uint256 indexed _amount, address indexed _to);
    event addressBalance(address indexed token, uint256 indexed _amount, address indexed _address);
    event balanceCall( uint256 indexed _amount);
    event userInPoolAddress(address indexed _caller);

    constructor(address _lpToken, address _erc20TokenAddress) {
        require(_lpToken != address(0));
        lpTokenAddress = _lpToken;
        erc20TokenAddress = _erc20TokenAddress;
    }

    function getReserve() public payable returns(uint256) {
        uint256 balaceGet = IERC20(erc20TokenAddress).balanceOf(address(this));
        emit balanceCall(balaceGet);
        return balaceGet;
    }

     function getEthReserve() public payable returns(uint256) {
        uint256 balaceGet = address(this).balance;
        emit balanceCall(balaceGet);
        return address(this).balance;
    }

    function getAddress() public payable returns (address){
        return erc20TokenAddress;
    }

     function getNumber() public payable returns (uint256){
        return 420;
    }

    function getMessage() public payable returns (string memory){
        return "Hejsaaaan!";
    }
 
    function addLiquidity (uint _amount, address _sender) public payable{
        uint256 daiReserve = getReserve();
        uint256 ethReserve = address(this).balance;
        emit userInPoolAddress(msg.sender);
        if(daiReserve == 0){
            IERC20(erc20TokenAddress).transferFrom(_sender, address(this), _amount);
            _mint(_sender, ethReserve);
            emit liquidityPool( _amount, _sender);
        }else{
        uint256 _ethReserve = address(this).balance - msg.value;
        uint256 acceptedLiquidityAmount = (_amount * daiReserve) / (_ethReserve);
        require(_amount >= acceptedLiquidityAmount, "not accepted liquidity less then the minimum amount accepted");
        IERC20(erc20TokenAddress).transferFrom(msg.sender, address(this), acceptedLiquidityAmount);

        uint256 mintokens = (IERC20(erc20TokenAddress).totalSupply() * msg.value) / (_ethReserve);
        _mint(msg.sender, mintokens);
        emit liquidityPool( _amount, msg.sender);
        }
    }
    // remove liquidity
    function removeLiquidity(uint _amount) public {
        require(_amount >= 0, "to little amount");
        uint256 ethReserve = address(this).balance;
        uint256 totalSupply = IERC20(erc20TokenAddress).totalSupply();
        uint256 erc20TokenReserve = IERC20(erc20TokenAddress).balanceOf(address(this));
        uint256 ethBackToUser = (ethReserve * _amount) / totalSupply;
        uint256 ldtokenBackToUser = (erc20TokenReserve * _amount) / totalSupply;
        _burn(msg.sender, _amount);
        IERC20(erc20TokenAddress).approve(address(this), ldtokenBackToUser);
        IERC20(erc20TokenAddress).transferFrom(address(this), msg.sender, ldtokenBackToUser);
        (bool call, bytes memory data) = msg.sender.call{value: ethBackToUser}("");
        emit liquidityWidthdraw(_amount, msg.sender);
    }


    function swapEthToToken(uint256 _amount) public payable{
        uint256 erc20Reserve = getReserve();
        uint256 ethReserve = address(this).balance;

        require(ethReserve > 0 && erc20Reserve > 0, "invalide reserve amount");
        uint256 outputAmount = (_amount * erc20Reserve) / (_amount + ethReserve);
        uint256 totalAmountwithfee = (outputAmount * 99) / 100;

        require(_amount >= totalAmountwithfee, "to little amount for swapping");
        IERC20(erc20TokenAddress).approve(address(this), totalAmountwithfee);
        IERC20(erc20TokenAddress).transferFrom(address(this), msg.sender, totalAmountwithfee);
        emit tokenSwap(erc20TokenAddress, msg.sender, "eth/token");
    }

       function swapTokenToEth(uint256 _amount) public payable{
        uint256 erc20Reserve = getReserve();
        uint256 ethReserve = address(this).balance;

        require(erc20Reserve > 0 && ethReserve > 0, "invalide reserve amount");

        uint256 outputAmount = (_amount * ethReserve) / (_amount + erc20Reserve);
        uint256 totalAmountwithfee = (outputAmount * 99) / 100;

        require(_amount >= totalAmountwithfee, "to little amount for swapping");

        (bool call, bytes memory data) = msg.sender.call{value: totalAmountwithfee}("");

        emit tokenSwap(erc20TokenAddress, msg.sender, "token/eth");
    }
}

