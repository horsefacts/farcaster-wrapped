// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {FarcasterWrapped} from "../src/FarcasterWrapped.sol";

contract FarcasterWrappedHarness is FarcasterWrapped {
    constructor(address _signer) FarcasterWrapped(_signer) {}

    function mintTypeHash() external pure returns (bytes32) {
        return MINT_TYPEHASH;
    }

    function hashTypedData(bytes32 structHash) public view returns (bytes32) {
        return _hashTypedData(structHash);
    }
}

contract FarcasterWrappedTest is Test {
    FarcasterWrappedHarness public token;

    address internal signer;
    uint256 internal signerPk;

    function setUp() public {
        (signer, signerPk) = makeAddrAndKey("signer");
        token = new FarcasterWrappedHarness(signer);
    }

    function test_name() public {
        assertEq(token.name(), "Farcaster Wrapped 2023");
    }

    function test_symbol() public {
        assertEq(token.symbol(), unicode"FC 🎁 2023");
    }

    function testFuzz_mint_validSig(
        address to,
        uint256 fid,
        FarcasterWrapped.WrappedStats calldata stats,
        bytes32 cid
    ) public {
        vm.assume(to != address(0));

        bytes memory sig = _signMint(signerPk, to, fid, stats, cid);

        token.mint(to, fid, stats, cid, sig);

        assertEq(token.balanceOf(to), 1);
        assertEq(token.ownerOf(fid), to);
        assertEq(token.cidOf(fid), cid);
        (uint24 mins, uint16 streak, string memory username) =
            token.statsOf(fid);
        assertEq(mins, stats.mins);
        assertEq(streak, stats.streak);
        assertEq(username, stats.username);
    }

    function testFuzz_mint_invalidSig(
        address to,
        uint256 fid,
        FarcasterWrapped.WrappedStats calldata stats,
        bytes32 cid,
        bytes calldata sig
    ) public {
        vm.assume(to != address(0));
        bytes memory validSig = _signMint(signerPk, to, fid, stats, cid);
        vm.assume(keccak256(sig) != keccak256(validSig));

        vm.expectRevert(FarcasterWrapped.InvalidSignature.selector);
        token.mint(to, fid, stats, cid, sig);
    }

    function _signMint(
        uint256 pk,
        address to,
        uint256 fid,
        FarcasterWrapped.WrappedStats calldata stats,
        bytes32 cid
    ) internal returns (bytes memory signature) {
        bytes32 digest = token.hashTypedData(
            keccak256(
                abi.encode(
                    token.mintTypeHash(),
                    to,
                    fid,
                    stats.mins,
                    stats.streak,
                    keccak256(bytes(stats.username)),
                    cid
                )
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        signature = abi.encodePacked(r, s, v);
        assertEq(signature.length, 65);
    }
}
