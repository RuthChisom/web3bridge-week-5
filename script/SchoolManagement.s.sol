// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SchoolManagement} from "../src/SchoolManagement.sol";

contract SchoolManagementScript is Script {
    SchoolManagement public schoolManagement;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        schoolManagement = new SchoolManagement();

        vm.stopBroadcast();
    }
}
