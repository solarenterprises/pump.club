// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IFactory
 * @notice Interface for the factory contract that deploys token and bonding curve instances
 * @dev Factory is deployed via minimal proxy pattern and implements Initializable
 */
interface IFactory {
    // Custom Errors
    /// @notice Thrown when an address parameter is zero
    error ZeroAddress();

    /// @notice Thrown when initialization fails
    error InitializationFailed();

    /// @notice Thrown when caller is not authorized
    error Unauthorized();

    /// @notice Thrown when deployment fee is insufficient
    /// @param provided The amount of ETH provided
    /// @param required The required deployment fee
    error InsufficientDeploymentFee(uint256 provided, uint256 required);

    /// @notice Thrown when deployment parameters are invalid
    error InvalidDeploymentParameters();

    /// @notice Thrown when deployment minting fails
    error TokenMintingFailed();

    /// @notice Thrown when deployment extra fees refund fails
    error RefundFailed();
    error NoFeesToWithdraw();
    error FeeWithdrawalFailed();

    // Events
    /**
     * @notice Emitted when a new bonding curve system is deployed
     * @param bondingCurveAddress The address of the deployed bonding curve
     * @param tokenAddress The address of the deployed token
     * @param owner The address that will own both contracts
     * @param name Token name
     * @param symbol Token symbol
     */
    event BondingCurveSystemDeployed(
        address indexed bondingCurveAddress,
        address indexed tokenAddress,
        address indexed owner,
        string name,
        string symbol
    );

    /**
     * @notice Emitted when deployment fee is updated
     * @param oldFee Previous fee amount
     * @param newFee New fee amount
     */
    event DeploymentFeeUpdated(uint256 oldFee, uint256 newFee);

    /**
     * @notice Emitted when fees are withdrawn
     * @param recipient Address receiving the fees
     * @param amount Amount withdrawn
     */
    event FeesWithdrawn(address indexed recipient, uint256 amount);

    // Add new events
    event BondingCurveSettingsUpdated(
        uint256 virtualEth,
        uint256 preBondingTarget,
        uint256 bondingTarget,
        uint256 minContribution,
        uint24 poolFee
    );

    struct BondingCurveSettings {
        uint256 virtualEth;
        uint256 preBondingTarget;
        uint256 bondingTarget;
        uint256 minContribution;
        uint24 poolFee;
        uint24 sellFee;
        address uniswapV3Factory;
        address positionManager;
        address weth;
        address feeTo;
    }

    // Add new functions
    function getBondingCurveSettings()
        external
        view
        returns (BondingCurveSettings memory);

    function updateBondingCurveSettings(
        BondingCurveSettings calldata newSettings
    ) external;

    // View Functions
    /**
     * @notice Get the current deployment fee
     * @return Current fee amount in wei
     */
    function getDeploymentFee() external view returns (uint256);

    /**
     * @notice Get the token implementation address
     * @return Address of the token implementation contract
     */
    function getTokenImplementation() external view returns (address);

    /**
     * @notice Get the bonding curve implementation address
     * @return Address of the bonding curve implementation contract
     */
    function getBondingCurveImplementation() external view returns (address);

    /**
     * @notice Get the LP NFT lock contract address
     * @return Address of the LP NFT lock contract
     */
    function getLockContract() external view returns (address);

    // State-Changing Functions
    /**
     * @notice Initialize the factory contract
     * @param owner Address that will own the factory
     * @param tokenImpl Address of the token implementation
     * @param bondingCurveImpl Address of the bonding curve implementation
     * @param lockContract Address of the LP NFT lock contract
     */
    // Update initialize function
    function initialize(
        uint256 factoryFees,
        address owner,
        address tokenImpl,
        address bondingCurveImpl,
        address lockContract,
        BondingCurveSettings calldata settings
    ) external;

    /**
     * @notice Deploy a complete bonding curve system (token + bonding curve)
     * @param name Token name
     * @param symbol Token symbol
     * @return tokenAddress Address of the deployed token contract
     * @return bondingCurveAddress Address of the deployed bonding curve
     */
    function deployBondingCurveSystem(
        string calldata name,
        string calldata symbol
    )
        external
        payable
        returns (address tokenAddress, address bondingCurveAddress);

    /**
     * @notice Update the deployment fee
     * @param newFee New fee amount in wei
     */
    function updateDeploymentFee(uint256 newFee) external;

    /**
     * @notice Withdraw collected fees
     * @param recipient Address to receive the fees
     */
    function withdrawFees(address recipient) external;
}