<script setup>
import { computed, ref } from "vue";
import { Link } from "@inertiajs/vue3";
import ApplicationLogo from "@/Components/ApplicationLogo.vue";
import { ChartBarIncreasing, House, Plus, Search, Settings, X } from "lucide-vue-next";
import Web3Auth from "@/Pages/Auth/Web3Auth.vue";
import Separator from "@/Components/ui/separator/Separator.vue";
import { useStore } from "vuex";
import { ScrollArea } from "@/Components/ui/scroll-area";
import PrimaryButton from "@/Components/PrimaryButton.vue";
import FormInput from "@/Components/FormInput.vue";
import { debouncedWatch, useUrlSearchParams } from "@vueuse/core";
import axios from "axios";

// Props
defineProps({
    title: {
        type: String,
        default: "",
    },
    compact: Boolean,
});

const store = useStore();
const searchedLaunchpads = ref([]);
const searchModal = computed(() => store.state.searchModal);

function openSearchModal() {
    store.dispatch('openSearchModal');
}

const params = useUrlSearchParams("history");
const search = ref(params.search ?? "");

debouncedWatch(
    [search],
    ([search]) => {
        if (search.trim()) {
            axios.get(window.route("advanced.search"), { params: { search: search.trim() } })
                .then(response => {
                    searchedLaunchpads.value = response.data;
                });
        } else {
            searchedLaunchpads.value = [];
        }
    },
    {
        maxWait: 700,
    },
);

function closeSearchModal() {
    store.dispatch('closeSearchModal');
}

</script>
<template>
    <div class="flex flex-col home-bg h-screen">
        <div class="w-full border-b border-white/10 py-0 px-2 flex overflow-x-auto whitespace-nowrap gap-6"
            style="min-height: 38px;">
            <div v-for="i in 8" :key="i" class="flex items-center gap-2 min-w-max">
                <img src="/indexcard.png" class="w-5 h-5 rounded-full" />
                <span class="text-white font-semibold text-xs">PNDA</span>
                <span v-if="i % 2 === 0" class="flex items-center text-xs text-red-400 font-semibold">
                    <svg class="w-3 h-3 mr-0.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
                    </svg>
                    0.7838 AVAX
                </span>
                <span v-else class="flex items-center text-xs text-green-400 font-semibold">
                    <svg class="w-3 h-3 mr-0.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M5 15l7-7 7 7" />
                    </svg>
                    0.7838 AVAX
                </span>
                <span class="text-white/60 text-xs">@kevin_91</span>
            </div>
        </div>
        <div class="flex flex-row items-center gap-2 py-1 px-2 border-b border-white/10">
            <div class="flex flex-row items-center gap-1">
                <House class="w-3.5 h-3.5 text-primary" />
                <span class="text-primary text-xs">scan</span>
            </div>
            <button class="flex flex-row items-center gap-1 border border-white/10 rounded-lg px-2 py-1"
                @click="openSearchModal">
                <Search class="w-3.5 h-3.5 text-white/50" />
                <span class="text-white/50 text-xs">search</span>
            </button>
            <Separator orientation="vertical" class="h-4" />
        </div>
        <slot name="header" />

        <!-- Main Content -->
        <main class="flex-1 flex flex-col">
            <!-- Main Content Area -->
            <div class="h-full w-full flex flex-col">
                <slot></slot>
            </div>
        </main>

        <!-- Footer (Will be created next) -->
        <footer class="w-full z-50 border border-white/10 px-4 py-2 bg-black">
            <div class="flex flex-row items-center justify-between">
                <!-- Logo and Brand -->
                <div class="flex flex-row items-center gap-4">
                    <Link class="flex items-center" href="/">
                    <ApplicationLogo class="block h-full w-auto font-semibold" />
                    <!-- <span class="text-white text-2xl font-bold">pump.club</span> -->
                    </Link>
                    <div class="flex flex-row items-center gap-2">
                        <img src="/avax-icon.svg" class="w-4 h-4" />
                        <span class="text-white/50 text-sm">$156.17</span>
                    </div>
                    <div class="flex flex-row items-center gap-2">
                        <ChartBarIncreasing class="w-4 h-4 text-white/50" />
                        <span class="text-white/50 text-sm">$63.2K</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="h-2 w-2 rounded-full bg-green-400"></span>
                        <span class="text-green-400 font-normal text-sm">Stable Connection</span>
                    </div>
                </div>
                <div class="flex flex-row gap-3 items-center">
                    <Link class="text-primary hover:bg-transparent flex items-center gap-1 text-sm whitespace-nowrap"
                        href="/launch">
                    {{ $t('Create Coin') }}
                    <Plus class="w-4 h-4 text-primary" />
                    </Link>
                    <Web3Auth />
                    <button class="text-white/50 hover:text-white transition-colors">
                        <Settings class="w-4 h-4" />
                    </button>
                </div>
            </div>
        </footer>
    </div>

    <!-- Search Modal -->
    <template v-if="searchModal">
        <div class="fixed inset-0 bg-gray-900/50 flex items-center justify-center z-[999999]">
            <div class="bg-gray-900 rounded-3xl p-8 w-full max-w-sm relative shadow-xl border border-white/10">
                <!-- Close button -->
                <button class="absolute top-4 right-4 text-gray-400 hover:text-white text-2xl"
                    @click="closeSearchModal">
                    <X class="w-5 h-5" />
                </button>
                <!-- Title -->
                <h2 class="text-2xl font-semibold text-white mb-6">Search</h2>
                <!-- Search input -->
                <div class="flex flex-col gap-4 w-full">
                    <FormInput v-model="search" class="ml-auto mr-auto w-full py-3" size="md"
                        inputClasses="!rounded-3xl" placeholder="Search for meme">
                        <template #lead>
                            <Search class="w-4 h-4 ml-1 text-gray-400" />
                        </template>
                        <template #trail>
                            <PrimaryButton size="xs"
                                class="rounded-full text-white hover:bg-transparent px-4 py-2.5 cursor-pointer"
                                style="background: linear-gradient(to right, #6C2801 0%, #DA5200 34%, #E97C02 100%);">
                                {{ $t("Search") }}
                            </PrimaryButton>
                        </template>
                    </FormInput>
                </div>
                <!-- History -->
                <div>
                    <div class="text-white/60 text-sm mb-2">History:</div>
                    <ScrollArea class="w-full overflow-hidden p-2 h-[400px]">
                        <div class="flex flex-col gap-2">
                            <Link :href="route('advanced.advancedTradingView', { contract: item.contract })"
                                v-for="(item, idx) in searchedLaunchpads" :key="idx"
                                class="flex items-center justify-between py-2 px-2 rounded-lg hover:bg-white/5 transition cursor-pointer">
                            <div class="flex items-center gap-3">
                                <img :src="item.logo"
                                    class="w-10 h-10 rounded-full object-cover border border-white/10" />
                                <div class="flex flex-col">
                                    <span class="text-white font-medium leading-tight">{{ item.name }}</span>
                                    <span class="text-white/40 text-xs font-mono">{{ item.symbol }}</span>
                                </div>
                            </div>
                            <div class="text-white/80 text-sm whitespace-nowrap">Market cap: <span
                                    class="font-semibold">{{
                                        item.marketCap }}</span></div>
                            </Link>
                        </div>
                    </ScrollArea>
                </div>
            </div>
        </div>
    </template>
</template>