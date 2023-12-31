// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {FarcasterWrapped} from "../src/FarcasterWrapped.sol";

contract DeployScript is Script {
    function run() public {
        vm.startBroadcast();
        new FarcasterWrapped{salt: unicode"🎁"}(
            msg.sender,
            address(0xb07cD551fE9b8b99AAbdD2d38C6E356D48e2EFC9),
            0.000777 ether
        );
    }
}
