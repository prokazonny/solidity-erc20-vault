// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract TokenVault is AccessControl {
    using SafeERC20 for IERC20;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    mapping(address => mapping(IERC20 => uint256)) public balances;

    constructor(){
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    event Deposit(address indexed user, IERC20 indexed token, uint256 amount);
    event Withdraw(address indexed user, IERC20 indexed token, uint256 amount);

    function deposit(IERC20 token, uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");

        token.safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender][token] += amount;

        emit Deposit(msg.sender, token, amount);
    } 

    function withdraw(IERC20 token, address user, uint256 amount) public onlyRole(ADMIN_ROLE){
        require(balances[user][token] >= amount, "Influccient balance");
        require(amount > 0, "Amount must be greater than 0");

        balances[user][token] -= amount;
        token.safeTransfer(user, amount);

        emit Withdraw(user, token, amount);
    }
}

