// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./Pool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Dex {
    Pool public  pool;
    
    event userAddress (address indexed _useraddress);
    event createPoolEvent (address indexed _createBy, address indexed _token ,uint256 indexed _id);
    event liquidity (address indexed _from, uint256 indexed _ldSupply, uint256 indexed _mintedAmount, uint256 _eth, uint256 _lpTokenBalance, uint256 _amount);
    event liquidityRemove (address indexed _from, uint256 indexed _ldSupply, uint256 indexed _tokenBack, uint256 _ethBack, uint256 _lpTokenBalance, uint256 _amount );
    event test (uint256 indexed _first, uint256 indexed _second);
    mapping (uint256 => Pool) public PoolMapping;
    mapping (uint256 => address) public PoolMappingAddress;
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

    //   function _test(uint256 _pool, uint256 _amount) public payable {
    //     // require(_amount >= msg.value, "to little amount");
    //     // pool =  Pool(payable(address(PoolMapping[_pool])));
    //     // emit userAddress(address(pool));
    //     // (address from, uint256 lpTotalSupply, uint256 _estimatedAmount, uint256 lpTokenBalance,  uint256 _ethReserve) = pool.addLiquidity{ value: msg.value }(_amount, msg.sender);
    //     // emit liquidity(from, lpTotalSupply, _estimatedAmount, _ethReserve, lpTokenBalance, _amount);
    //     emit test(_pool, _amount);
    // }
    
    function _addLiquidity(uint256 _pool, uint256 _amount) public payable {
        require(_amount >= msg.value, "to little amount");
        pool =  Pool(payable(address(PoolMapping[_pool])));
        (address from, uint256 lpTotalSupply, uint256 _estimatedAmount, uint256 lpTokenBalance,  uint256 _ethReserve) = pool.addLiquidity{ value: msg.value }(_amount, msg.sender);
        emit liquidity(from, lpTotalSupply, _estimatedAmount, _ethReserve, lpTokenBalance, _amount);
    }

    function _removeLiquidity(uint256 _pool, uint256 _amount) public payable{
        pool = Pool(payable(address(PoolMapping[_pool]))); 
        (address from, uint256 lpTotalSupply, uint256 lptokenReturned, uint256 ethReturned, uint256 lpTokenBalance) = pool.removeLiquidity(_amount, msg.sender);
        emit liquidityRemove(from, lpTotalSupply, lptokenReturned, ethReturned, lpTokenBalance, _amount);
    }

    function _swapTokenToEth(uint256 _pool, uint256 _amount, uint256 _estimatedAmount)  public payable{
        pool = Pool(payable(address(PoolMapping[_pool])));
        pool.swapTokenToEth{ value: msg.value }(_amount, _estimatedAmount, msg.sender);
        //if true return the values needed here in an event
    }

    function _swapEthToToken(uint256 _pool, uint256 _amount)  public payable{
        pool = Pool(payable(address(PoolMapping[_pool])));
        pool.swapEthToToken{ value: msg.value }(_amount, msg.sender);
    }
    
    function _getSwapAmount(uint256 _pool, uint256 _amount)  public returns (uint256){
        pool = Pool(payable(address(PoolMapping[_pool])));
        pool.getSwapAmountDai(_amount);
    }
    function _getSwapAmountEth(uint256 _pool, uint256 _amount)  public payable returns (uint256){
        pool = Pool(payable(address(PoolMapping[_pool])));
        pool.getSwapAmountEth{value: msg.value }(_amount);
    }
}
