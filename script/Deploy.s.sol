// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {FarcasterWrapped} from "../src/FarcasterWrapped.sol";

contract DeployScript is Script {
    function run() public {
        vm.broadcast();
        new FarcasterWrapped{salt: ""}(msg.sender, msg.sender, 0.000001 ether);
    }
}
