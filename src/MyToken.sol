// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MyToken is ERC20, ERC20Permit, AccessControl {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(uint256 initialSupply) 
        ERC20Permit("MyToken")
        ERC20("MyToken", "MTK") 
    {
        _mint(msg.sender, initialSupply);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address account, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(account, amount);
    }

    function burn (uint256 amount) public {
        _burn(msg.sender, amount);
    }
}