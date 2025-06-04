// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./IFactory.sol";

/**
 * @title IBondingCurve
 * @notice Interface for the bonding curve contract that manages token distribution and liquidity
 * @dev Implements constant product AMM formula with pre-bonding and bonding phases
 */
interface IBondingCurve {
    // Custom Errors
    error ZeroAddress();
    error InitializationFailed();
    error PreBondingTargetReached();
    error BondingTargetReached();
    error ContributionTooLow();
    error InvalidPhase();
    error TokensLocked();
    error TokensNotLocked();
    error InsufficientTokens();
    error InsufficientETH();
    error SlippageExceeded();
    error TransferFailed();
    error CannotFinalizeYet();
    error AlreadyFinalized();
    error NoFeesToWithdraw();

    // Events
    event PreBondingContribution(
        address indexed contributor,
        uint256 amount,
        uint256 tokenAmount
    );

    event PreBondingCompleted(uint256 totalContributed, uint256 totalTokens);

    event TokensUnlocked(address indexed account);

    event TokensPurchased(
        address indexed buyer,
        uint256 ethAmount,
        uint256 tokenAmount
    );

    event TokensSold(
        address indexed seller,
        uint256 tokenAmount,
        uint256 ethAmount,
        uint256 fee
    );

    event CurveFinalized(
        address indexed uniswapPool,
        uint256 indexed lpTokenId
    );

    event FeesWithdrawn(uint256 amount);

    // State-Changing Functions
    /**
     * @notice Initialize the bonding curve contract
     * @param token_ Address of the ERC20 token
     * @param lock_ Address of the LP NFT lock contract
     * @param owner_ Address that will own the contract
     */
    // Update initialize function
    function initialize(
        address token_,
        address lock_,
        address owner_,
        IFactory.BondingCurveSettings calldata settings_
    ) external;

    /**
     * @notice Contribute ETH during pre-bonding phase
     */
    function contributePreBonding() external payable;

    /**
     * @notice Buy tokens during bonding phase
     * @param minTokens Minimum tokens to receive (slippage protection)
     */
    function buyTokens(
        uint256 minTokens
    ) external payable returns (uint256 tokensToReceive);

    /**
     * @notice Sell tokens during bonding phase
     * @param tokenAmount Amount of tokens to sell
     * @param minETH Minimum ETH to receive (slippage protection)
     */
    function sellTokens(
        uint256 tokenAmount,
        uint256 minETH
    ) external returns (uint256 ethToReceive, uint256 fee);

    /**
     * @notice Finalize the curve and create Uniswap pool
     * @dev Only callable when bonding target is reached
     */
    function finalizeCurve() external;
}