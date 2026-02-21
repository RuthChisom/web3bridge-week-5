// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MyERC20} from "../src/MyERC20.sol";

contract MyERC20Script is Script {
    MyERC20 public myErc20;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        myErc20 = new MyERC20(
            "MyToken",
            "MTK",
            18,
            1000_000 * 10 ** 18 // Initial supply of 1 million tokens with 18 decimals
        );

        vm.stopBroadcast();
    }
}
