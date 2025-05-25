// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IFoundry.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title Foundry
 * @notice Main deployer contract for the bonding curve system
 * @dev Implements minimal proxy pattern for gas-efficient deployment
 */
contract Foundry is IFoundry, Ownable, ReentrancyGuard, Pausable {
    using Clones for address;

    // Implementation addresses
    address private factoryImplementation;
    address private lockImplementation;
    address private tokenImplementation;
    address private bondingCurveImplementation;

    // Deployment fee
    uint256 private deploymentFee;

    // Mapping to track deployed clones
    mapping(address => bool) private deployedClones;

    /**
     * @notice Constructor to initialize the Foundry contract
     */
    constructor(
        address _factoryImpl,
        address _lockImpl,
        address _tokenImpl,
        address _bondingCurveImpl,
        uint256 _initialFee
    ) Ownable(msg.sender) {
        if (_factoryImpl == address(0)) revert ZeroAddress();
        if (_lockImpl == address(0)) revert ZeroAddress();
        if (_tokenImpl == address(0)) revert ZeroAddress();
        if (_bondingCurveImpl == address(0)) revert ZeroAddress();

        factoryImplementation = _factoryImpl;
        lockImplementation = _lockImpl;
        tokenImplementation = _tokenImpl;
        bondingCurveImplementation = _bondingCurveImpl;
        deploymentFee = _initialFee;
    }

    // Implementation of view functions
    function getFactoryImplementation() external view returns (address) {
        return factoryImplementation;
    }

    function getLockImplementation() external view returns (address) {
        return lockImplementation;
    }

    function getTokenImplementation() external view returns (address) {
        return tokenImplementation;
    }

    function getBondingCurveImplementation() external view returns (address) {
        return bondingCurveImplementation;
    }

    function getDeploymentFee() external view returns (uint256) {
        return deploymentFee;
    }

    function isDeployedClone(
        address cloneAddress
    ) external view returns (bool) {
        return deployedClones[cloneAddress];
    }

    /**
     * @inheritdoc IFoundry
     */
    function deploySystem(
        address owner,
        uint256 factoryFees,
        IFactory.BondingCurveSettings calldata settings
    )
        external
        payable
        whenNotPaused
        nonReentrant
        returns (address factoryAddress, address lockAddress)
    {
        if (msg.value < deploymentFee) {
            revert InsufficientDeploymentFee(msg.value, deploymentFee);
        }
        if (owner == address(0)) revert ZeroAddress();

        // Deploy lock contract clone
        lockAddress = lockImplementation.clone();
        deployedClones[lockAddress] = true;

        // Initialize lock contract
        (bool lockSuccess, ) = lockAddress.call(
            abi.encodeWithSignature("initialize()")
        );
        if (!lockSuccess) revert InitializationFailed("lock");

        // Deploy factory clone
        factoryAddress = factoryImplementation.clone();
        deployedClones[factoryAddress] = true;

        // Initialize factory with all required parameters
        IFactory(factoryAddress).initialize(
            factoryFees,
            owner,
            tokenImplementation,
            bondingCurveImplementation,
            lockAddress,
            settings
        );

        emit SystemDeployed(factoryAddress, lockAddress, owner);

        // Refund excess fee if any
        if (msg.value > deploymentFee) {
            (bool refundSuccess, ) = msg.sender.call{
                value: msg.value - deploymentFee
            }("");
            if (!refundSuccess) revert FeeOperationFailed("refund");
        }

        return (factoryAddress, lockAddress);
    }

    /**
     * @inheritdoc IFoundry
     */
    function updateImplementation(
        string calldata implementationType,
        address newImplementation
    ) external onlyOwner {
        if (newImplementation == address(0)) revert ZeroAddress();

        address oldImplementation;
        bytes32 implType = keccak256(bytes(implementationType));

        if (implType == keccak256(bytes("factory"))) {
            oldImplementation = factoryImplementation;
            factoryImplementation = newImplementation;
        } else if (implType == keccak256(bytes("lock"))) {
            oldImplementation = lockImplementation;
            lockImplementation = newImplementation;
        } else if (implType == keccak256(bytes("token"))) {
            oldImplementation = tokenImplementation;
            tokenImplementation = newImplementation;
        } else if (implType == keccak256(bytes("bondingCurve"))) {
            oldImplementation = bondingCurveImplementation;
            bondingCurveImplementation = newImplementation;
        } else {
            revert InvalidImplementationType(implementationType);
        }

        emit ImplementationUpdated(
            implementationType,
            oldImplementation,
            newImplementation
        );
    }

    /**
     * @inheritdoc IFoundry
     */
    function updateDeploymentFee(uint256 newFee) external onlyOwner {
        uint256 oldFee = deploymentFee;
        deploymentFee = newFee;
        emit DeploymentFeeUpdated(oldFee, newFee);
    }

    /**
     * @inheritdoc IFoundry
     */
    function withdrawFees(address recipient) external onlyOwner {
        if (recipient == address(0)) revert ZeroAddress();
        uint256 balance = address(this).balance;
        if (balance == 0) revert NoFeesToWithdraw();

        (bool success, ) = recipient.call{value: balance}("");
        if (!success) revert FeeOperationFailed("withdrawal");

        emit FeesWithdrawn(recipient, balance);
    }

    /**
     * @notice Pause the contract
     * @dev Only callable by owner
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause the contract
     * @dev Only callable by owner
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Required for the contract to receive ETH
     */
    receive() external payable {}
}