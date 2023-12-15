// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Base64} from "solady/src/utils/Base64.sol";

library LibDataURI {
    function toDataURI(
        string memory data,
        string memory mimeType
    ) internal pure returns (string memory) {
        return string.concat(
            "data:", mimeType, ";base64,", Base64.encode(abi.encodePacked(data))
        );
    }
}
