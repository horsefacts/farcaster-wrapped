// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {EIP712} from "solady/src/utils/EIP712.sol";
import {ERC721} from "solady/src/tokens/ERC721.sol";
import {LibString} from "solady/src/utils/LibString.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {SignatureCheckerLib} from "solady/src/utils/SignatureCheckerLib.sol";

import {LibCID} from "./LibCID.sol";
import {LibDataURI} from "./LibDataURI.sol";

contract FarcasterWrapped is Ownable, ERC721, EIP712 {
    using LibString for uint256;
    using LibCID for bytes32;
    using LibDataURI for string;

    /// @notice Caller provided incorrect payable amount
    error InvalidPayment();

    /// @notice Caller provided invalid `Mint` signature
    error InvalidSignature();

    /// @notice emitted when owner changes the signer address
    event SetSigner(address oldSigner, address newSigner);

    /// @notice EIP-712 typehash for `Mint` message
    bytes32 internal constant MINT_TYPEHASH = keccak256(
        "Mint(address to,uint256 fid,uint24 mins,uint16 streak,string username,bytes32 cid)"
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

    /// @notice Read token CID by fid
    mapping(uint256 fid => bytes32 cid) public cidOf;

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
    function contractURI() public pure returns (string memory) {
        return contractJSON().toDataURI();
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
        return tokenJSON(fid).toDataURI();
    }

    /// @notice Read token image URI
    /// @param fid Token/Farcaster ID
    /// @return Image ipfs:// URI
    function imageURI(uint256 fid) public view returns (string memory) {
        return cidOf[fid].toImageURI();
    }

    /// @notice Read token metadata JSON
    /// @param fid Token/Farcaster ID
    /// @return Token metadata JSON
    function tokenJSON(uint256 fid) public view returns (string memory) {
        WrappedStats memory stats = statsOf[fid];
        return string.concat(
            '{"image":"',
            imageURI(fid),
            '","name":"FID #',
            fid.toString(),
            '","attributes":[{"trait_type":"Minutes Spent Casting","value":',
            uint256(stats.mins).toString(),
            '},{"trait_type":"Streak","value":',
            uint256(stats.streak).toString(),
            '},{"trait_type":"Username","value":"',
            stats.username,
            '"}]}'
        );
    }

    /// @notice Read contract metadata JSON
    /// @return Contract metadata JSON
    function contractJSON() public pure returns (string memory) {
        return
        '{"name":"Farcaster Wrapped 2023","image":"TODO","description":"A commemorative NFT for all the people involved in proliferating the Farcaster protocol in 2023"}';
    }

    /// @notice Mint a Farcaster Wrapped token.
    ///         Caller must send mintFee wei as msg.value.
    ///         Caller must provide an EIP-712 `Mint` signature.
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

    /// @notice Set signer address. Only callable by owner.
    /// @param _signer New signer address
    function setSigner(address _signer) external onlyOwner {
        emit SetSigner(signer, signer = _signer);
    }

    /// @notice Withdraw contract balance. Only callable by owner.
    function withdrawBalance(address to) external onlyOwner {
        SafeTransferLib.safeTransferAllETH(to);
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
