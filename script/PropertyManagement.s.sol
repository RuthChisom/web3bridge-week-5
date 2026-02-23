// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {PropertyManagement} from "../src/PropertyManagement.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PropertyManagementScript is Script {
    function run() external {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy the PropertyManagement contract
        PropertyManagement pm = new PropertyManagement();

        // Add a sample property
        pm.createProperty("Ocean View Condo", "Miami, FL", 1000 ether, true, msg.sender);

        // Add another property
        pm.createProperty("Mountain Cabin", "Paris, FR", 500 ether, true, msg.sender);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}