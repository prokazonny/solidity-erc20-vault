// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenVault {
    using SafeERC20 for IERC20;

    
    mapping(address => mapping(IERC20 => uint256)) public balances;

    function deposit(IERC20 token, uint256 amount) public {
        token.safeTransferFrom(msg.sender, address(this), amount);

        balances[msg.sender][token] += amount;
    } 

    function withdraw(IERC20 token, uint256 amount) public {
        require(balances[msg.sender][token] >= amount, "Influccient balance");

        balances[msg.sender][token] -= amount;

        token.safeTransfer(msg.sender, amount);
    }
}

