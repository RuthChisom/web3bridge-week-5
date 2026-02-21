// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SavingsVault} from "../src/SavingsVault.sol";

contract SavingsVaultScript is Script {
    SavingsVault public savingsVault;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        savingsVault = new SavingsVault();

        vm.stopBroadcast();
    }
}
