// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IFactory.sol";
import "./interfaces/IBondingCurve.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";

/**
 * @title Factory
 * @notice Factory contract for deploying bonding curve systems
 * @dev Implements minimal proxy pattern for gas-efficient deployment
 */
contract Factory is
    IFactory,
    Initializable,
    Ownable2StepUpgradeable,
    ReentrancyGuardUpgradeable
{
    using Clones for address;

    // State variables
    address private tokenImplementation;
    address private bondingCurveImplementation;
    address private lockContract;
    uint256 private deploymentFee;
    BondingCurveSettings private settings;
    // Deployment tracking
    mapping(address => address) private tokenToBondingCurve;
    mapping(address => address) private bondingCurveToToken;

    /**
     * @dev Constructor is disabled since this contract is meant to be used behind a proxy
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @inheritdoc IFactory
     */
    function initialize(
        uint256 factoryFees,
        address owner,
        address tokenImpl,
        address bondingCurveImpl,
        address lockContractAddr,
        BondingCurveSettings calldata initialSettings
    ) external initializer {
        if (owner == address(0)) revert ZeroAddress();
        if (tokenImpl == address(0)) revert ZeroAddress();
        if (bondingCurveImpl == address(0)) revert ZeroAddress();
        if (lockContractAddr == address(0)) revert ZeroAddress();

        __Ownable_init(owner);
        __ReentrancyGuard_init();

        tokenImplementation = tokenImpl;
        bondingCurveImplementation = bondingCurveImpl;
        lockContract = lockContractAddr;
        settings = initialSettings;
        settings.preBondingTarget = (initialSettings.virtualEth * 20) / 100;
        if (settings.bondingTarget <= settings.preBondingTarget)
            revert InvalidDeploymentParameters();
        deploymentFee = factoryFees;
    }

    function updateBondingCurveSettings(
        BondingCurveSettings calldata newSettings
    ) external onlyOwner {
        // Update settings
        settings = newSettings;
        settings.preBondingTarget = (newSettings.virtualEth * 20) / 100;
        if (settings.bondingTarget <= settings.preBondingTarget)
            revert InvalidDeploymentParameters();
        emit BondingCurveSettingsUpdated(
            newSettings.virtualEth,
            newSettings.preBondingTarget,
            newSettings.bondingTarget,
            newSettings.minContribution,
            newSettings.poolFee
        );
    }

    function getBondingCurveSettings()
        external
        view
        returns (BondingCurveSettings memory)
    {
        return settings;
    }

    /**
     * @inheritdoc IFactory
     */
    function deployBondingCurveSystem(
        string calldata name,
        string calldata symbol
    )
        external
        payable
        nonReentrant
        returns (address tokenAddress, address bondingCurveAddress)
    {
        // Validate deployment fee
        if (msg.value < deploymentFee) {
            revert InsufficientDeploymentFee(msg.value, deploymentFee);
        }

        // Validate parameters
        if (bytes(name).length == 0 || bytes(symbol).length == 0) {
            revert InvalidDeploymentParameters();
        }

        // Deploy token contract
        tokenAddress = tokenImplementation.clone();

        // Initialize token with  _msgSender() as owner
        (bool tokenSuccess, ) = tokenAddress.call(
            abi.encodeWithSignature("initialize(string,string)", name, symbol)
        );
        if (!tokenSuccess) revert InitializationFailed();

        // Deploy bonding curve contract
        bondingCurveAddress = bondingCurveImplementation.clone();

        // Initialize bonding curve
        IBondingCurve(bondingCurveAddress).initialize(
            tokenAddress,
            lockContract,
            _msgSender(),
            settings
        );

        // Mint total supply to the bonding curve contract
        (bool mintSuccess, ) = tokenAddress.call(
            abi.encodeWithSignature(
                "mintTotalSupply(address)",
                bondingCurveAddress
            )
        );
        if (!mintSuccess) revert TokenMintingFailed();

        // Store the relationship between token and bonding curve
        tokenToBondingCurve[tokenAddress] = bondingCurveAddress;
        bondingCurveToToken[bondingCurveAddress] = tokenAddress;

        emit BondingCurveSystemDeployed(
            bondingCurveAddress,
            tokenAddress,
            _msgSender(),
            name,
            symbol
        );

        // Refund excess deployment fee
        if (msg.value > deploymentFee) {
            (bool refundSuccess, ) = _msgSender().call{
                value: msg.value - deploymentFee
            }("");
            if (!refundSuccess) revert RefundFailed();
        }

        return (tokenAddress, bondingCurveAddress);
    }

    /**
     * @inheritdoc IFactory
     */
    function updateDeploymentFee(uint256 newFee) external onlyOwner {
        uint256 oldFee = deploymentFee;
        deploymentFee = newFee;
        emit DeploymentFeeUpdated(oldFee, newFee);
    }

    /**
     * @inheritdoc IFactory
     */
    function withdrawFees(address recipient) external onlyOwner {
        if (recipient == address(0)) revert ZeroAddress();

        uint256 balance = address(this).balance;
        if (balance == 0) revert NoFeesToWithdraw();

        (bool success, ) = recipient.call{value: balance}("");
        if (!success) revert FeeWithdrawalFailed();

        emit FeesWithdrawn(recipient, balance);
    }

    /**
     * @inheritdoc IFactory
     */
    function getDeploymentFee() external view returns (uint256) {
        return deploymentFee;
    }

    /**
     * @inheritdoc IFactory
     */
    function getTokenImplementation() external view returns (address) {
        return tokenImplementation;
    }

    /**
     * @inheritdoc IFactory
     */
    function getBondingCurveImplementation() external view returns (address) {
        return bondingCurveImplementation;
    }

    /**
     * @inheritdoc IFactory
     */
    function getLockContract() external view returns (address) {
        return lockContract;
    }

    /**
     * @notice Get the bonding curve address associated with a token
     * @param token The token address to query
     * @return The associated bonding curve address
     */
    function getBondingCurveForToken(
        address token
    ) external view returns (address) {
        return tokenToBondingCurve[token];
    }

    /**
     * @notice Get the token address associated with a bonding curve
     * @param bondingCurve The bonding curve address to query
     * @return The associated token address
     */
    function getTokenForBondingCurve(
        address bondingCurve
    ) external view returns (address) {
        return bondingCurveToToken[bondingCurve];
    }

    /**
     * @dev Required for the contract to receive ETH
     */
    receive() external payable {}
}