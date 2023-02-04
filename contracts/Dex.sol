// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./Pool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Dex {
    Pool public  pool;
    event userAddress (address indexed _useraddress);
    event createPoolEvent (address indexed _createBy, address indexed _token ,uint256 indexed _id);
    event liquidity (address indexed _from, uint256 indexed _lpTokenSupply, uint256 indexed _mintedAmount, uint256 _ethBalance, address _lpTokenAddress, uint256 _amount, uint256 _lpTokenBalance, uint256 _tokenReserve);
    event liquidityRemove (address indexed _from, uint256 indexed _lpTokenSupply, uint256 indexed _mintedAmount, uint256 _ethBalance, address _lpTokenAddress, uint256 _amount, uint256 _lpTokenBalance, uint256 _tokenReserve );
    event outputAmountCheck (uint256 outputamount);
    mapping (uint256 => Pool) public PoolMapping;
    uint256 public counter;
    constructor () payable{}

     function getPoolAddress(uint256 _pool) public view returns(address){
        return address(PoolMapping[_pool]);
    }

    function createPool(address tokenA) public payable {
        pool = new Pool(tokenA);
        PoolMapping[counter] = pool;
        emit createPoolEvent(msg.sender, address(pool), counter);
        emit userAddress (address(pool));
        counter += 1;
    }

    function _addLiquidity(uint256 _pool, uint256 _amount) public payable {
        require(_amount >= msg.value, "to little amount");
        pool =  Pool(payable(address(PoolMapping[_pool])));
        (address from, uint256 lpTotalSupply, uint256 _estimatedAmount, uint256 _ethReserve,  address lpTokenAddress, uint256 _lpTokenBalance, uint256 _daiReserve) = pool.addLiquidity{ value: msg.value }(_amount, msg.sender);
        emit liquidity(from, lpTotalSupply, _estimatedAmount, _ethReserve, lpTokenAddress, _amount, _lpTokenBalance, _daiReserve);
    }

    function _removeLiquidity(uint256 _pool, uint256 _amount) public payable{
        pool = Pool(payable(address(PoolMapping[_pool]))); 
        (address from, uint256 lpTotalSupply, uint256 _estimatedAmount, uint256 _ethReserve,  address lpTokenAddress, uint256 _lpTokenBalance, uint256 _daiReserve) = pool.removeLiquidity(_amount, msg.sender);
        emit liquidityRemove(from, lpTotalSupply, _estimatedAmount, _ethReserve, lpTokenAddress, _amount, _lpTokenBalance, _daiReserve);
    }

    function _swapTokenToEth(uint256 _pool, uint256 _estimatedAmount, address _account) public payable{
        pool = Pool(payable(address(PoolMapping[_pool])));
        pool.swapTokenToEth{ value: msg.value }(_estimatedAmount, _account);
    }

    function _swapEthToToken(uint256 _pool,  uint256 _estimateamount) public payable{
         pool = Pool(payable(address(PoolMapping[_pool])));
         pool.swapEthToToken{ value: msg.value }( _estimateamount, msg.sender);
    }
    
    function _getSwapTokenToEth(uint256 _pool, uint256 _amount)  public payable returns (uint256){
        pool = Pool(payable(address(PoolMapping[_pool])));
        (uint256 swapamount) = pool.getSwapTokenToEth{ value: msg.value }(_amount);
        emit outputAmountCheck(swapamount);
        return swapamount;
    }

    function _getSwapEthToToken(uint256 _pool, uint256 _amount)  public payable returns (uint256){
        pool = Pool(payable(address(PoolMapping[_pool])));
        (uint256 swapamount) = pool.getSwapEthToToken{ value: msg.value }(_amount);
         emit outputAmountCheck(swapamount);
        return swapamount;
    }
}
