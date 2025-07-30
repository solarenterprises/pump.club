<script setup>
import { onMounted, ref } from "vue";

import { MessageSquare, TvMinimalPlay, UsersRound, Copy, User, Users, TrendingUp, Crown, MessageCircle, Braces, Crosshair, Heart, ArrowDownLeft } from "lucide-vue-next";
import { RiExchangeLine } from "oh-vue-icons/icons";
import Chat from "@/Pages/Launchpads/Chat.vue";
import BuyCard from "@/Pages/Launchpads/TradingView/BuyCard.vue";
import DevStream from "@/Pages/Launchpads/TradingView/DevStream.vue";
import Holders from "@/Pages/Launchpads/TradingView/Holders.vue";
import Info from "@/Pages/Launchpads/TradingView/Info.vue";
import LockCard from "@/Pages/Launchpads/TradingView/LockCard.vue";
import Trades from "@/Pages/Launchpads/TradingView/Trades.vue";
import AdvancedLayout from "@/Layouts/AdvancedLayout.vue";
import { ADVANCED_TABS } from '@/store/constants';
import AdvancedTradingViewChart from "./TradingView/AdvancedTradingViewChart.vue";
import { ScrollArea } from "@/Components/ui/scroll-area";

defineProps({
    launchpad: Object,
    top: Array,
    stats: Object,
    rate: Object,
    poolstats: Object,
});

const tabs = [
    { name: "Trades", icon: RiExchangeLine, vueicon: true },
    { name: "Holders", icon: UsersRound },
    { name: "Dev Stream", icon: TvMinimalPlay },
];

const activeTab = ref("Trades");
const selectedTab = ref('coin-chart');

const navHeight = ref(90);
const navRef = ref(null);

onMounted(() => {
    if (navRef.value) {
        navHeight.value = navRef.value.offsetHeight;
    }
});

const coinTabs = [
    { label: 'Coin Details', value: 'coin-details' },
    { label: 'Similar Coins', value: 'similar-coins' }
];
const coinTab = ref('coin-details');
function copyContract(contract) {
    navigator.clipboard.writeText(contract);
}
</script>

<template>
    <AdvancedLayout>
        <div class="flex flex-col flex-1">
            <div class="w-full h-full flex flex-col flex-1">
                <div class="flex-row justify-between items-stretch border-b border-white/10 grid grid-cols-5">
                    <div class="flex flex-col gap-2 col-span-4 p-3 border-r border-white/10">
                        <div class="flex flex-row gap-2">
                            <button v-for="tab in ADVANCED_TABS" :key="tab.value" :class="[
                                'px-3 py-1 rounded-full font-normal transition text-sm',
                                selectedTab === tab.value
                                    ? 'bg-white/4 text-white'
                                    : 'bg-transparent text-gray-400 hover:text-white'
                            ]" @click="selectedTab = tab.value">
                                {{ tab.label }}
                            </button>
                        </div>
                        <div class="h-4/8 w-full">
                            <AdvancedTradingViewChart :launchpad="launchpad" />
                        </div>
                    </div>

                    <div class="flex flex-row justify-between col-span-1">
                        <div class="flex flex-col w-full items-stretch justify-between h-full">
                            <div class="w-full p-3">
                                <!-- Tabs -->
                                <div class="flex gap-2 mb-4">
                                    <button v-for="tab in coinTabs" :key="tab.value" @click="coinTab = tab.value"
                                        :class="[
                                            'px-4 py-1 rounded-full font-medium transition',
                                            coinTab === tab.value
                                                ? 'bg-white/4 text-white'
                                                : 'bg-transparent text-gray-400 hover:text-white'
                                        ]">
                                        {{ tab.label }}
                                    </button>
                                </div>
                                <!-- Coin Details Tab -->
                                <div>
                                    <div class="flex items-center gap-4 mb-2">
                                        <div class="relative">
                                            <img :src="launchpad.logo"
                                                class="w-16 h-16 rounded-xl border-2 border-orange-500 shadow-lg object-cover" />
                                        </div>
                                        <div>
                                            <div class="text-white font-semibold text-xl flex items-center gap-2">
                                                {{ launchpad.name }}
                                                <span class="text-gray-400 text-base font-normal">{{
                                                    launchpad.symbol
                                                    }}</span>
                                            </div>
                                            <div
                                                class="flex items-center gap-1 bg-white/10 text-xs text-gray-300 rounded-lg px-2 py-1 mt-1 w-fit">
                                                {{ launchpad.contract?.slice(0, 6) }}...{{
                                                    launchpad.contract?.slice(-3)
                                                }}
                                                <Copy class="w-3 h-3 ml-1 cursor-pointer"
                                                    @click="copyContract(launchpad.contract)" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="text-gray-400 text-xs mb-2 uppercase tracking-wide leading-snug">
                                        {{ launchpad.description }}
                                    </div>
                                    <div class="w-full h-2 bg-white/10 rounded-full mb-2">
                                        <div class="h-2 bg-orange-500 rounded-full" :style="{ width: '60%' }"></div>
                                    </div>
                                    <div class="text-white text-sm mb-4">ATH: ${{ poolstats?.stats?.maxPrice ?? '0'
                                        }}
                                    </div>
                                    <!-- Badges -->
                                    <div class="flex flex-row items-center gap-2 justify-between">
                                        <div class="flex items-center gap-2 mt-2 flex-wrap">
                                            <span
                                                class="flex items-center border-white/50 border text-white/50 rounded-lg px-1 py-0.5 text-xs font-normal">
                                                {{ launchpad.stat1 || 139 }}
                                                <User class="w-3 h-3 ml-1 text-[#DA5200]" />
                                            </span>
                                            <span
                                                class="flex items-center border-white/50 border text-white/50 rounded-lg px-1 py-0.5 text-xs font-normal">
                                                {{ launchpad.stat2 || 139 }}
                                                <Crosshair class="w-3 h-3 ml-1 text-[#DA5200]" />
                                            </span>
                                            <span
                                                class="flex items-center border-white/50 border text-white/50 rounded-lg px-1 py-0.5 text-xs font-normal">
                                                {{ launchpad.stat3 || 139 }}
                                                <Braces class="w-3 h-3 ml-1 text-[#DA5200]" />
                                            </span>
                                            <span
                                                class="flex items-center border-white/50 border text-white/50 rounded-lg px-1 py-0.5 text-xs font-normal">
                                                {{ launchpad.stat4 || 139 }}
                                                <Crown class="w-3 h-3 ml-1 text-[#DA5200]" />
                                            </span>
                                            <span
                                                class="flex items-center border-white/50 border text-white/50 rounded-lg px-1 py-0.5 text-xs font-normal">
                                                {{ launchpad.stat4 || 139 }}
                                                <MessageCircle class="w-3 h-3 ml-1 text-[#DA5200]" />
                                            </span>
                                        </div>
                                    </div>
                                    <!-- Stats and Price Change Table -->
                                </div>
                                <!-- Similar Coins Tab -->
                            </div>
                            <div class="w-full">
                                <!-- Top row: only vertical (middle) borders -->
                                <div class="grid grid-cols-4 border-t border-b border-white/20">
                                    <div class="p-2 text-center">
                                        <div class="text-white text-sm">4m ago</div>
                                        <div class="text-gray-400 text-xs">created</div>
                                    </div>
                                    <div class="border-l border-white/20 p-2 text-center">
                                        <div class="text-white text-sm">$0.054</div>
                                        <div class="text-gray-400 text-xs">price USD</div>
                                    </div>
                                    <div class="border-l border-white/20 p-2 text-center">
                                        <div class="text-white text-sm">$4.5k</div>
                                        <div class="text-gray-400 text-xs">market cap</div>
                                    </div>
                                    <div class="border-l border-white/20 p-2 text-center">
                                        <div class="text-white text-sm">$4.3k</div>
                                        <div class="text-gray-400 text-xs">volume</div>
                                    </div>
                                </div>
                                <!-- Bottom row: only vertical (middle) borders -->
                                <div class="grid grid-cols-4">
                                    <div class="p-2 text-center">
                                        <div class="text-red-400 text-sm">-2.90%</div>
                                        <div class="text-gray-400 text-xs">5min</div>
                                    </div>
                                    <div class="border-l border-white/20 p-2 text-center">
                                        <div class="text-red-400 text-sm">-2.90%</div>
                                        <div class="text-gray-400 text-xs">1H</div>
                                    </div>
                                    <div class="border-l border-white/20 p-2 text-center">
                                        <div class="text-red-400 text-sm">-2.90%</div>
                                        <div class="text-gray-400 text-xs">6H</div>
                                    </div>
                                    <div class="border-l border-white/20 p-2 text-center">
                                        <div class="text-red-400 text-sm">-2.90%</div>
                                        <div class="text-gray-400 text-xs">24H</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="flex-row justify-between items-stretch grid grid-cols-5 flex-1">
                    <div class="flex col-span-2 flex-col border-r border-white/10">
                        <div class="flex h-fit p-3">
                            <div class="flex justify-between rounded-full p-1 gap-1 overflow-x-auto w-full md:w-fit">
                                <button v-for="tab in tabs" :key="tab.name" @click="activeTab = tab.name" :class="[
                                    'md:px-7 px-2 py-2 text-sm md:text-base font-normal focus:outline-none transition-all',
                                    activeTab === tab.name
                                        ? 'bg-white/4 text-white shadow rounded-full'
                                        : 'bg-transparent text-gray-400 rounded-full hover:text-white'
                                ]">
                                    {{ tab.name }}
                                </button>
                            </div>
                        </div>

                        <div class="text-gray-300 grid gap-1 relative h-full">
                            <div class="absolute inset-0 px-3">
                                <ScrollArea class="h-full">
                                    <Trades :trades="$page.props.trades" :chainId="launchpad.chainId"
                                        :bcurve="launchpad.contract" v-if="activeTab == 'Trades'" />
                                    <Holders :holders="$page.props.holders" :chainId="launchpad.chainId"
                                        :launchpad="launchpad" :usdRate="rate.usd_rate" v-if="activeTab == 'Holders'" />
                                    <DevStream :launchpad="launchpad" v-if="activeTab == 'Dev Stream'" />
                                </ScrollArea>
                            </div>
                        </div>
                    </div>
                    <div class="col-span-1 border-r border-white/10">
                        <div class="w-full max-w-md mx-auto bg-black/80 rounded-2xl p-3">
                            <!-- Header -->
                            <div class="flex items-center justify-between mb-4">
                                <span class="bg-white/4 text-white text-base font-normal rounded-xl px-4 py-2">Bubble
                                    maps</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-span-1 border-r border-white/10">
                        <!-- Comment Thread Section -->
                        <div class="w-full max-w-md mx-auto bg-black/80 rounded-2xl p-3">
                            <!-- Header -->
                            <div class="flex items-center justify-between mb-4">
                                <span
                                    class="bg-white/4 text-white text-base font-normal rounded-xl px-4 py-2">Threads</span>
                            </div>
                            <!-- Add comment -->
                            <div class="flex items-center gap-2 mb-4">
                                <img src="https://randomuser.me/api/portraits/men/32.jpg"
                                    class="w-8 h-8 rounded-full object-cover" />
                                <input type="text"
                                    class="flex-1 bg-white/10 text-white rounded-full px-4 py-2 outline-none placeholder-gray-400 placeholder:text-sm"
                                    placeholder="Add a comment..." />
                            </div>
                            <!-- Comments List -->
                            <div class="flex flex-col gap-6">
                                <div class="flex gap-3">
                                    <img src="https://randomuser.me/api/portraits/men/34.jpg"
                                        class="w-8 h-8 rounded-full object-cover" />
                                    <div>
                                        <div class="flex items-center gap-2">
                                            <span class="text-white font-semibold">@KHVw4r</span>
                                            <span class="text-gray-500 text-xs">10m</span>
                                        </div>
                                        <div class="text-white">This coin top.</div>
                                        <div class="flex items-center gap-3 mt-1 text-xs text-gray-400">
                                            <span class="flex items-center gap-1">
                                                <Heart class="text-white/50 w-4 h-4" />1
                                            </span>
                                            <span class="flex items-center gap-1">
                                                <ArrowDownLeft class="text-white/50 w-4 h-4" />Reply
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-span-1 relative">
                        <div class="flex h-full absolute inset-0">
                            <div class="flex flex-col h-full w-full items-stretch justify-between overflow-scroll">
                                <!-- <div class="flex flex-col items-stretch justify-between h-full"> -->
                                <div class="w-full max-w-md mx-auto bg-black/80 rounded-2xl p-3">
                                    <!-- Header -->
                                    <div class="flex items-center justify-between mb-4">
                                        <span
                                            class="bg-white/4 text-white text-base font-normal rounded-xl px-4 py-2">Trade
                                            Box</span>
                                    </div>
                                    <BuyCard :launchpad="launchpad" />
                                </div>
                                <div class="w-full">
                                    <div class="grid grid-cols-4 border-t border-white/20">
                                        <div class="p-2 text-center">
                                            <div class="text-white/50 text-sm">Bought</div>
                                            <div class="text-[#93FF83] text-xs">0.00</div>
                                        </div>
                                        <div class="border-l border-white/20 p-2 text-center">
                                            <div class="text-white/50 text-sm">Sold</div>
                                            <div class="text-[#FF4A4D] text-xs">0.00</div>
                                        </div>
                                        <div class="border-l border-white/20 p-2 text-center">
                                            <div class="text-white/50 text-sm">Holding</div>
                                            <div class="text-[#93FF83] text-xs">0.00</div>
                                        </div>
                                        <div class="border-l border-white/20 p-2 text-center">
                                            <div class="text-white/50 text-sm">Pnl</div>
                                            <div class="text-[#FF4A4D] text-xs">+0.00</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </AdvancedLayout>
</template>
