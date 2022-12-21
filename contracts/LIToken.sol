//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LIToken is ERC20{
    event minted(address indexed _user, uint256 indexed _amount);
    event burned(address indexed _user, uint256 indexed _amount);

    constructor() ERC20('Lp', 'LPToken'){
    }

    function mint(address _sender, uint256 _amount) external {
        emit minted(_sender, _amount);
        _mint(_sender, _amount);
    }

    function burn(address _sender, uint256 _amount) external {
         emit burned(_sender, _amount);
        _burn(_sender, _amount);
    }

    function _totalSupply() public view returns(uint256){
         return totalSupply();
    }
}