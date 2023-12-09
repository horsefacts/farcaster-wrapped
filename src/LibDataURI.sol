// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Base64} from "solady/src/utils/Base64.sol";

library LibDataURI {
    function toDataURI(string memory json)
        internal
        pure
        returns (string memory)
    {
        return string.concat(
            "data:application/json;base64,",
            Base64.encode(abi.encodePacked(json))
        );
    }
}
