// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./LP.sol";

contract Dex is IERC20, LiquidityToken {
    LiquidityToken public lpToken;
    address public lpTokenAddress;
    event tokenSwap(address indexed fromToken, address indexed toToken, address indexed swapper);
    event liquidityPool( uint256 indexed amount, address indexed provider);
    event liquidityWidthdraw( uint256 indexed _amount, address indexed _to);
    constructor(address _lpToken) {
        require(_lpToken != address(0));
        lpTokenAddress = _lpToken;
    }

    function getReserve(address _token) private view returns(uint256) {
        return IERC20(_token).balanceOf(address(this));
    }

    function addLiquidity (uint _amount, address _firstReserve, address _secondReserve, address _liquidityToken) public {
        uint256 firstReserve = getReserve(_firstReserve);
        uint256 secondReserve = getReserve(_secondReserve);
        if(firstReserve == 0){
            IERC20(_firstReserve).transferFrom(msg.sender, address(this), _amount);
            _mint(msg.sender, secondReserve);
            emit liquidityPool( _amount, msg.sender);
        }else{
        uint256 acceptedLiquidityAmount = (_amount * firstReserve) / secondReserve;
        require(_amount >= acceptedLiquidityAmount, "not accepted liquidity less then the minimum amount accepted");
        IERC20(_liquidityToken).transferFrom(msg.sender, address(this), acceptedLiquidityAmount);
        _mint(msg.sender, acceptedLiquidityAmount);
        emit liquidityPool( _amount, msg.sender);
        }
    }
    // remove liquidity
    function removeLiquidity(uint _amount, address _liquidityToken, address _firstReserve, address _secondReserve) public {
        uint256 firstReserve = getReserve(_firstReserve);
        uint256 totalSupply = IERC20(_liquidityToken).totalSupply();
        uint256 secondSupply = IERC20(_secondReserve).totalSupply();
        require(_amount >= 0, "to little amount");
        uint256 firstReserveTokenBackToUser = (firstReserve * _amount) / totalSupply;
        uint256 secondReserveBackToUser = (secondSupply * _amount) / totalSupply;
        _burn(msg.sender, _amount);
        IERC20(_firstReserve).transferFrom(address(this), msg.sender, firstReserveTokenBackToUser);
        IERC20(_secondReserve).transferFrom(address(this), msg.sender, secondReserveBackToUser);
        emit liquidityWidthdraw(_amount, msg.sender);
    }
    

    function swap(uint256 _amount, address _fromToken, address _toToken) public payable{
        uint256 fromReserve = getReserve(_fromToken);
        uint256 toReserve = getReserve(_toToken);
        uint256 outputAmount = (_amount * toReserve) / (_amount + fromReserve);
        uint256 fee = (outputAmount * 99) / 100;
        
        require(_amount >= outputAmount, "to little amount for swapping");
        IERC20(_fromToken).transferFrom(msg.sender, address(this), fee);
        IERC20(_toToken).approve(address(this), msg.value);
        IERC20(_toToken).transferFrom(address(this), msg.sender, outputAmount);
        emit tokenSwap(_fromToken, _toToken, msg.sender);
    }
}