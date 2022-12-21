// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./Pool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Dex {
    Pool public  pool;
    
    event userAddress (address indexed _useraddress);
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
       // emit poolAddress(address(pool));
        counter += 1;
    }
    
    function _addLiquidity(uint256 _pool, uint256 _amount) public payable  {
        require(_amount >= msg.value, "to little amount");
        pool =  Pool(payable(address(PoolMapping[_pool])));
        emit userAddress(address(pool));
        pool.addLiquidity{ value: msg.value }(_amount, msg.sender);
    }

    function _removeLiquidity(uint256 _pool, uint256 _amount) public payable{
        pool = Pool(payable(address(PoolMapping[_pool]))); 
        pool.removeLiquidity(_amount, msg.sender);
    }

    function _swapTokenToEth(uint256 _pool, uint256 _amount, uint256 _estimatedAmount)  public payable{
        pool = Pool(payable(address(PoolMapping[_pool])));
        pool.swapTokenToEth{ value: msg.value }(_amount, _estimatedAmount, msg.sender);
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
