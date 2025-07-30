import { computed, reactive, watch } from 'vue';

import { get } from '@vueuse/core';
import { getPublicClient } from '@wagmi/core';
import { useChainId, useConfig } from '@wagmi/vue';
import { formatEther } from 'viem';

// Uniswap V3 Pool ABI for price data
const POOL_ABI = [
    {
        "inputs": [],
        "name": "slot0",
        "outputs": [
            {
                "internalType": "uint160",
                "name": "sqrtPriceX96",
                "type": "uint160"
            },
            {
                "internalType": "int24",
                "name": "tick",
                "type": "int24"
            },
            {
                "internalType": "uint16",
                "name": "observationIndex",
                "type": "uint16"
            },
            {
                "internalType": "uint16",
                "name": "observationCardinality",
                "type": "uint16"
            },
            {
                "internalType": "uint16",
                "name": "observationCardinalityNext",
                "type": "uint16"
            },
            {
                "internalType": "uint8",
                "name": "feeProtocol",
                "type": "uint8"
            },
            {
                "internalType": "bool",
                "name": "unlocked",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    }
];

export const usePriceInfo = (launchpad, usdRate) => {
    const publicClient = getPublicClient(useConfig());
    const chainId = useChainId();
    const info = reactive({
        // Price metrics
        currentPrice: 0,
        priceInUsd: 0,
        initialPrice: 0,
        initialPriceUsd: 0,

        // Progress metrics
        preBondingProgress: 0,
        bondingProgress: 0,
        totalProgress: 0,

        // Market cap metrics
        currentMarketCap: 0,
        fullyDilutedMarketCap: 0,

        // Contract state
        isFinalized: false,
        currentPhase: 0,
        ethReserve: 0n,
        tokenReserve: 0n,
        totalPreBondingContributions: 0n,
        totalETHCollected: 0n,
        virtualEth: 0n,
        preBondingTarget: 0n,
        bondingTarget: 0n,
        uniswapPool: null,

        // Update function
        update: async () => {
            try {
                // Fetch all needed contract data in a single multicall
                const calls = {
                    'isFinalized': [],
                    'currentPhase': [],
                    'ethReserve': [],
                    'tokenReserve': [],
                    'totalPreBondingContributions': [],
                    'totalETHCollected': [],
                    'getBondingCurveSettings': [],
                    'uniswapPool': [],
                };

                const results = await publicClient.multicall({
                    contracts: Object.keys(calls).map((functionName) => ({
                        address: launchpad.contract,
                        abi: launchpad.factory.abi,
                        functionName,
                        args: calls[functionName]
                    }))
                });

                // Process results
                const [
                    isFinalized,
                    currentPhase,
                    ethReserve,
                    tokenReserve,
                    totalPreBondingContributions,
                    totalETHCollected,
                    settings,
                    uniswapPool
                ] = results;

                // Update state with contract data
                if (isFinalized.status === 'success') info.isFinalized = isFinalized.result;
                if (currentPhase.status === 'success') info.currentPhase = currentPhase.result;
                if (ethReserve.status === 'success') info.ethReserve = ethReserve.result;
                if (tokenReserve.status === 'success') info.tokenReserve = tokenReserve.result;
                if (totalPreBondingContributions.status === 'success') {
                    info.totalPreBondingContributions = totalPreBondingContributions.result;
                }
                if (totalETHCollected.status === 'success') info.totalETHCollected = totalETHCollected.result;
                if (settings.status === 'success') {
                    info.virtualEth = settings.result.virtualEth;
                    info.preBondingTarget = settings.result.preBondingTarget;
                    info.bondingTarget = settings.result.bondingTarget;
                }
                if (uniswapPool.status === 'success') info.uniswapPool = uniswapPool.result;

                // Calculate price based on phase and finalization status
                if (info.isFinalized && info.uniswapPool) {
                    try {
                        // Get price from Uniswap pool
                        const poolData = await publicClient.readContract({
                            address: info.uniswapPool,
                            abi: POOL_ABI,
                            functionName: 'slot0'
                        });

                        // Get sqrtPriceX96 from slot0
                        const sqrtPriceX96 = poolData[0];

                        // Convert sqrtPriceX96 to price
                        // For token1/token0 price: (sqrtPriceX96 ** 2) * (1e18) / (2 ** 192)
                        const price = (BigInt(sqrtPriceX96) * BigInt(sqrtPriceX96) * BigInt(1e18)) / (2n ** 192n);

                        // If token0 is WETH, we need to invert the price
                        const token0 = await publicClient.readContract({
                            address: info.uniswapPool,
                            abi: [{
                                "inputs": [],
                                "name": "token0",
                                "outputs": [{ "type": "address" }],
                                "stateMutability": "view",
                                "type": "function"
                            }],
                            functionName: 'token0'
                        });

                        // Get settings for WETH address comparison
                        const settings = await publicClient.readContract({
                            address: launchpad.contract,
                            abi: launchpad.factory.abi,
                            functionName: 'getBondingCurveSettings'
                        });

                        // Determine if we need to invert the price
                        const wethIsToken0 = token0.toLowerCase() === settings.weth.toLowerCase();

                        if (wethIsToken0) {
                            // If WETH is token0, we need the reciprocal
                            info.currentPrice = 1 / Number(formatEther(price));
                        } else {
                            // If WETH is token1, use price directly
                            info.currentPrice = Number(formatEther(price));
                        }

                    } catch (error) {
                        console.error('Error calculating Uniswap price:', error);
                        // Fallback to reserve-based price if Uniswap calculation fails
                        if (info.ethReserve && info.tokenReserve) {
                            info.currentPrice = Number(formatEther(info.ethReserve)) / Number(formatEther(info.tokenReserve));
                        }
                    }
                } else {
                    // Calculate price from reserves
                    if (info.ethReserve && info.tokenReserve) {
                        info.currentPrice = Number(formatEther(info.ethReserve)) / Number(formatEther(info.tokenReserve));
                    }
                }

                // Update USD price
                info.priceInUsd = info.currentPrice * Number(usdRate);

                // Calculate initial price from virtual ETH
                if (info.virtualEth) {
                    info.initialPrice = Number(formatEther(info.virtualEth)) / 1000000000; // 1B total supply
                    info.initialPriceUsd = info.initialPrice * Number(usdRate);
                }

                // Calculate progress
                if (info.preBondingTarget) {
                    info.preBondingProgress = (Number(formatEther(info.totalPreBondingContributions)) /
                        Number(formatEther(info.preBondingTarget))) * 100;
                }

                if (info.bondingTarget) {
                    info.bondingProgress = (Number(formatEther(info.totalETHCollected)) /
                        Number(formatEther(info.bondingTarget))) * 100;
                }

                info.totalProgress = Math.min(100, Math.max(info.preBondingProgress, info.bondingProgress));

                // Calculate market caps
                if (info.tokenReserve && info.priceInUsd) {
                    info.currentMarketCap = Number(formatEther(info.tokenReserve)) * info.priceInUsd;
                    info.fullyDilutedMarketCap = 1000000000 * info.priceInUsd;
                }
            } catch (error) {
                console.error('Error updating price info:', error);
            }
        }
    });

    // Create computed properties for formatted values
    const formatted = computed(() => ({
        currentPrice: info.currentPrice.toFixed(6),
        priceInUsd: info.priceInUsd.toFixed(6),
        initialPrice: info.initialPrice.toFixed(6),
        initialPriceUsd: info.initialPriceUsd.toFixed(6),
        preBondingProgress: Math.min(100, info.preBondingProgress).toFixed(2),
        bondingProgress: Math.min(100, info.bondingProgress).toFixed(2),
        totalProgress: Math.min(100, info.totalProgress).toFixed(2),
        currentMarketCap: info.currentMarketCap.toLocaleString('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        }),
        fullyDilutedMarketCap: info.fullyDilutedMarketCap.toLocaleString('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        })
    }));

    // Watch for chain changes and update data
    watch(chainId, () => {
        if (chainId.value) {
            info.update();
        }
    }, { immediate: true });

    // Update when USD rate changes
    watch(() => get(usdRate), () => {
        info.update();
    }, { immediate: true });

    return {
        info,
        formatted
    };
};

export default usePriceInfo;