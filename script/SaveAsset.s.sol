// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SaveAsset} from "../src/SaveAsset.sol";

contract SaveAssetScript is Script {
    SaveAsset public saveAsset;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        saveAsset = new SaveAsset(0x9cfBDFf9f0Edd7D3E0fdA5072DB483c41Ec11bd2);

        vm.stopBroadcast();
    }
}
