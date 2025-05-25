// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library BondingMath {
    uint256 private constant PRECISION = 1e18;

    function calculateTokensForETH(
        uint256 ethReserve,
        uint256 tokenReserve,
        uint256 ethIn
    ) internal pure returns (uint256) {
        uint256 numerator = ethIn * tokenReserve;
        uint256 denominator = ethReserve + ethIn;
        return numerator / denominator;
    }

    function calculateETHForTokens(
        uint256 ethReserve,
        uint256 tokenReserve,
        uint256 tokenIn,
        uint256 sellFee
    ) internal pure returns (uint256 ethOut, uint256 fee) {
        uint256 numerator = tokenIn * ethReserve;
        uint256 denominator = tokenReserve + tokenIn;
        ethOut = numerator / denominator;
        if (sellFee > 0) {
            fee = (ethOut * sellFee) / 10000;
            ethOut -= fee;
        }
    }

    function getCurrentPrice(
        uint256 ethReserve,
        uint256 tokenReserve
    ) internal pure returns (uint256) {
        return (ethReserve * PRECISION) / tokenReserve;
    }
}