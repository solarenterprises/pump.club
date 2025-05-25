// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./IFactory.sol";

/**
 * @title IFoundry
 * @notice Interface for the main deployer contract that manages the bonding curve system
 * @dev Handles deployment and initialization of the entire bonding curve ecosystem
 */
interface IFoundry {
    // Custom Errors
    /// @notice Thrown when an address parameter is zero
    error ZeroAddress();

    /// @notice Thrown when initialization of a contract fails
    /// @param contractType The type of contract that failed to initialize
    error InitializationFailed(string contractType);

    /// @notice Thrown when the deployment fee provided is insufficient
    /// @param provided The amount of ETH provided
    /// @param required The required deployment fee
    error InsufficientDeploymentFee(uint256 provided, uint256 required);

    /// @notice Thrown when an invalid implementation type is provided
    /// @param providedType The invalid implementation type
    error InvalidImplementationType(string providedType);

    /// @notice Thrown when a fee-related operation fails
    /// @param operation The operation that failed (e.g., "refund", "withdrawal")
    error FeeOperationFailed(string operation);

    /// @notice Thrown when attempting to withdraw zero fees or when contract has no balance
    error NoFeesToWithdraw();

    /**
     * @notice Emitted when a new system (factory + lock) is deployed
     * @param factoryAddress The address of the newly deployed factory
     * @param lockAddress The address of the newly deployed lock contract
     * @param owner The address of the factory owner
     */
    event SystemDeployed(
        address indexed factoryAddress,
        address indexed lockAddress,
        address indexed owner
    );

    /**
     * @notice Emitted when implementation addresses are updated
     * @param implementationType The type of implementation being updated
     * @param oldImplementation The previous implementation address
     * @param newImplementation The new implementation address
     */
    event ImplementationUpdated(
        string indexed implementationType,
        address indexed oldImplementation,
        address indexed newImplementation
    );

    /**
     * @notice Emitted when the deployment fee is updated
     * @param oldFee The previous fee amount
     * @param newFee The new fee amount
     */
    event DeploymentFeeUpdated(uint256 oldFee, uint256 newFee);

    /**
     * @notice Emitted when fees are withdrawn
     * @param recipient The address receiving the fees
     * @param amount The amount withdrawn
     */
    event FeesWithdrawn(address indexed recipient, uint256 amount);

    // View Functions
    function getFactoryImplementation() external view returns (address);

    function getLockImplementation() external view returns (address);

    function getTokenImplementation() external view returns (address);

    function getBondingCurveImplementation() external view returns (address);

    function getDeploymentFee() external view returns (uint256);

    function isDeployedClone(address cloneAddress) external view returns (bool);

    /**
     * @notice Deploy both factory and lock contracts in a single transaction
     * @param owner Address that will own the factory
     * @param settings Bonding curve settings for initialization
     * @return factoryAddress The address of the newly deployed factory
     * @return lockAddress The address of the newly deployed lock contract
     */
    function deploySystem(
        address owner,
         uint256 factoryFees,
        IFactory.BondingCurveSettings calldata settings
    ) external payable returns (address factoryAddress, address lockAddress);

    /**
     * @notice Update the implementation address for a specific contract type
     * @param implementationType The type of implementation to update
     * @param newImplementation The new implementation address
     */
    function updateImplementation(
        string calldata implementationType,
        address newImplementation
    ) external;

    /**
     * @notice Update the deployment fee
     * @param newFee The new fee amount in wei
     */
    function updateDeploymentFee(uint256 newFee) external;

    /**
     * @notice Withdraw collected fees
     * @param recipient The address to receive the fees
     */
    function withdrawFees(address recipient) external;
}