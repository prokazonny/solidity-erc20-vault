// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/TokenVault.sol";
import "../src/MyToken.sol";

contract TokenVaultTest is Test {
    MyToken token;
    TokenVault vault;

    function setUp() public {
        token = new MyToken(1000 ether);
        vault = new TokenVault();

        token.approve(address(vault), type(uint256).max);
    }

    function testDeposit() public {
        uint256 balanceBefore = vault.balances(address(this), token);

        vault.deposit(token, 100 ether); 

        assertEq(vault.balances(address(this), token), balanceBefore + 100 ether);
        assertEq(token.balanceOf(address(this)), 900 ether); 
        assertEq(token.balanceOf(address(vault)), 100 ether); 

    }

    function testWithdraw() public {
        uint256 balanceBefore = vault.balances(address(this), token);

        vault.deposit(token, 100 ether);

        assertEq(vault.balances(address(this), token), balanceBefore + 100 ether); // mapping
        assertEq(token.balanceOf(address(this)), 900 ether); // токены ушли с пользователя
        assertEq(token.balanceOf(address(vault)), 100 ether); // токены на контракте
        
        vault.withdraw(token, 100 ether);

        assertEq(vault.balances(address(this), token), 0 ether); 
        assertEq(token.balanceOf(address(this)), 1000 ether); 
        assertEq(token.balanceOf(address(vault)), 0 ether); 
    }

    function testWithdrawRevert() public {
        vm.expectRevert();
        vault.withdraw(token, 2000 ether); 
    }

    function testFuzzDepositWithdraw(uint256 depositAmount, uint256 withdrawAmount) public {
        uint256 balanceBefore = token.balanceOf(address(this));

        depositAmount = bound(depositAmount, 1, token.balanceOf(address(this)));
        vault.deposit(token, depositAmount);

        assertEq(vault.balances(address(this), token), depositAmount);
        assertEq(token.balanceOf(address(this)), balanceBefore - depositAmount); 
        assertEq(token.balanceOf(address(vault)), depositAmount);

        uint256 userBalanceBeforeWithdraw = token.balanceOf(address(this));

        withdrawAmount = bound(withdrawAmount, 1, depositAmount);
        vault.withdraw(token, withdrawAmount);

        assertEq(vault.balances(address(this), token), depositAmount - withdrawAmount);
        assertEq(token.balanceOf(address(this)), userBalanceBeforeWithdraw + withdrawAmount); 
        assertEq(token.balanceOf(address(vault)), depositAmount - withdrawAmount);
    }

    function testFuzzRevertWithdraw(uint256 depositAmount, uint256 withdrawAmount) public {
        depositAmount = bound(depositAmount, 1, token.balanceOf(address(this)));
        vault.deposit(token, depositAmount);

        uint256 userBalanceBeforeWithdraw = token.balanceOf(address(this));
        
        if( withdrawAmount > depositAmount){
            vm.expectRevert();
            vault.withdraw(token, withdrawAmount);
            assertEq(vault.balances(address(this), token), depositAmount);
            assertEq(token.balanceOf(address(this)), userBalanceBeforeWithdraw);
            assertEq(token.balanceOf(address(vault)), depositAmount); 
        }else {
            vault.withdraw(token, withdrawAmount);
            assertEq(vault.balances(address(this), token), depositAmount - withdrawAmount);
            assertEq(token.balanceOf(address(this)), userBalanceBeforeWithdraw + withdrawAmount);
            assertEq(token.balanceOf(address(vault)), depositAmount - withdrawAmount);
            }
    }
} 
