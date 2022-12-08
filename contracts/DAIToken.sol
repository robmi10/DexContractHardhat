pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DAI is ERC20{
    constructor() ERC20('DAI', 'DAPPTOKEN'){
        _mint(msg.sender, 180000000e18);
    }
}