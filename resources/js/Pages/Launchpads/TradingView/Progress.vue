<script setup>
import { computed } from "vue";

import { formatEther } from "viem";

import ChainSymbol from "@/Components/ChainSymbol.vue";
import usePriceInfo from "@/hooks/usePriceInfo";

const props = defineProps({
    launchpad: {
        type: Object,
        required: true,
    },
    usdRate: {
        type: [String, Number],
        required: true,
    },
});

const { info: priceInfo, formatted } = usePriceInfo(
    props.launchpad,
    props.usdRate,
);

// Computed properties for progress display
const progressLabel = computed(() => {
    switch (priceInfo.currentPhase) {
        case 0:
            return "Pre-Bonding Progress";
        case 1:
            return "Bonding Progress";
        case 2:
            return "Sale Complete";
        default:
            return "Progress";
    }
});

const currentProgress = computed(() => {
    return priceInfo.currentPhase === 0
        ? priceInfo.preBondingProgress
        : priceInfo.bondingProgress;
});

const currentProgressFormatted = computed(() => {
    return parseFloat(currentProgress.value).toFixed(2);
});

const currentAmountFormatted = computed(() => {
    const amount =
        priceInfo.currentPhase === 0
            ? priceInfo.totalPreBondingContributions
            : priceInfo.totalETHCollected;
    return formatEther(amount || 0n).toString();
});

const targetAmountFormatted = computed(() => {
    const target =
        priceInfo.currentPhase === 0
            ? priceInfo.preBondingTarget
            : priceInfo.bondingTarget;
    return formatEther(target || 0n).toString();
});

const showInitialPrice = computed(() => {
    // Only show initial price during pre-bonding and bonding phases
    return priceInfo.currentPhase < 2;
});
</script>
<template>
    <div>
        <!-- Progress Section -->
        <div class="mb-4">
            <div class="flex justify-between mb-2">
                <span class="text-gray-400">{{ progressLabel }}:</span>
                <div class="flex items-center gap-2">
                    <span class="text-green-400">
                        {{ currentProgressFormatted }}%
                    </span>
                    <span class="text-gray-500 text-sm">
                        ({{ currentAmountFormatted }} /
                        {{ targetAmountFormatted }}
                        <ChainSymbol :chain-id="launchpad.chainId" /> )
                    </span>
                </div>
            </div>
            <div class="bg-gray-800 rounded-full h-2">
                <div
                    class="bg-green-400 h-full rounded-full transition-all duration-300"
                    :style="{
                        width: `${Math.min(100, currentProgress)}%`,
                    }"
                ></div>
            </div>
        </div>

        <!-- Price and Market Cap -->
        <div class="grid grid-cols-2 gap-4 mb-4">
            <!-- Price Card -->
            <div class="bg-white/10 p-4 rounded-lg">
                <div class="text-gray-400 text-sm mb-1">
                    {{ $t("PRICE") }}
                    <span
                        v-if="priceInfo.isFinalized"
                        class="text-xs ml-1 text-blue-400"
                    >
                        (Uniswap V3)
                    </span>
                </div>
                <div class="text-xl font-semibold">
                    ${{ formatted.priceInUsd }}
                </div>
                <div
                    v-if="showInitialPrice"
                    class="text-sm text-gray-500 mt-1"
                >
                    {{ $t("Initial") }}: ${{ formatted.initialPriceUsd }}
                </div>
            </div>

            <!-- Market Cap Card -->
            <div class="bg-white/10 p-4 rounded-lg">
                <div class="text-gray-400 text-sm mb-1">
                    {{ $t("MARKET CAP") }}
                </div>
                <div class="text-xl font-semibold">
                    {{ formatted.currentMarketCap }}
                </div>
                <div class="text-sm text-gray-500 mt-1">
                    {{ $t("FDV") }}:
                    {{ formatted.fullyDilutedMarketCap }}
                </div>
            </div>
        </div>
        <slot :info="priceInfo"></slot>
    </div>
</template>
