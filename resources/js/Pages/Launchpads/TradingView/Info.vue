<script setup>
import { computed } from "vue";

import { Globe2 } from "lucide-vue-next";
import { DiscordIcon, TelegramIcon, XIcon } from "vue3-simple-icons";

import AddressLink from "@/Components/AddressLink.vue";
import BaseButton from "@/Components/BaseButton.vue";
import ChainSymbol from "@/Components/ChainSymbol.vue";
import NetworkIcon from "@/Icons/NetworkIcon.vue";
import { networks, shortenAddress } from "@/lib/wagmi";
import Progress from "@/Pages/Launchpads/TradingView/Progress.vue";
import TradingStats from "@/Pages/Launchpads/TradingView/TradingStats.vue";
import UniswapGraph from "@/Pages/Launchpads/TradingView/UniswapGraph.vue";
const props = defineProps({
    launchpad: Object,
    rank: Number,
    rate: Object,
    totalVolume: Number,
    totalLaunchpads: Number,
});
const chain = computed(() =>
    networks.find((c) => c.id === parseInt(props.launchpad.chainId)),
);
</script>
<template>
    <div class="text-white rounded-lg">
        <!-- Header -->
        <div class="flex items-center gap-2 mb-4">
            <span class="font-semibold">{{ launchpad.symbol }}</span>
            <span class="text-gray-400">/</span>
            <span class="font-semibold">
                <ChainSymbol :chainId="launchpad.chainId" />
            </span>
            <span class="bg-green-900 text-green-400 text-xs px-1 rounded">
                1h
            </span>
            <span class="text-orange-500">#{{ rank }}</span>
        </div>

        <!-- Platform Info -->
        <div class="flex items-center gap-2 mb-4">
            <NetworkIcon
                class="rounded-full w-6 h-6"
                :chainId="launchpad.chainId"
            />
            <span>{{ chain.name }}</span>
            <span class="text-gray-400">></span>
            <span class="bg-primary rounded-full w-6 h-6"></span>
            <span>{{ launchpad.name }}</span>
        </div>

        <!-- Telegram Button -->
        <div class="flex items-center gap-3 my-4">
            <BaseButton
                url
                :href="launchpad.twitter"
                :disabled="!launchpad.twitter"
                target="_blank"
                secondary
                class="bg-white/10 rounded-lg"
            >
                <XIcon class="w-4 h-4" />
            </BaseButton>
            <BaseButton
                url
                :href="launchpad.telegram"
                :disabled="!launchpad.telegram"
                target="_blank"
                secondary
                class="bg-white/10 rounded-lg"
            >
                <TelegramIcon class="w-4 h-4" />
            </BaseButton>
            <BaseButton
                url
                :href="launchpad.discord"
                target="_blank"
                :disabled="!launchpad.discord"
                secondary
                class="bg-white/10 rounded-lg"
            >
                <DiscordIcon class="w-4 h-4" />
            </BaseButton>
            <BaseButton
                url
                target="_blank"
                :href="launchpad.website"
                :disabled="!launchpad.website"
                secondary
                class="bg-white/10 rounded-lg"
            >
                <Globe2 class="w-4 h-4" />
            </BaseButton>
            <BaseButton
                secondary
                class="bg-white/10 rounded-lg ml-auto"
            >
                {{ launchpad.holders_count }} Holders
            </BaseButton>
        </div>

        <!-- Progress Bar -->
        <Progress
            :launchpad="launchpad"
            :usdRate="rate.usd_rate"
            v-slot="{ info }"
        >
            <UniswapGraph
                v-if="info.isFinalized"
                :price-changes="$page.props.poolstats?.priceChanges"
                :stats="$page.props.poolstats?.stats"
            />
            <TradingStats
                v-else
                :stats="$page.props.report"
            />
        </Progress>

        <!-- Time Stats -->

        <!-- Alerts Button -->
        <div class="grid gap-3 mt-5 rounded-lg bg-white/10 pt-4">
            <div class="px-4">
                <a
                    :href="$page.props.links?.tgChannel ?? '#'"
                    target="_blank"
                    class="w-full bg-gray-750 px-4 py-2 rounded-lg mb-4 flex justify-center items-center gap-2"
                >
                    <span>🔔</span>
                    <span>{{ $t("Telegram Alerts") }}</span>
                </a>
            </div>
            <!-- Footer Info -->
            <div class="divide-y divide-gray-750 text-sm">
                <div class="flex justify-between pb-1 px-4 items-center">
                    <span class="text-gray-400">{{ $t("Token created") }}</span>
                    <span>{{ launchpad.createdAgo }}</span>
                </div>
                <div class="flex justify-between py-1 px-4 items-center">
                    <span class="text-gray-400">{{ $t("Creator") }}</span>
                    <div class="flex items-center gap-2">
                        <span class="bg-gray-750 px-2 py-1 rounded">
                            {{ shortenAddress(launchpad.user.address) }}
                        </span>
                        <button class="bg-gray-750 px-2 py-1 rounded">
                            HLD
                        </button>
                        <AddressLink
                            :chainId="launchpad.chainId"
                            :address="launchpad.user.address"
                            v-slot="{ etherScanLink }"
                        >
                            <a
                                :href="etherScanLink"
                                target="_blank"
                                class="bg-gray-750 px-2 py-1 rounded"
                            >
                                EXP
                            </a>
                        </AddressLink>
                    </div>
                </div>
                <div class="flex justify-between py-1 px-4 items-center">
                    <span class="text-gray-400">{{ launchpad.symbol }}</span>
                    <div class="flex items-center gap-2">
                        <span class="bg-gray-750 px-2 py-1 rounded">
                            {{ shortenAddress(launchpad.token) }}
                        </span>
                        <button class="bg-gray-750 px-2 py-1 rounded">
                            HLD
                        </button>
                        <AddressLink
                            :chainId="launchpad.chainId"
                            :address="launchpad.token"
                            v-slot="{ etherScanLink }"
                        >
                            <a
                                :href="etherScanLink"
                                target="_blank"
                                class="bg-gray-750 px-2 py-1 rounded"
                            >
                                EXP
                            </a>
                        </AddressLink>
                    </div>
                </div>
                <div
                    v-if="launchpad.pool"
                    class="flex justify-between items-center py-1 px-4"
                >
                    <span class="text-gray-400">{{ launchpad.symbol }}</span>
                    <div class="flex items-center gap-2">
                        <span class="bg-gray-750 px-2 py-1 rounded">
                            {{ shortenAddress(launchpad.pool) }}
                        </span>
                        <button class="bg-gray-750 px-2 py-1 rounded">
                            HLD
                        </button>
                        <AddressLink
                            :chainId="launchpad.chainId"
                            :address="launchpad.pool"
                            v-slot="{ etherScanLink }"
                        >
                            <a
                                :href="etherScanLink"
                                target="_blank"
                                class="bg-gray-750 px-2 py-1 rounded"
                            >
                                EXP
                            </a>
                        </AddressLink>
                    </div>
                </div>
                <div class="flex justify-between items-center py-1 px-4">
                    <span class="text-gray-400">{{ $t("Migration DEX") }}</span>
                    <span>Uniswap V3</span>
                </div>
            </div>
        </div>
    </div>
</template>
