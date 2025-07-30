

import { computed, reactive, ref, watch } from "vue";


import { get } from "@vueuse/core";
import { getPublicClient, getWalletClient } from '@wagmi/core';
import { useAccount, useChainId, useConfig } from "@wagmi/vue";
import { BaseError, ContractFunctionRevertedError, erc20Abi, formatEther, zeroAddress } from "viem";
import { useI18n } from "vue-i18n";

import { isAddress, useTxHash } from "@/hooks/explorers.js";
import positionAbi from "@/hooks/positionManager.json";
import { camelToTitle } from "@/hooks/useCamelToTitle.js";



export const useReactiveContractCall = (
    abi,
    contract,
) => {
    const { address: account } = useAccount();
    const { t } = useI18n();
    const busy = ref(null);
    const error = ref(null);
    const simulation = ref(null);
    const called = ref(null);
    const status = ref('');
    const confirming = ref(false);
    const isConfirmed = ref(false);
    const receipt = ref(null);
    const txhash = ref(null);
    const [shortTx, etherScanLink] = useTxHash(txhash);
    const config = useConfig();
    const publicClient = getPublicClient(config);
    const call = async (method, args, value, txCallback) => {
        called.value = method;
        isConfirmed.value = false;
        error.value = null;
        receipt.value = null;
        txhash.value = null;
        confirming.value = false;
        busy.value = method;
        simulation.value = method;
        status.value = t('Sending Transaction ...');
        const walletClient = await getWalletClient(config);
        const response = await publicClient.simulateContract({
            address: get(contract),
            abi: get(abi),
            functionName: method,
            account: account.value,
            args,
            value: value ?? 0,
        }).catch((err) => {
            console.log(err);
            status.value = null;
            if (err instanceof BaseError) {
                const revertError = err.walk(err => err instanceof ContractFunctionRevertedError);
                if (revertError instanceof ContractFunctionRevertedError) {
                    const errorName = revertError.data?.errorName ?? '';
                    error.value = camelToTitle(errorName);
                    return;
                }
                return error.value = err.shortMessage;
            }
        });
        simulation.value = null;
        if (error.value || !response?.request) {
            busy.value = null;
            return;
        }
        txhash.value = await walletClient.writeContract(response.request).catch((err) => {
            error.value = err.shortMessage ?? err.detials;
        });
        if (error.value) {
            status.value = null;
            busy.value = null;
            return;
        }
        if (typeof txCallback === 'function') {
            txCallback(txhash.value);
        }
        confirming.value = true;
        status.value = t('Confirming Tx ...');
        receipt.value = await publicClient.waitForTransactionReceipt(
            { hash: txhash.value }
        );
        status.value = t('Tx Complete');
        confirming.value = false;
        isConfirmed.value = true;
        busy.value = null;
        setTimeout(() => {
            isConfirmed.value = false;
        }, 30000);
    };
    return reactive({
        error,
        txhash,
        busy,
        shortTx,
        tx: shortTx,
        txlink: etherScanLink,
        status,
        etherScanLink,
        confirming,
        isConfirmed,
        simulation,
        receipt,
        called,
        call
    });
};

export const useContractFees = (abi, address, functionName = 'fees') => {
    const publicClient = getPublicClient(useConfig());
    const fees = ref(0n);
    const feesFormatted = computed(() => formatEther(fees.value));
    const chainId = useChainId();
    const loadFees = async () => {
        fees.value = await publicClient.readContract({
            abi: get(abi),
            address: get(address),
            functionName,
        });
    };
    watch(
        [chainId, () => get(abi), () => get(address)],
        ([chainId, abi, address]) => {
            if (!chainId || !address || !abi) return;
            loadFees();
        },
        { immediate: true },
    );
    return {
        fees,
        feesFormatted
    };
};


export const useFactoryConfig = (abi, address, functionName = 'getBondingCurveSettings') => {
    const publicClient = getPublicClient(useConfig());
    const config = reactive({
        virtualEth: 0,
        preBondingTarget: 0,
        bondingTarget: 0,
        minContribution: 0,
        poolFee: 0,
        sellFee: 0,
        uniswapV3Factory: 0,
        positionManager: 0,
        weth: 0,
        feeTo: 0,
        load: async () => null
    });
    const chainId = useChainId();
    config.load = async () => {
        const response = await publicClient.readContract({
            abi,
            address: get(address),
            functionName,
        });
        config.virtualEth = formatEther(response.virtualEth);
        config.preBondingTarget = formatEther(response.preBondingTarget);
        config.bondingTarget = formatEther(response.bondingTarget);
        config.minContribution = formatEther(response.minContribution);
        config.poolFee = response.poolFee;
        config.sellFee = response.sellFee;
        config.uniswapV3Factory = response.uniswapV3Factory;
        config.positionManager = response.positionManager;
        config.weth = response.weth;
        config.feeTo = response.feeTo;
    };
    watch(
        chainId,
        (chainId) => {
            if (!chainId) return;
            if (!get(address)) return;
            config.load();
        },
        { immediate: true },
    );
    return config;
};

export const useLaunchpadInfo = (launchpad) => {
    const { address, chainId } = useAccount();
    const settings = reactive({
        owner: zeroAddress,
        isOwner: false,
        isFinalized: false,
        currentPhase: 0,
        balance: 0,
        updateBalance: () => null,
        updateInfo: () => null,
        updateTokenBalance: () => null,
        phase: null,
        totalPreBondingContributions: 0,
        totalETHCollected: 0,
        virtualEth: 0n,
        virtualEthFormatted: 0,
        preBondingTarget: 0,
        bondingTarget: 0,
        minContribution: 0,
        ethReserve: 0n,
        tokenReserve: 0n,
        tokenBalance: 0n,
        poolFee: 0,
        sellFee: 0,
        contributions: 0,
        tokenLocks: false,
        tokenAllocations: 0,
        uniswapV3Factory: zeroAddress,
        positionManager: zeroAddress,
        uniswapPool: zeroAddress,
        weth: zeroAddress,
        feeTo: zeroAddress
    });
    settings.phase = computed(() => {
        const phases = ['Prebonding', 'Bonding', 'Finalized'];
        return phases[settings.currentPhase] ?? 'Prebonding';
    });
    settings.isOwner = computed(() => `${settings.owner}`.toLowerCase() === `${address.value}`.toLowerCase());
    const publicClient = getPublicClient(useConfig());
    // balance
    settings.updateBalance = async () => {
        const response = await publicClient.readContract({
            abi: erc20Abi,
            address: get(launchpad.token),
            functionName: 'balanceOf',
            args: [settings.owner]
        });
        settings.balance = formatEther(response);
    };
    // balance
    settings.updateTokenBalance = async () => {
        const response = await publicClient.readContract({
            abi: erc20Abi,
            address: get(launchpad.token),
            functionName: 'balanceOf',
            args: [launchpad.contract]
        });
        settings.tokenBalance = response;
    };
    watch(() => settings.owner, (owner) => {
        if (owner !== zeroAddress)
            settings.updateBalance();
    }, { immediate: true });
    // contract
    settings.updateInfo = async () => {
        const bondingCurve = {
            address: launchpad.contract,
            abi: launchpad.factory.abi
        };
        const calls = {
            'uniswapPool': [],
            'owner': [],
            'isFinalized': [],
            'currentPhase': [],
            'totalETHCollected': [],
            'totalPreBondingContributions': [],
            'getBondingCurveSettings': [],
            'ethReserve': [],
            'tokenReserve': [],
            'contributions': [address.value],
            'tokenLocks': [address.value],
            'tokenAllocations': [address.value],
        };
        const results = await publicClient.multicall({
            contracts: Object.keys(calls).map((functionName) => ({
                ...bondingCurve,
                functionName,
                args: calls[functionName]
            }))
        });
        const [
            uniswapPool,
            owner,
            isFinalized,
            currentPhase,
            totalETHCollected,
            totalPreBondingContributions,
            getBondingCurveSettings,
            ethReserve,
            tokenReserve,
            contributions,
            tokenLocks,
            tokenAllocations
        ] = results;
        if (owner.status === 'success') {
            settings.owner = owner.result;
        } if (uniswapPool.status === 'success') {
            settings.uniswapPool = uniswapPool.result;
        }
        if (isFinalized.status === 'success') {
            settings.isFinalized = isFinalized.result;
        }
        if (currentPhase.status === 'success') {
            settings.currentPhase = currentPhase.result;
        }
        if (totalETHCollected.status === 'success') {
            settings.totalETHCollected = formatEther(totalETHCollected.result);
        }
        if (totalPreBondingContributions.status === 'success') {
            settings.totalPreBondingContributions = formatEther(totalPreBondingContributions.result);
        }
        if (ethReserve.status === 'success') {
            settings.ethReserve = ethReserve.result;
        }
        if (tokenReserve.status === 'success') {
            settings.tokenReserve = tokenReserve.result;
        }


        if (contributions.status === 'success') {
            settings.contributions = formatEther(contributions.result);
        }
        if (tokenLocks.status === 'success') {
            settings.tokenLocks = tokenLocks.result;
        }
        if (tokenAllocations.status === 'success') {
            settings.tokenAllocations = formatEther(tokenAllocations.result);
        }




        if (getBondingCurveSettings.status === 'success') {
            settings.virtualEth = getBondingCurveSettings.result.virtualEth;
            settings.virtualEthFormatted = formatEther(getBondingCurveSettings.result.virtualEth);
            settings.preBondingTarget = formatEther(getBondingCurveSettings.result.preBondingTarget);
            settings.bondingTarget = formatEther(getBondingCurveSettings.result.bondingTarget);
            settings.minContribution = formatEther(getBondingCurveSettings.result.minContribution);
            settings.poolFee = getBondingCurveSettings.result.poolFee / 10000;
            settings.sellFee = getBondingCurveSettings.result.sellFee / 10000;
            settings.uniswapV3Factory = isAddress(getBondingCurveSettings.result.uniswapV3Factory);
            settings.positionManager = isAddress(getBondingCurveSettings.result.positionManager);
            settings.weth = isAddress(getBondingCurveSettings.result.weth);
            settings.feeTo = isAddress(getBondingCurveSettings.result.feeTo);
        }
        await settings.updateTokenBalance();
    };

    watch(chainId, () => {
        settings.updateInfo();
    }, { immediate: true });

    return settings;
};


export const useLockInfo = (launchpad) => {
    const publicClient = getPublicClient(useConfig());
    const { address } = useAccount();
    const info = reactive({
        positionManager: zeroAddress,
        token: zeroAddress,
        lockContract: zeroAddress,
        lpTokenId: 0n,
        isFinalized: 0n,
        currentPhase: null,
        weth: zeroAddress,
        owner: zeroAddress,
        isLocked: true,
        lockedAt: 0n,
        unlocksAt: 0n,
        tokenFees: 0n,
        wethFees: 0n,
        stokenFees: 0n,
        swethFees: 0n,
        updateInfo: async () => null,
        updateCheckFees: async () => null,
    });

    info.updateInfo = async () => {
        const bondingCurve = {
            address: launchpad.contract,
            abi: launchpad.factory.abi
        };
        const calls = {
            'token': [],
            'lockContract': [],
            'lpTokenId': [],
            'isFinalized': [],
            'currentPhase': [],
            'getBondingCurveSettings': [],
        };
        const results = await publicClient.multicall({
            contracts: Object.keys(calls).map((functionName) => ({
                ...bondingCurve,
                functionName,
                args: calls[functionName]
            }))
        });
        const [
            token,
            lockContract,
            lpTokenId,
            isFinalized,
            currentPhase,
            getBondingCurveSettings,
        ] = results;
        if (token.status === 'success') {
            info.token = token.result;
        }
        if (lockContract.status === 'success') {
            info.lockContract = lockContract.result;
        }
        if (lpTokenId.status === 'success') {
            info.lpTokenId = lpTokenId.result;
        }
        if (isFinalized.status === 'success') {
            info.isFinalized = isFinalized.result;
        }
        if (currentPhase.status === 'success') {
            info.currentPhase = currentPhase.result;
        }
        if (getBondingCurveSettings.status === 'success') {
            info.positionManager = isAddress(getBondingCurveSettings.result.positionManager);
            info.weth = isAddress(getBondingCurveSettings.result.weth);
        }
        if (info.isFinalized)
            await info.updateCheckFees();
    };
    /**
     * use simulation
     */
    info.updateCheckFees = async () => {
        const [owner, , isLocked, lockedAt] = await publicClient.readContract({
            abi: launchpad.factory.lock_abi,
            address: launchpad.factory.lock,
            functionName: 'lockedNFTs',
            args: [info.lpTokenId]
        });
        info.owner = owner;
        info.isLocked = isLocked;
        info.lockedAt = lockedAt;
        info.unlocksAt = parseInt(lockedAt) + (60 * 60 * 24 * 365 * 10);
        const [, , token0] = await publicClient.readContract({
            abi: positionAbi,
            address: info.positionManager,
            functionName: 'positions',
            args: [info.lpTokenId]
        });
        // simulation method? // could revert!!!
        const result = await publicClient.simulateContract({
            account: address.value,
            abi: launchpad.factory.lock_abi,
            address: launchpad.factory.lock,
            functionName: 'claimFees',
            args: [info.lpTokenId]
        });

        if (`${token0}`.toLowerCase() === `${info.weth}`.toLocaleLowerCase()) {
            info.wethFees = formatEther(result.result[0]);
            info.tokenFees = formatEther(result.result[1]);
        } else {
            info.wethFees = formatEther(result.result[1]);
            info.tokenFees = formatEther(result.result[0]);
        }
    };
    const { chainId } = useAccount();
    watch(chainId, () => {
        info.updateInfo();
    }, { immediate: true });
    return info;
};
