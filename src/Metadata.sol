// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LibString} from "solady/src/utils/LibString.sol";
import {Base58} from "base58-solidity/Base58.sol";
import {Base64} from "solady/src/utils/Base64.sol";

library Metadata {
    using LibString for uint256;

    function toCid(bytes32 value) internal pure returns (string memory) {
        return string(Base58.encode(abi.encodePacked(bytes2(0x1220), value)));
    }

    function toImageURI(bytes32 cid) internal pure returns (string memory) {
        return string.concat("ipfs://", toCid(cid));
    }

    function tokenJSON(
        uint256 tokenId,
        string memory imageURI,
        uint256 mins,
        uint256 streak,
        string memory username
    ) internal pure returns (string memory) {
        return string.concat(
            '{"image":"',
            imageURI,
            '","name":"FID #',
            tokenId.toString(),
            '","attributes":[{"trait_type":"Minutes Spent Casting","value":',
            mins.toString(),
            '},{"trait_type":"Streak","value":',
            streak.toString(),
            '},{"trait_type":"Username","value":"',
            username,
            '"}]}'
        );
    }

    function contractJSON() internal pure returns (string memory) {
        return
        '{"name":"Farcaster Wrapped 2023","image":"TODO","description":"TODO"}';
    }

    function contractURI() internal pure returns (string memory) {
        return toDataURI(contractJSON());
    }

    function tokenURI(
        uint256 tokenId,
        string memory imageURI,
        uint256 mins,
        uint256 streak,
        string memory username
    ) internal pure returns (string memory) {
        return toDataURI(tokenJSON(tokenId, imageURI, mins, streak, username));
    }

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
