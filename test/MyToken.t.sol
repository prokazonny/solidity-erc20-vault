// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;


import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken token;

    function setUp() public {
        token = new MyToken(1000 ether);
    }

    function testTransfer() public {
        address sender = address(this);
        address receiver = address(0x1);

        uint256 senderBalanceBefore = token.balanceOf(sender);
        uint256 receiverBalanceBefore = token.balanceOf(receiver);

        assertTrue(token.transfer(receiver, 200 ether));

        assertEq(token.balanceOf(sender), senderBalanceBefore - 200 ether);
        assertEq(token.balanceOf(receiver), receiverBalanceBefore + 200 ether);
    }

    function testTransferRevert() public {
        address receiver = address(0x1);

        vm.expectRevert();
        token.transfer(receiver, 2000 ether);

        assertEq(token.balanceOf(address(this)), 1000 ether);
        assertEq(token.balanceOf(receiver), 0 ether);
    }

    function testMint() public {
        token.mint(address(this), 100 ether);

        assertEq(token.balanceOf(address(this)), 1100 ether);
    }

    function testBurn() public {
        token.burn(100 ether);

        assertEq(token.balanceOf(address(this)), 900 ether);
    }

    function testRevertBurn() public {
        vm.expectRevert();
        token.burn(1100 ether);

        assertEq(token.balanceOf(address(this)), 1000 ether);
    }
    
}