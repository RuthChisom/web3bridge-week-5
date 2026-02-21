// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Lock} from "../src/Lock.sol";

contract LockScript is Script {
    Lock public lock;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        lock = new Lock();

        vm.stopBroadcast();
    }
}
