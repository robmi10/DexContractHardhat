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
    event swapToToken (uint256 indexed _ethReserve,uint256 indexed _inputAmountFee, uint256  _fullEthReserve, uint256  _outputAmount, uint256  _msgValue);
    event getSwapAmount (uint256 _amount);
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

    function _swapTokenToEth(uint256 _pool, uint256 _amount, uint256 _estimatedAmount, address _account) public payable{
        pool = Pool(payable(address(PoolMapping[_pool])));
        pool.swapTokenToEth{ value: msg.value }(_amount, _estimatedAmount, _account);
        emit getSwapAmount(msg.value);
        //if true return the values needed here in an event
    }

    function _swapEthToToken(uint256 _pool, uint256 _amount, uint256 _estimateamount) public payable{
         pool = Pool(payable(address(PoolMapping[_pool])));
         pool.swapEthToToken{ value: msg.value }(_amount, _estimateamount, msg.sender);
         emit getSwapAmount(msg.value);
    }
    
    function _getSwapAmount(uint256 _pool, uint256 _amount)  public returns (uint256){
        pool = Pool(payable(address(PoolMapping[_pool])));
        (uint256 swapamount) = pool.getSwapAmountDai(_amount);
        emit getSwapAmount(swapamount);
        return swapamount;
    }

    function _getSwapAmountEth(uint256 _pool, uint256 _amount)  public  returns (uint256){
        pool = Pool(payable(address(PoolMapping[_pool])));
        (uint256 swapamount) = pool.getSwapAmountEth(_amount);
        emit getSwapAmount(swapamount);
        return swapamount;
    }

     function _getAmount(uint256 _pool, uint256 _amount)  public  returns (uint256, uint256){
        pool = Pool(payable(address(PoolMapping[_pool])));
        (uint256 calcAmount, uint256 amountCheck) = pool.getSwapAmountEthSecond(_amount);
        emit getSwapAmount(amountCheck);
        return (calcAmount, amountCheck);
    }

     function _getLiquidityStatus(uint256 _pool, uint256 _amount)  public  returns (uint256, uint256){
        pool = Pool(payable(address(PoolMapping[_pool])));
        (uint256 calcAmount, uint256 amountCheck) = pool.getLiquidityStatus(_amount);
        emit getSwapAmount(amountCheck);
        return (calcAmount, amountCheck);
    }

      function _getReserve(uint256 _pool, uint256 _amount)  public returns (uint256){
        pool = Pool(payable(address(PoolMapping[_pool])));
        (uint256 reserveAmount) = pool.getReserve();
        emit getSwapAmount(reserveAmount);
        return reserveAmount;
    }

      function _getEthReserve(uint256 _pool, uint256 _amount)  public  returns (uint256){
        pool = Pool(payable(address(PoolMapping[_pool])));
        (uint256 ethreserveAmount) = pool.getEthReserve();
        emit getSwapAmount(ethreserveAmount);
        return ethreserveAmount;
    }

    function _getinputAmountFee(uint256 _pool, uint256 _amount) public returns (uint256){
        pool = Pool(payable(address(PoolMapping[_pool])));
        (uint256 inputAmountFeeAmount) = pool.getinputAmountFee(_amount);
        emit getSwapAmount(inputAmountFeeAmount);
        return inputAmountFeeAmount;
    }

    function _getfullEthReserve(uint256 _pool, uint256 _amount)  public returns (uint256){
        pool = Pool(payable(address(PoolMapping[_pool])));
        (uint256 fullEthReserve) = pool.getfullEthReserve();
        emit getSwapAmount(fullEthReserve);
        return fullEthReserve;
    }

}
