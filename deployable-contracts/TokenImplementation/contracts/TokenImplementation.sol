// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title TokenImplementation
 * @notice Implementation of the ERC20 token with one-time mint capability
 * @dev Deployed via minimal proxy pattern with fixed total supply
 */
contract TokenImplementation is Initializable, ERC20Upgradeable {
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 * 10 ** 18; // 1 billion tokens with 18 decimals
    bool private _minted;
    address public factory;

    /// @notice Thrown when attempting to mint tokens more than once
    error AlreadyMinted();

    /// @notice Thrown when an address parameter is zero
    error ZeroAddress();

    /// @notice Thrown when caller is not the factory
    error OnlyFactory();

    /// @notice Emitted when the initial token supply is minted
    event InitialMintCompleted(address indexed recipient, uint256 amount);

    /**
     * @dev Constructor disabled since this contract is meant to be used behind a proxy
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initialize the token contract
     * @param name_ Token name
     * @param symbol_ Token symbol
     */
    function initialize(
        string memory name_,
        string memory symbol_
    ) external initializer {
        __ERC20_init(name_, symbol_);
        factory = msg.sender;
        _minted = false;
    }

    /**
     * @notice Mint the total supply of tokens to a specified address
     * @dev Can only be called once by the factory
     * @param to Address to receive the minted tokens
     */
    function mintTotalSupply(address to) external {
        if (msg.sender != factory) revert OnlyFactory();
        if (_minted) revert AlreadyMinted();
        if (to == address(0)) revert ZeroAddress();

        _mint(to, TOTAL_SUPPLY);
        _minted = true;

        emit InitialMintCompleted(to, TOTAL_SUPPLY);
    }

    /**
     * @notice Check if the total supply has been minted
     * @return Boolean indicating if tokens have been minted
     */
    function isMinted() external view returns (bool) {
        return _minted;
    }

    /**
     * @notice Override to prevent transfers when tokens haven't been minted
     * @param from The sender's address
     * @param to The recipient's address
     * @param amount The amount to transfer
     */
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (!_minted && from != address(0))
            revert("Transfers disabled before mint");
        super._update(from, to, amount);
    }
}
