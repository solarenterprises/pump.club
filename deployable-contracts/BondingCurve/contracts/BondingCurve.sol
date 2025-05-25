// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// BondingMath.sol
import "./libraries/BondingMath.sol";
import "./libraries/UniswapPoolCreator.sol";
import "./interfaces/IBondingCurve.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/ILock.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


interface IToken is IERC20 {
    function TOTAL_SUPPLY() external returns (uint256);
}

// BondingCurve.sol
contract BondingCurve is
    IBondingCurve,
    Initializable,
    Ownable2StepUpgradeable,
    ReentrancyGuardUpgradeable,
    IERC721Receiver
{
    using BondingMath for uint256;
    using UniswapPoolCreator for *;
    using Address for address payable;
    using SafeERC20 for IERC20;
    using SafeERC20 for IToken;

    // Constants
    IFactory.BondingCurveSettings private settings;

    // State variables
    IToken public token;
    address public lockContract;
    address public uniswapPool;
    uint256 public lpTokenId;
    bool public isFinalized;

    enum Phase {
        PreBonding,
        Bonding,
        Finalized
    }

    Phase public currentPhase;

    uint256 public totalPreBondingContributions;
    uint256 public ethReserve;
    uint256 public tokenReserve;
    uint256 public preBondingTokens;
    uint256 public totalETHCollected;
    uint256 public accumulatedFees;

    mapping(address => uint256) public contributions;
    mapping(address => bool) public tokenLocks;
    mapping(address => uint256) public tokenAllocations;

    modifier onlyPhase(Phase phase) {
        if (currentPhase != phase) revert InvalidPhase();
        _;
    }

    function initialize(
        address token_,
        address lock_,
        address owner_,
        IFactory.BondingCurveSettings calldata settings_
    ) external initializer {
        if (token_ == address(0) || lock_ == address(0) || owner_ == address(0))
            revert ZeroAddress();

        __Ownable_init(owner_);
        __ReentrancyGuard_init();

        token = IToken(token_);
        lockContract = lock_;
        settings = settings_;
        currentPhase = Phase.PreBonding;
    }

    function getBondingCurveSettings()
        external
        view
        returns (IFactory.BondingCurveSettings memory)
    {
        return settings;
    }

    function contributePreBonding()
        external
        payable
        nonReentrant
        onlyPhase(Phase.PreBonding)
    {
        if (msg.value < settings.minContribution) revert ContributionTooLow();

        uint256 newTotal = totalPreBondingContributions + msg.value;
        if (newTotal > settings.preBondingTarget)
            revert PreBondingTargetReached();

        uint256 tokensOut = BondingMath.calculateTokensForETH(
            settings.virtualEth, // virtual
            token.balanceOf(address(this)), // total supply (10B)
            msg.value // contribution amount
        );
        contributions[msg.sender] += msg.value;
        tokenAllocations[msg.sender] += tokensOut;
        totalPreBondingContributions += msg.value;
        preBondingTokens += tokensOut;
        tokenLocks[msg.sender] = true;
        emit PreBondingContribution(msg.sender, msg.value, tokensOut);
        if (totalPreBondingContributions >= settings.preBondingTarget) {
            currentPhase = Phase.Bonding;
            // Now ethReserve includes both virtual and real ETH
            ethReserve = settings.virtualEth + totalPreBondingContributions;
            totalETHCollected = totalPreBondingContributions;
            // tokenReserve is reduced by allocated tokens
            tokenReserve = token.balanceOf(address(this)) - preBondingTokens;
        }
    }

    function buyTokens(
        uint256 minTokens
    )
        external
        payable
        nonReentrant
        onlyPhase(Phase.Bonding)
        returns (uint256 tokensToReceive)
    {
        if (msg.value < settings.minContribution) revert ContributionTooLow();
        if (totalETHCollected > settings.bondingTarget)
            revert BondingTargetReached();

        tokensToReceive = BondingMath.calculateTokensForETH(
            ethReserve,
            tokenReserve,
            msg.value
        );

        if (tokensToReceive < minTokens) revert SlippageExceeded();
        if (tokenReserve < tokensToReceive) revert InsufficientTokens();

        ethReserve += msg.value;
        tokenReserve -= tokensToReceive;
        totalETHCollected += msg.value;
        token.safeTransfer(msg.sender, tokensToReceive);
        emit TokensPurchased(msg.sender, msg.value, tokensToReceive);
        if (totalETHCollected >= settings.bondingTarget) {
            currentPhase = Phase.Finalized;
        }
    }

    function sellTokens(
        uint256 tokenAmount,
        uint256 minETH
    )
        external
        nonReentrant
        onlyPhase(Phase.Bonding)
        returns (uint256 ethToReceive, uint256 fee)
    {
        if (tokenAmount == 0) revert InsufficientTokens();
        (ethToReceive, fee) = BondingMath.calculateETHForTokens(
            ethReserve,
            tokenReserve,
            tokenAmount,
            settings.sellFee
        );
        if (ethToReceive < minETH) revert SlippageExceeded();
        uint256 availableETH = ethReserve - settings.virtualEth;
        if (availableETH < ethToReceive + fee) revert InsufficientETH();
        ethReserve -= (ethToReceive + fee);
        tokenReserve += tokenAmount;
        token.safeTransferFrom(msg.sender, address(this), tokenAmount);
        payable(msg.sender).sendValue(ethToReceive);
        payable(settings.feeTo).sendValue(fee);
        emit TokensSold(msg.sender, tokenAmount, ethToReceive, fee);
    }

    function finalizeCurve() external nonReentrant {
        if (totalETHCollected < settings.bondingTarget)
            revert CannotFinalizeYet();
        if (isFinalized) revert AlreadyFinalized();

        UniswapPoolCreator.PoolParams memory poolParams = UniswapPoolCreator
            .PoolParams({
                factory: settings.uniswapV3Factory,
                token: address(token),
                weth: settings.weth,
                fee: settings.poolFee,
                ethReserve: ethReserve,
                tokenReserve: tokenReserve
            });

        address pool = UniswapPoolCreator.createAndInitializePool(poolParams);
        uint256 ethLiquidity = address(this).balance;
        uint256 tokenLiquidity = (ethLiquidity * tokenReserve) / ethReserve;

        token.safeIncreaseAllowance(settings.positionManager, tokenLiquidity);

        UniswapPoolCreator.PositionParams memory posParams = UniswapPoolCreator
            .PositionParams({
                positionManager: settings.positionManager,
                token: address(token),
                weth: settings.weth,
                fee: settings.poolFee,
                ethAmount: ethLiquidity,
                tokenAmount: tokenLiquidity
            });
        uint256 tokenId = UniswapPoolCreator.createLPPosition(posParams);
        // Approve lock contract to transfer the NFT
        INonfungiblePositionManager(settings.positionManager).approve(
            lockContract,
            tokenId
        );
        ILock(lockContract).lockNFT(tokenId, owner());
        uniswapPool = pool;
        lpTokenId = tokenId;
        isFinalized = true;
        currentPhase = Phase.Finalized;
        emit CurveFinalized(pool, tokenId);
    }

    receive() external payable {}

    /**
     * @notice Withdraw allocated tokens after curve finalization
     * @dev Can only be called after curve is finalized and only by addresses with allocations
     * @param recipient Address to receive the tokens
     */
    function withdrawTokenAllocation(address recipient) external nonReentrant {
        if (!isFinalized) revert CannotFinalizeYet();
        if (recipient == address(0)) revert ZeroAddress();
        if (!tokenLocks[msg.sender]) revert TokensNotLocked();
        uint256 allocation = tokenAllocations[msg.sender];
        if (allocation == 0) revert InsufficientTokens();
        // Reset state before transfer to prevent reentrancy
        tokenAllocations[msg.sender] = 0;
        tokenLocks[msg.sender] = false;
        // Transfer tokens to the specified recipient
        token.safeTransfer(recipient, allocation);

        emit TokensUnlocked(recipient);
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
}