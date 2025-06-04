// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "../interfaces/UniswapV3Interfaces.sol";

library UniswapPoolCreator {
    uint256 private constant Q96 = 2 ** 96;

    // Uniswap v3 tick range limits
    int24 private constant MIN_TICK = -887272;
    int24 private constant MAX_TICK = 887272;
    int24 private constant TICK_SPACING = 60;

    struct PoolParams {
        address factory;
        address token;
        address weth;
        uint24 fee;
        uint256 ethReserve;
        uint256 tokenReserve;
    }

    struct PositionParams {
        address positionManager;
        address token;
        address weth;
        uint24 fee;
        uint256 ethAmount;
        uint256 tokenAmount;
    }

    function createAndInitializePool(
        PoolParams memory params
    ) internal returns (address pool) {
        IUniswapV3Factory factory = IUniswapV3Factory(params.factory);
        pool = factory.createPool(params.token, params.weth, params.fee);
        uint160 sqrtPriceX96 = uint160(
            Math.sqrt((params.ethReserve * Q96) / params.tokenReserve) *
                Math.sqrt(Q96)
        );
        IUniswapV3Pool(pool).initialize(sqrtPriceX96);
    }

    function createLPPosition(
        PositionParams memory params
    ) internal returns (uint256 tokenId) {
        // Round to the nearest tick spacing
        int24 minTick = (MIN_TICK / TICK_SPACING) * TICK_SPACING;
        int24 maxTick = (MAX_TICK / TICK_SPACING) * TICK_SPACING;
        // Calculate minimum amounts with 50% slippage tolerance
        uint256 amount0Min = (params.tokenAmount * 90) / 100;
        uint256 amount1Min = (params.ethAmount * 90) / 100;
        bool tokenIs0 = params.token < params.weth;
        INonfungiblePositionManager.MintParams
            memory mintParams = INonfungiblePositionManager.MintParams({
                token0: tokenIs0 ? params.token : params.weth,
                token1: tokenIs0 ? params.weth : params.token,
                fee: params.fee,
                tickLower: minTick,
                tickUpper: maxTick,
                amount0Desired: tokenIs0
                    ? params.tokenAmount
                    : params.ethAmount,
                amount1Desired: tokenIs0
                    ? params.ethAmount
                    : params.tokenAmount,
                amount0Min: tokenIs0 ? amount0Min : amount1Min,
                amount1Min: tokenIs0 ? amount1Min : amount0Min,
                recipient: address(this),
                deadline: block.timestamp
            });

        (tokenId, , , ) = INonfungiblePositionManager(params.positionManager)
            .mint{value: params.ethAmount}(mintParams);
    }
}