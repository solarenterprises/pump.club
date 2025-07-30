<script setup>
import { onMounted, ref } from "vue";

import { Link } from "@inertiajs/vue3";
import { ChevronLeft, MessageSquare, TvMinimalPlay, UsersRound } from "lucide-vue-next";
import { RiExchangeLine } from "oh-vue-icons/icons";

import { Carousel, CarouselContent, CarouselItem } from "@/Components/ui/carousel";
import AppLayout from "@/Layouts/AppLayout.vue";
import { shortenAddress } from "@/lib/wagmi";
import BarButton from "@/Pages/Launchpads/BarButton.vue";
import Chat from "@/Pages/Launchpads/Chat.vue";
import BuyCard from "@/Pages/Launchpads/TradingView/BuyCard.vue";
import DevStream from "@/Pages/Launchpads/TradingView/DevStream.vue";
import Holders from "@/Pages/Launchpads/TradingView/Holders.vue";
import Info from "@/Pages/Launchpads/TradingView/Info.vue";
import LockCard from "@/Pages/Launchpads/TradingView/LockCard.vue";
import Trades from "@/Pages/Launchpads/TradingView/Trades.vue";
import TradingViewChart from "@/Pages/Launchpads/TradingView/TradingViewChart.vue";

defineProps({
    launchpad: Object,
    top: Array,
    stats: Object,
    rate: Object,
    poolstats: Object,
});

const tabs = [
    { name: "Chat", icon: MessageSquare },
    { name: "Trades", icon: RiExchangeLine, vueicon: true },
    { name: "Holders", icon: UsersRound },
    { name: "Dev Stream", icon: TvMinimalPlay },
];
const activeTab = ref("Chat");

const navHeight = ref(90);
const navRef = ref(null);

onMounted(() => {
  if (navRef.value) {
    navHeight.value = navRef.value.offsetHeight;
  }
});
</script>
<template>
    <AppLayout compact>
        <template #header>
            <div class="hidden md:flex items-center w-full bg-black relative bg-black/10" :style="{ paddingTop: `calc(10px + ${navHeight}px)` }">
                <div class="flex w-full items-center">
                    <div class="flex w-full items-center">
                    <Carousel class="w-full" :opts="{ align: 'start' }">
                        <CarouselContent>
                        <CarouselItem
                            v-for="(launch, i) in top"
                            :key="launch.id"
                            class="!basis-auto"
                        >
                            <BarButton :launch="launch" :active="i === 0" />
                        </CarouselItem>
                        </CarouselContent>
                    </Carousel>
                    </div>
                </div>
                </div>
        </template>
        <div class="flex flex-col md:flex-row gap-6 mx-2 md:mx-5 lg:mx-24 xl:mx-36 md:my-10 my-0 pt-24 md:pt-4">
			<div class="lg:w-8/12 w-full md:w-7/12 mb-6 mx-auto md:bg-black/50 bg-transparent md:p-7 p-2 h-full rounded-3xl">
                <div class="flex flex-col gap-2 w-full">
                    <div class="flex flex-col gap-2 w-full">
                        <div class="flex flex-col justify-between w-full py-2 gap-4">
                            <div class="flex flex-row justify-between items-center gap-4">
                                <Link href="/" class="flex items-center text-white hover:text-gray-300 focus:outline-none">
                                    <ChevronLeft class="w-4 h-4" />
                                    Back
                                </Link>
                            </div>
                            <div class="flex flex-col md:flex-row items-center justify-between gap-6 text-gray-300 text-sm w-full">
                                <div class="flex flex-row items-center gap-4">
                                    <span class="text-white font-semibold leading-tight">{{ launchpad.name }}</span>
                                    <img src="https://randomuser.me/api/portraits/men/32.jpg" alt="avatar" class="md:w-8 md:h-8 w-12 h-12 rounded-full object-cover" />
                                    <span class="text-gray-400 text-xs leading-tight">{{ shortenAddress(launchpad.user.address) }}</span>
                                </div>
                                <div class="flex flex-row justify-between items-center gap-4 text-gray-400">
                                    <span>{{ launchpad.createdAgo }}</span>
                                    <span>market cap: ${{ launchpad.marketCap ?? 0 }}</span>
                                    <span>replies: {{ launchpad.msg_count ?? 0 }}</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="h-4/8 w-full">
                        <TradingViewChart :launchpad="launchpad" />
                    </div>
                    <div class="flex h-fit mt-6">
                        <div class="flex justify-between bg-white/10 rounded-full p-1 gap-1 overflow-x-auto w-full md:w-fit">
                            <button
                                v-for="tab in tabs"
                                :key="tab.name"
                                @click="activeTab = tab.name"
                                :class="[
                                    'md:px-7 px-2 py-2 text-sm md:text-base font-normal focus:outline-none transition-all',
                                    activeTab === tab.name
                                        ? 'bg-gradient-to-r from-orange-500 to-orange-600 text-white shadow rounded-full'
                                        : 'bg-transparent text-gray-400 rounded-full hover:text-white'
                                ]"
                            >
                                {{ tab.name }}
                            </button>
                        </div>
                    </div>

                    <div class="text-gray-300 mt-4 grid gap-1 relative h-full mb-8">
                        <Chat
                            v-if="activeTab == 'Chat'"
                            :launchpadId="launchpad.id"
                            :devId="launchpad.user_id"
                            :initial-messages="$page.props.msgs"
                            class="md:w-full"
                        />
                        <Trades
                            :trades="$page.props.trades"
                            :chainId="launchpad.chainId"
                            :bcurve="launchpad.contract"
                            v-if="activeTab == 'Trades'"
                        />
                        <Holders
                            :holders="$page.props.holders"
                            :chainId="launchpad.chainId"
                            :launchpad="launchpad"
                            :usdRate="rate.usd_rate"
                            v-if="activeTab == 'Holders'"
                        />
                        <DevStream
                            :launchpad="launchpad"
                            v-if="activeTab == 'Dev Stream'"
                        />
                    </div>
                </div>
            </div>
            <div class="lg:w-4/12 w-full md:w-5/12 mb-6 mx-auto md:bg-black/50 bg-transparent md:p-7 p-2 h-full rounded-3xl">
                <div class="flex flex-col items-center md:items-start md:flex-row gap-8 mt-4 md:justify-center">
                    <div class="grid mb-12 gap-4 w-full">
                        <BuyCard :launchpad="launchpad" />
                        <LockCard
                            v-if="launchpad.isOwner"
                            :launchpad="launchpad"
                        />
                        <Info
                            :rank="stats.rank"
                            :rate="rate"
                            :totalVolume="stats.totalVolume"
                            :totalLaunchpads="stats.totalLaunchpads"
                            :launchpad="launchpad"
                        />
                    </div>
                </div>
            </div>
        </div>
    </AppLayout>
</template>
