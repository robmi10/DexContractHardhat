// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./Pool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DexV3 {
    Pool public  pool;

    event poolAddress (address indexed _pooladdress);
    event userAddress (address indexed _useraddress);

    event userNumber (uint256 indexed _userNumber);

    event userMessage (string indexed _message);
    mapping (uint256 => Pool) public PoolMapping;
    mapping (uint256 => address) public PoolMappingAddress;
    uint256 public counter;


     function getPoolAddress(uint256 _pool) public payable returns(address){
        pool = PoolMapping[_pool];
        emit poolAddress(address(pool));
        return address(pool);
    }

    function getPoolMap(uint256 _pool) public payable returns(address){
        address check_pool = PoolMappingAddress[_pool];
        emit poolAddress(check_pool);
        return address(pool);
    }

      function getMessage(uint256 _pool) public {
        pool = Pool(address(PoolMapping[_pool]));
        uint256 message = pool.getNumber();
        emit userNumber(message);
        
    }

       function checkPoolAddress(uint256 _pool) public payable returns(address){
        pool = PoolMapping[_pool];
        address getpool = pool.getAddress();
        emit poolAddress(getpool);
        return address(pool);
    }

    function createPool(address liquidityToken, address tokenA) public payable {
        pool = new Pool(liquidityToken, tokenA);
        PoolMappingAddress[counter] = address(pool);
        emit poolAddress(address(pool));
        counter += 1;
    }
    
    function _addLiquidity(uint256 _pool, uint256 _amount) public payable  {
        pool =  Pool(address(PoolMapping[_pool]));
        // tokenA.transferFrom(msg.sender, address(this), _amount);
        emit userAddress(address(pool));
        pool.addLiquidity(_amount, msg.sender);
        // pool.addLiquidity(_amount).send({from: msg.sender});
    }

    function _removeLiquidity(uint256 _pool, uint256 _amount) public payable{
        pool = PoolMapping[_pool];
        pool.removeLiquidity(_amount);
    }

    function _swapTokenToEth(uint256 _pool, uint256 _amount)  public payable{
        pool = PoolMapping[_pool];
        pool.swapTokenToEth(_amount);
    }

     function _swapEthToToken(uint256 _pool, uint256 _amount)  public payable{
        pool = PoolMapping[_pool];
        pool.swapEthToToken(_amount);
    }

}