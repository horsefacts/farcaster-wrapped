// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {EIP712} from "solady/src/utils/EIP712.sol";
import {ERC721} from "solady/src/tokens/ERC721.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {SignatureCheckerLib} from "solady/src/utils/SignatureCheckerLib.sol";

import {Renderer} from "./Renderer.sol";
import {LibDataURI} from "./LibDataURI.sol";

contract FarcasterWrapped is Ownable, ERC721, EIP712 {
    using LibDataURI for string;

    Renderer public renderer = new Renderer();

    /// @notice Caller provided incorrect payable amount
    error InvalidPayment();

    /// @notice Caller provided invalid `Mint` signature
    error InvalidSignature();

    /// @notice emitted when owner changes the signer address
    event SetSigner(address oldSigner, address newSigner);

    /// @notice EIP-712 typehash for `Mint` message
    bytes32 internal constant MINT_TYPEHASH = keccak256(
        "Mint(address to,uint256 fid,uint24 mins,uint16 streak,string username)"
    );

    /// @notice Fee in wei per mint
    uint256 public immutable mintFee;

    /// @notice Address authorized to sign `Mint` messages
    address public signer;

    /// @notice Stats for a given FID
    /// @param mins Minutes spent casting
    /// @param streak Current streak
    /// @param username Username of caster
    struct WrappedStats {
        uint24 mins;
        uint16 streak;
        string username;
    }

    /// @notice Read stats by fid
    mapping(uint256 fid => WrappedStats) public statsOf;

    /// @notice Random seed by fid
    mapping(uint256 fid => uint32 seed) public seeds;

    /// @notice Set owner, signer, and mint fee
    /// @param _owner Contract owner address
    /// @param _signer Mint signer address
    /// @param _mintFee Fee in wei per mint
    constructor(address _owner, address _signer, uint256 _mintFee) {
        mintFee = _mintFee;
        _initializeOwner(_owner);
        emit SetSigner(address(0), signer = _signer);
    }

    /// @notice Read token name
    function name() public pure override returns (string memory) {
        return "Farcaster Wrapped 2023";
    }

    /// @notice Read token symbol
    function symbol() public pure override returns (string memory) {
        return unicode"FC 🎁 2023";
    }

    /// @notice Read contract metadata
    /// @return Base64 encoded metadata data URI
    function contractURI() public view returns (string memory) {
        return renderer.contractJSON().toDataURI("application/json");
    }

    /// @notice Read token metadata
    /// @param fid Token/Farcaster ID
    /// @return Base64 encoded metadata data URI
    function tokenURI(uint256 fid)
        public
        view
        override
        returns (string memory)
    {
        WrappedStats memory stats = statsOf[fid];
        return renderer.tokenJSON(
            seeds[fid], fid, stats.mins, stats.streak, stats.username
        ).toDataURI("application/json");
    }

    /// @notice Mint a Farcaster Wrapped token.
    ///         Caller must send mintFee wei as msg.value.
    ///         Caller must provide an EIP-712 `Mint` signature.
    function mint(
        address to,
        uint256 fid,
        WrappedStats calldata stats,
        bytes calldata sig
    ) external payable {
        if (msg.value != mintFee) revert InvalidPayment();
        if (!_verifySignature(to, fid, stats, sig)) {
            revert InvalidSignature();
        }
        statsOf[fid] = stats;
        seeds[fid] = _seed(fid);
        _mint(to, fid);
    }

    /// @notice Set signer address. Only callable by owner.
    /// @param _signer New signer address
    function setSigner(address _signer) external onlyOwner {
        emit SetSigner(signer, signer = _signer);
    }

    /// @notice Withdraw contract balance. Only callable by owner.
    function withdrawBalance(address to) external onlyOwner {
        SafeTransferLib.safeTransferAllETH(to);
    }

    /// @dev Generate token PRNG seed.
    function _seed(uint256 fid) internal view returns (uint32) {
        return uint32(
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp, blockhash(block.number - 1), fid
                    )
                )
            )
        );
    }

    /// @dev EIP-712 domain name and contract version.
    function _domainNameAndVersion()
        internal
        pure
        override
        returns (string memory, string memory)
    {
        return ("Farcaster Wrapped 2023", "1");
    }

    /// @dev Verify EIP-712 `Mint` signature.
    function _verifySignature(
        address to,
        uint256 fid,
        WrappedStats calldata stats,
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
                    keccak256(bytes(stats.username))
                )
            )
        );
        return
            SignatureCheckerLib.isValidSignatureNowCalldata(signer, digest, sig);
    }
}
