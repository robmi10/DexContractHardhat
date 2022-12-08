//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20{
    event depositEvent(uint256 amount, address indexed from);
    event widthdrawEvent(uint256 amount, address indexed from);
    event transferEvent(bool indexed status, bytes indexed data);
    constructor() ERC20('Wrapped Ether', 'WETH'){
    }
 
    function deposit () public payable{
        ERC20(address(this)).transfer(msg.sender, msg.value);
        emit depositEvent(msg.value, msg.sender);
        _mint(msg.sender, msg.value);
    }

    function widthdraw(uint256 _amount) external {
        _burn(msg.sender, _amount);
        (bool call, bytes memory data) = msg.sender.call{value: _amount}("");
        emit transferEvent(call, data);
        emit widthdrawEvent(_amount, msg.sender);
    }
       fallback () external{
        deposit();
    }
}