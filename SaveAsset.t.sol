// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SaveAsset} from "../src/SaveAsset.sol";
import {ERC20} from "../src/ERC20.sol"; // your own ERC20 contract

contract SaveAssetTest is Test {
    SaveAsset public saveAsset;
    ERC20 public token;

    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        // Deploy ERC20 token and SaveAsset contract
        token = new ERC20("TestToken", "TTK", 18, 1_000_000 ether);
        saveAsset = new SaveAsset(address(token));

        // Fund users with ETH
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);

        // Mint ERC20 tokens to users (if your ERC20 has a mint function)
        token.transfer(user1, 1000 ether);
        token.transfer(user2, 1000 ether);

        // Approve SaveAsset to spend ERC20 tokens
        vm.prank(user1);
        token.approve(address(saveAsset), 1_000 ether);

        vm.prank(user2);
        token.approve(address(saveAsset), 1_000 ether);
    }

    function test_DepositETH() public {
        vm.prank(user1);
        saveAsset.deposit{value: 1 ether}();
        assertEq(saveAsset.balances(user1), 1 ether);
    }

    function test_WithdrawETH() public {
        vm.prank(user1);
        saveAsset.deposit{value: 2 ether}();

        vm.prank(user1);
        saveAsset.withdraw(1 ether);

        assertEq(saveAsset.balances(user1), 1 ether);
    }

    function test_DepositERC20() public {
        vm.prank(user1);
        saveAsset.depositERC20(100 ether);

        assertEq(saveAsset.getErc20SavingsBalance(), 100 ether);
    }

    function test_WithdrawERC20() public {
        vm.prank(user1);
        saveAsset.depositERC20(200 ether);

        vm.prank(user1);
        saveAsset.withdrawERC20(50 ether);

        assertEq(saveAsset.getErc20SavingsBalance(), 150 ether);
    }

    function testFail_WithdrawERC20Insufficient() public {
        vm.prank(user2);
        saveAsset.withdrawERC20(50 ether);
    }

    function test_ContractBalance() public {
        vm.prank(user1);
        saveAsset.deposit{value: 1 ether}();

        vm.prank(user2);
        saveAsset.deposit{value: 2 ether}();

        assertEq(saveAsset.getContractBalance(), 3 ether);
    }

    function test_ReceiveFallback() public {
        (bool success, ) = address(saveAsset).call{value: 1 ether}("");
        assertTrue(success);
        assertEq(saveAsset.getContractBalance(), 1 ether);
    }
}
