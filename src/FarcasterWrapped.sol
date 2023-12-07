// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC721} from "solady/src/tokens/ERC721.sol";
import {EIP712} from "solady/src/utils/EIP712.sol";
import {SignatureCheckerLib} from "solady/src/utils/SignatureCheckerLib.sol";

import {console2} from "forge-std/console2.sol";

contract FarcasterWrapped is ERC721, EIP712 {
    error InvalidSignature();

    bytes32 internal constant MINT_TYPEHASH = keccak256(
        "Mint(address to,uint256 fid,uint24 mins,uint16 streak,string username,bytes32 cid)"
    );

    address public signer;

    struct WrappedStats {
        uint24 mins;
        uint16 streak;
        string username;
    }

    mapping(uint256 fid => WrappedStats) public statsOf;
    mapping(uint256 fid => bytes32 cid) public cidOf;

    constructor(address _signer) {
        signer = _signer;
    }

    function name() public pure override returns (string memory) {
        return "Farcaster Wrapped 2023";
    }

    function symbol() public pure override returns (string memory) {
        return unicode"FC 🎁 2023";
    }

    function tokenURI(uint256) public pure override returns (string memory) {
        return "https://fake-not-implemented.com/";
    }

    function mint(
        address to,
        uint256 fid,
        WrappedStats calldata stats,
        bytes32 cid,
        bytes calldata sig
    ) public {
        if (!_verifySignature(to, fid, stats, cid, sig)) {
            revert InvalidSignature();
        }
        statsOf[fid] = stats;
        cidOf[fid] = cid;
        _mint(to, fid);
    }

    function _domainNameAndVersion()
        internal
        pure
        override
        returns (string memory, string memory)
    {
        return ("Farcaster Wrapped 2023", "1");
    }

    function _verifySignature(
        address to,
        uint256 fid,
        WrappedStats calldata stats,
        bytes32 cid,
        bytes calldata sig
    ) internal view returns (bool) {
        bytes32 digest = _hashTypedData(
            keccak256(
                abi.encode(
                    MINT_TYPEHASH,
                    to,
                    fid,
                    stats.mins,
                    stats.streak,
                    keccak256(bytes(stats.username)),
                    cid
                )
            )
        );
        return
            SignatureCheckerLib.isValidSignatureNowCalldata(signer, digest, sig);
    }
}
