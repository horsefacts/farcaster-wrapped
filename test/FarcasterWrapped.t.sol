// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {LibString} from "solady/src/utils/LibString.sol";
import {Base64} from "solady/src/utils/Base64.sol";

import {FarcasterWrapped} from "../src/FarcasterWrapped.sol";

contract FarcasterWrappedHarness is FarcasterWrapped {
    constructor(
        address _owner,
        address _signer
    ) FarcasterWrapped(_owner, _signer) {}

    function mintTypeHash() external pure returns (bytes32) {
        return MINT_TYPEHASH;
    }

    function hashTypedData(bytes32 structHash) public view returns (bytes32) {
        return _hashTypedData(structHash);
    }
}

contract FarcasterWrappedTest is Test {
    FarcasterWrappedHarness public token;

    address internal owner = makeAddr("owner");
    address internal signer;
    uint256 internal signerPk;

    function setUp() public {
        (signer, signerPk) = makeAddrAndKey("signer");
        token = new FarcasterWrappedHarness(owner, signer);
    }

    function test_name() public {
        assertEq(token.name(), "Farcaster Wrapped 2023");
    }

    function test_symbol() public {
        assertEq(token.symbol(), unicode"FC 🎁 2023");
    }

    function testFuzz_mint_validSig(
        address caller,
        address to,
        uint256 fid,
        FarcasterWrapped.WrappedStats calldata stats,
        bytes32 cid
    ) public {
        vm.assume(to != address(0));

        vm.deal(caller, token.mintFee());
        bytes memory sig = _signMint(signerPk, to, fid, stats, cid);

        vm.prank(caller);
        token.mint{value: token.mintFee()}(to, fid, stats, cid, sig);

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
        address caller,
        address to,
        uint256 fid,
        FarcasterWrapped.WrappedStats calldata stats,
        bytes32 cid,
        bytes calldata sig
    ) public {
        vm.assume(to != address(0));
        bytes memory validSig = _signMint(signerPk, to, fid, stats, cid);
        vm.assume(keccak256(sig) != keccak256(validSig));

        uint256 fee = token.mintFee();

        vm.deal(caller, fee);

        vm.expectRevert(FarcasterWrapped.InvalidSignature.selector);
        vm.prank(caller);
        token.mint{value: fee}(to, fid, stats, cid, sig);
    }

    function testFuzz_mint_overPayment(
        address caller,
        address to,
        uint256 fid,
        FarcasterWrapped.WrappedStats calldata stats,
        bytes32 cid,
        uint256 _payment
    ) public {
        vm.assume(to != address(0));

        bytes memory sig = _signMint(signerPk, to, fid, stats, cid);

        uint256 payment =
            bound(_payment, token.mintFee() + 1, type(uint256).max);
        vm.deal(caller, payment);

        vm.expectRevert(FarcasterWrapped.InvalidPayment.selector);
        vm.prank(caller);
        token.mint{value: payment}(to, fid, stats, cid, sig);
    }

    function testFuzz_mint_underPayment(
        address caller,
        address to,
        uint256 fid,
        FarcasterWrapped.WrappedStats calldata stats,
        bytes32 cid,
        uint256 _payment
    ) public {
        vm.assume(to != address(0));

        bytes memory sig = _signMint(signerPk, to, fid, stats, cid);
        uint256 payment = bound(_payment, 0, token.mintFee() - 1);
        vm.deal(caller, payment);

        vm.expectRevert(FarcasterWrapped.InvalidPayment.selector);
        vm.prank(caller);
        token.mint{value: payment}(to, fid, stats, cid, sig);
    }

    function test_metadata() public {
        uint256 fid = 1;
        bytes32 cid = bytes32(
            0xc3c4733ec8affd06cf9e9ff50ffc6bcd2ec85a6170004bb709669c31de94391a
        );
        FarcasterWrapped.WrappedStats memory stats =
            FarcasterWrapped.WrappedStats(1000, 10, "username");
        vm.deal(address(this), token.mintFee());
        bytes memory sig =
            this._signMint(signerPk, address(this), fid, stats, cid);

        token.mint{value: token.mintFee()}(address(this), fid, stats, cid, sig);

        string memory dataURI = token.tokenURI(fid);
        string[] memory split = LibString.split(dataURI, ",");
        string memory encoded = split[1];
        string memory decoded = string(Base64.decode(encoded));

        assertEq(
            dataURI,
            "data:application/json;base64,eyJpbWFnZSI6ImlwZnM6Ly9RbWJXcXhCRUtDM1A4dHFzS2M5OHhtV056cnpEdFJMTWlNUEw4d0J1VEdzTW5SIiwibmFtZSI6IkZJRCAjMSIsImF0dHJpYnV0ZXMiOlt7InRyYWl0X3R5cGUiOiJNaW51dGVzIFNwZW50IENhc3RpbmciLCJ2YWx1ZSI6MTAwMH0seyJ0cmFpdF90eXBlIjoiU3RyZWFrIiwidmFsdWUiOjEwfSx7InRyYWl0X3R5cGUiOiJVc2VybmFtZSIsInZhbHVlIjoidXNlcm5hbWUifV19"
        );
        assertEq(
            decoded,
            '{"image":"ipfs://QmbWqxBEKC3P8tqsKc98xmWNzrzDtRLMiMPL8wBuTGsMnR","name":"FID #1","attributes":[{"trait_type":"Minutes Spent Casting","value":1000},{"trait_type":"Streak","value":10},{"trait_type":"Username","value":"username"}]}'
        );
    }

    function _signMint(
        uint256 pk,
        address to,
        uint256 fid,
        FarcasterWrapped.WrappedStats calldata stats,
        bytes32 cid
    ) public returns (bytes memory signature) {
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
