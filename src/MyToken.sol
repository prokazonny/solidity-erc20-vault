// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken" , "MTK") {
        _mint(msg.sender, initialSupply);
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    function burn  (uint256 amount) public {
        _burn(msg.sender, amount);
    }

}