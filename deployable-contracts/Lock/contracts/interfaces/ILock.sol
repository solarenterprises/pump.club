// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ILock
 * @notice Interface for the LP NFT lock contract
 * @dev Handles locking of Uniswap V3 LP NFTs and fee management
 */
interface ILock {
    // Custom Errors
    /// @notice Thrown when NFT is already locked
    error NFTAlreadyLocked();

    /// @notice Thrown when NFT is not locked
    error NFTNotLocked();

    /// @notice Thrown when caller is not the NFT owner
    error NotNFTOwner();

    /// @notice Thrown when lock period has not ended
    error LockPeriodNotEnded();

    // Events
    /**
     * @notice Emitted when an NFT is locked
     * @param owner Address of the NFT owner
     * @param tokenId ID of the locked NFT
     */
    event NFTLocked(address indexed owner, uint256 indexed tokenId);

    /**
     * @notice Emitted when an NFT is unlocked
     * @param owner Address of the NFT owner
     * @param tokenId ID of the unlocked NFT
     */
    event NFTUnlocked(
        address indexed owner,
        uint256 indexed tokenId,
        address to
    );

    /**
     * @notice Emitted when fees are claimed
     * @param owner Address claiming the fees
     * @param tokenId NFT position ID
     * @param amount0 Amount of token0 fees claimed
     * @param amount1 Amount of token1 fees claimed
     */
    event FeesClaimed(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 amount0,
        uint256 amount1
    );

    // Functions
    function initialize() external;

    function lockNFT(uint256 tokenId, address owner) external;

    function unlockNFT(uint256 tokenId, address to) external;

    function claimFees(
        uint256 tokenId
    ) external returns (uint256 amount0, uint256 amount1);

    function checkAvailableFees(
        uint256 tokenId
    ) external view returns (uint256 amount0, uint256 amount1);

    function getNFTsByOwner(
        address owner
    ) external view returns (uint256[] memory);

    function isNFTLocked(uint256 tokenId) external view returns (bool);

    function getRemainingLockTime(
        uint256 tokenId
    ) external view returns (uint256);
}