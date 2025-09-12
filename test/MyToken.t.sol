// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "lib/forge-std/src/Test.sol";
import "../src/MyToken.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract MyTokenSafeTest is Test {
    using SafeERC20 for IERC20;

    MyToken token;

    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        token = new MyToken(1000 ether);

        // Раздаём токены
        IERC20(token).safeTransfer(user1, 100 ether);
        IERC20(token).safeTransfer(user2, 100 ether);
    }

    // =============================
    // 1. Unit-тесты ERC20
    // =============================
    function testInitialSupply() public {
        assertEq(token.balanceOf(address(this)), 800 ether);
    }

    function testSafeTransfer() public {
        uint256 senderBefore = token.balanceOf(address(this));
        uint256 receiverBefore = token.balanceOf(user1);

        IERC20(token).safeTransfer(user1, 50 ether);

        assertEq(token.balanceOf(address(this)), senderBefore - 50 ether);
        assertEq(token.balanceOf(user1), receiverBefore + 50 ether);
    }

    // =============================
    // 2. Mint & Burn
    // =============================
    function testMintByMinter() public {
        token.grantRole(token.MINTER_ROLE(), user1);
        vm.prank(user1);
        token.mint(user1, 200 ether);

        assertEq(token.balanceOf(user1), 300 ether); // 100 + 200
    }

    function testMintRevertByNonMinter() public {
        vm.startPrank(user2);
        vm.expectRevert(); // любой revert от AccessControl
        token.mint(user2, 200 ether);
        vm.stopPrank();

        assertEq(token.balanceOf(user2), 100 ether);
    }

    function testBurn() public {
        vm.startPrank(user1);
        token.burn(50 ether);
        vm.stopPrank();

        assertEq(token.balanceOf(user1), 50 ether); // 100 - 50
    }

    function testBurnRevert() public {
        vm.startPrank(user1);
        vm.expectRevert(); // revert при попытке сжечь больше, чем баланс
        token.burn(200 ether);
        vm.stopPrank();

        assertEq(token.balanceOf(user1), 100 ether);
    }

    // =============================
    // 3. AccessControl
    // =============================
    function testGrantAndRevokeMinterRole() public {
        token.grantRole(token.MINTER_ROLE(), user1);
        vm.prank(user1);
        token.mint(user1, 200 ether);
        assertEq(token.balanceOf(user1), 300 ether);

        token.revokeRole(token.MINTER_ROLE(), user1);
        vm.prank(user1);
        vm.expectRevert(); // теперь non-minter
        token.mint(user1, 100 ether);
    }

    // =============================
    // 4. Fuzz-тесты
    // =============================
    function testFuzzSafeTransfer(uint256 amount) public {
        amount = bound(amount, 1, token.balanceOf(address(this)));

        uint256 senderBefore = token.balanceOf(address(this));
        uint256 receiverBefore = token.balanceOf(user1);

        IERC20(token).safeTransfer(user1, amount);

        assertEq(token.balanceOf(address(this)), senderBefore - amount);
        assertEq(token.balanceOf(user1), receiverBefore + amount);
    }

    function testFuzzMint(uint256 amount) public {
        amount = bound(amount, 1, 1_000_000 ether);

        uint256 before = token.balanceOf(address(this));
        token.mint(address(this), amount);

        assertEq(token.balanceOf(address(this)), before + amount);
    }

    function testFuzzBurn(uint256 amount) public {
        amount = bound(amount, 1, token.balanceOf(address(this)));

        uint256 before = token.balanceOf(address(this));
        token.burn(amount);

        assertEq(token.balanceOf(address(this)), before - amount);
    }
}
