// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "lib/forge-std/src/Test.sol";
import "../src/TokenVault.sol";
import "../src/MyToken.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenVaultSafeTest is Test {
    using SafeERC20 for IERC20;

    MyToken tokenA;
    MyToken tokenB;
    TokenVault vault;

    address user1 = address(0x111);
    address user2 = address(0x222);

    function setUp() public {
        tokenA = new MyToken(1000 ether);
        tokenB = new MyToken(500 ether);
        vault = new TokenVault();

 
        IERC20(tokenA).safeTransfer(user1, 200 ether);
        IERC20(tokenB).safeTransfer(user2, 100 ether);

        vm.startPrank(user1);
        tokenA.approve(address(vault), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(user2);
        tokenB.approve(address(vault), type(uint256).max);
        vm.stopPrank();
    }

    // =============================
    // Deposit
    // =============================

    function testDeposit() public {
        vm.startPrank(user1);
        vault.deposit(tokenA, 50 ether);
        vm.stopPrank();

        assertEq(vault.balances(user1, tokenA), 50 ether);
        assertEq(tokenA.balanceOf(address(vault)), 50 ether);
    }

    function testDepositZeroAmountRevert() public {
        vm.startPrank(user1);
        vm.expectRevert();
        vault.deposit(tokenA, 0);
        vm.stopPrank();
    }

    // =============================
    // Withdraw
    // =============================

    function testWithdrawByAdmin() public {
        vm.startPrank(user1);
        vault.deposit(tokenA, 100 ether);
        vm.stopPrank();

        vault.withdraw(tokenA, user1, 40 ether);

        assertEq(vault.balances(user1, tokenA), 60 ether);
        assertEq(tokenA.balanceOf(user1), 200 ether - 100 ether + 40 ether);
    }

    function testWithdrawRevertIfNotAdmin() public {
        vm.startPrank(user1);
        vault.deposit(tokenA, 20 ether);
        vm.stopPrank();

        vm.startPrank(user1);
        vm.expectRevert();
        vault.withdraw(tokenA, user1, 10 ether);
        vm.stopPrank();
    }

    function testWithdrawZeroAmountRevert() public {
        vm.startPrank(user1);
        vault.deposit(tokenA, 50 ether);
        vm.stopPrank();

        vm.expectRevert();
        vault.withdraw(tokenA, user1, 0);
    }

    function testWithdrawMoreThanBalanceRevert() public {
        vm.startPrank(user1);
        vault.deposit(tokenA, 50 ether);
        vm.stopPrank();

        vm.expectRevert();
        vault.withdraw(tokenA, user1, 100 ether);
    }

    // =============================
    // 3. Multi-token support
    // =============================

    function testMultiTokenSupport() public {
        vm.startPrank(user1);
        vault.deposit(tokenA, 50 ether);
        vm.stopPrank();

        vm.startPrank(user2);
        vault.deposit(tokenB, 30 ether);
        vm.stopPrank();

        assertEq(vault.balances(user1, tokenA), 50 ether);
        assertEq(vault.balances(user2, tokenB), 30 ether);
        assertEq(tokenA.balanceOf(address(vault)), 50 ether);
        assertEq(tokenB.balanceOf(address(vault)), 30 ether);
    }
}
