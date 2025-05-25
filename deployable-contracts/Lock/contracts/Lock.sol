// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./interfaces/ILock.sol";
import "./interfaces/UniswapV3Interfaces.sol";

/**
 * @title Lock
 * @notice Contract for locking Uniswap V3 LP NFTs and managing fee claims
 * @dev Implements IERC721Receiver to accept NFT transfers
 */
contract Lock is
    ILock,
    Initializable,
    Ownable2StepUpgradeable,
    ReentrancyGuardUpgradeable,
    IERC721Receiver
{
    // Structs
    struct LockedNFT {
        address owner;
        uint256 tokenId;
        bool isLocked;
        uint256 lockedAt;
    }

    // State variables
    INonfungiblePositionManager public positionManager;
    mapping(uint256 => LockedNFT) public lockedNFTs;
    mapping(address => uint256[]) public ownerNFTs;

    // Constants
    uint256 public constant LOCK_DURATION = 3650 days; // ten years.
    address public immutable UNISWAP_V3_POSITION_MANAGER;

    constructor(address _positionManager) {
        _disableInitializers();
        UNISWAP_V3_POSITION_MANAGER = _positionManager;
    }

    /**
     * @notice Initialize the lock contract
     */
    function initialize() external initializer {
        __Ownable_init(_msgSender());
        __ReentrancyGuard_init();
        positionManager = INonfungiblePositionManager(
            UNISWAP_V3_POSITION_MANAGER
        );
    }

    /**
     * @notice Lock a Uniswap V3 LP NFT
     * @param tokenId The ID of the NFT to lock
     */
    function lockNFT(uint256 tokenId, address owner) external nonReentrant {
        if (lockedNFTs[tokenId].isLocked) revert NFTAlreadyLocked();

        // Transfer NFT to this contract
        positionManager.safeTransferFrom(_msgSender(), address(this), tokenId);

        // Create locked NFT record
        lockedNFTs[tokenId] = LockedNFT({
            owner: owner,
            tokenId: tokenId,
            isLocked: true,
            lockedAt: block.timestamp
        });

        ownerNFTs[owner].push(tokenId);

        emit NFTLocked(owner, tokenId);
    }

    /**
     * @notice Unlock an NFT after the lock period
     * @param tokenId The ID of the NFT to unlock
     */
    function unlockNFT(uint256 tokenId, address to) external nonReentrant {
        LockedNFT storage nft = lockedNFTs[tokenId];

        if (!nft.isLocked) revert NFTNotLocked();
        if (nft.owner != _msgSender()) revert NotNFTOwner();
        if (block.timestamp < nft.lockedAt + LOCK_DURATION)
            revert LockPeriodNotEnded();

        // Transfer NFT back to owner
        positionManager.safeTransferFrom(address(this), to, tokenId);

        // Update state
        nft.isLocked = false;

        // Remove from owner's NFT array
        _removeNFTFromOwner(_msgSender(), tokenId);

        emit NFTUnlocked(_msgSender(), tokenId, to);
    }

    /**
     * @notice Claim accumulated fees for a locked NFT position
     * @param tokenId The NFT position ID
     */
    function claimFees(
        uint256 tokenId
    ) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        LockedNFT storage nft = lockedNFTs[tokenId];

        if (!nft.isLocked) revert NFTNotLocked();
        if (nft.owner != _msgSender()) revert NotNFTOwner();

        // Collect fees through position manager
        (amount0, amount1) = positionManager.collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: _msgSender(),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );

        emit FeesClaimed(_msgSender(), tokenId, amount0, amount1);
    }

    /**
     * @notice Check available fees for a locked NFT position
     * @param tokenId The NFT position ID
     * @return amount0 Available fees for token0
     * @return amount1 Available fees for token1
     */
    function checkAvailableFees(
        uint256 tokenId
    ) external view returns (uint256 amount0, uint256 amount1) {
        if (!lockedNFTs[tokenId].isLocked) revert NFTNotLocked();

        // Get position info from position manager
        (
            ,
            ,
            ,
            ,
            ,
            ,
            ,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        ) = positionManager.positions(tokenId);

        // Return currently owed tokens plus any accumulated but uncollected fees
        amount0 = uint256(tokensOwed0);
        amount1 = uint256(tokensOwed1);

        if (liquidity > 0) {
            // Add current fee growth if position is still active
            amount0 += uint256(feeGrowthInside0LastX128);
            amount1 += uint256(feeGrowthInside1LastX128);
        }
    }

    /**
     * @notice Get all NFTs owned by an address
     * @param owner The address to query
     * @return Array of NFT IDs owned by the address
     */
    function getNFTsByOwner(
        address owner
    ) external view returns (uint256[] memory) {
        return ownerNFTs[owner];
    }

    /**
     * @notice Check if an NFT is currently locked
     * @param tokenId The NFT ID to check
     * @return true if NFT is locked
     */
    function isNFTLocked(uint256 tokenId) external view returns (bool) {
        return lockedNFTs[tokenId].isLocked;
    }

    /**
     * @notice Get remaining lock time for an NFT
     * @param tokenId The NFT ID to check
     * @return Remaining time in seconds, 0 if lock period has ended
     */
    function getRemainingLockTime(
        uint256 tokenId
    ) external view returns (uint256) {
        LockedNFT storage nft = lockedNFTs[tokenId];
        if (!nft.isLocked) return 0;

        uint256 endTime = nft.lockedAt + LOCK_DURATION;
        if (block.timestamp >= endTime) return 0;

        return endTime - block.timestamp;
    }

    /**
     * @notice Implements IERC721Receiver
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * @notice Remove an NFT from owner's array
     * @param owner Address of the NFT owner
     * @param tokenId ID of the NFT to remove
     */
    function _removeNFTFromOwner(address owner, uint256 tokenId) internal {
        uint256[] storage ownerTokens = ownerNFTs[owner];
        for (uint256 i = 0; i < ownerTokens.length; i++) {
            if (ownerTokens[i] == tokenId) {
                // Move the last element to this position and pop
                ownerTokens[i] = ownerTokens[ownerTokens.length - 1];
                ownerTokens.pop();
                break;
            }
        }
    }
}