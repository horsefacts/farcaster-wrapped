// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Base58} from "base58-solidity/Base58.sol";

library LibCID {
    function toCid(bytes32 value) internal pure returns (string memory) {
        return string(Base58.encode(abi.encodePacked(bytes2(0x1220), value)));
    }

    function toImageURI(bytes32 cid) internal pure returns (string memory) {
        return string.concat("ipfs://", toCid(cid));
    }
}
