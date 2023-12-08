// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC721} from "solady/src/tokens/ERC721.sol";
import {EIP712} from "solady/src/utils/EIP712.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {SignatureCheckerLib} from "solady/src/utils/SignatureCheckerLib.sol";

import {Metadata} from "./Metadata.sol";

import {console2} from "forge-std/console2.sol";

contract FarcasterWrapped is Ownable, ERC721, EIP712 {
    error InvalidPayment();
    error InvalidSignature();

    bytes32 internal constant MINT_TYPEHASH = keccak256(
        "Mint(address to,uint256 fid,uint24 mins,uint16 streak,string username,bytes32 cid)"
    );
    uint256 public constant mintFee = 0.000777 ether;
    address public signer;

    struct WrappedStats {
        uint24 mins;
        uint16 streak;
        string username;
    }

    mapping(uint256 fid => WrappedStats) public statsOf;
    mapping(uint256 fid => bytes32 cid) public cidOf;

    constructor(address _owner, address _signer) {
        _initializeOwner(_owner);
        signer = _signer;
    }

    function name() public pure override returns (string memory) {
        return "Farcaster Wrapped 2023";
    }

    function symbol() public pure override returns (string memory) {
        return unicode"FC 🎁 2023";
    }

    function contractURI() public pure returns (string memory) {
        return Metadata.contractURI();
    }

    function tokenURI(uint256 fid)
        public
        view
        override
        returns (string memory)
    {
        WrappedStats memory stats = statsOf[fid];
        return Metadata.tokenURI(
            fid, imageURI(fid), stats.mins, stats.streak, stats.username
        );
    }

    function imageURI(uint256 fid) public view returns (string memory) {
        return Metadata.toImageURI(cidOf[fid]);
    }

    function mint(
        address to,
        uint256 fid,
        WrappedStats calldata stats,
        bytes32 cid,
        bytes calldata sig
    ) external payable {
        if (msg.value != mintFee) revert InvalidPayment();
        if (!_verifySignature(to, fid, stats, cid, sig)) {
            revert InvalidSignature();
        }
        statsOf[fid] = stats;
        cidOf[fid] = cid;
        _mint(to, fid);
    }

    function withdrawBalance(address to) external onlyOwner {
        SafeTransferLib.safeTransferAllETH(to);
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
