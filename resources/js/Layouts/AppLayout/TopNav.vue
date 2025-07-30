<script setup>
import { computed, ref } from "vue";

import { Link, usePage } from "@inertiajs/vue3";
import { useAccount } from "@wagmi/vue";
import {
    BookOpenText,
    ChartPie,
    EllipsisVertical,
    House,
    MessageSquareMore,
    Plus,
    Video,
} from "lucide-vue-next";

import ApplicationLogo from "@/Components/ApplicationLogo.vue";
import PrimaryButton from "@/Components/PrimaryButton.vue";
import HowItWorksModal from "@/Layouts/AppLayout/HowItWorksModal.vue";
import NavActions from "@/Layouts/AppLayout/NavActions.vue";
import Web3Auth from "@/Pages/Auth/Web3Auth.vue";

const isMobileMenuOpen = ref(false);
const showHowItworks = ref(false);
const { isConnected } = useAccount();

// Check if user is authenticated
const isAuthenticated = computed(() => !!usePage().props.auth.user);
</script>
<template>
    <nav class="py-3 md:py-5 px-2 md:px-10 bg-black/50 w-full z-50 fixed backdrop-blur-lg">
        <div class="mx-auto px-4 sm:px-6 lg:px-8">
            <div :class="isConnected ? 'flex flex-col md:flex-row items-center justify-between h-full' : 'flex flex-row items-center justify-between h-full'">
                <!-- Logo and Brand -->
                 <div :class="isConnected ? 'flex items-center justify-between md:w-auto w-full' : 'flex items-center justify-between w-auto'">
                    <Link class="flex items-center" href="/">
                        <ApplicationLogo class="block h-full w-auto font-semibold" />
                    </Link>
                    <div v-if="isConnected" class="flex md:hidden">
                        <button
                            @click="isMobileMenuOpen = !isMobileMenuOpen"
                            class="inline-flex items-center justify-center px-4 py-2 rounded-full text-white border-white/10 border"
                        >
                            <span class="sr-only">Open main menu</span>
                            <!-- Icon when menu is closed -->
                            <svg
                                v-if="!isMobileMenuOpen"
                                class="block h-6 w-6"
                                fill="none"
                                viewBox="0 0 24 24"
                                stroke="currentColor"
                            >
                                <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    stroke-width="2"
                                    d="M4 6h16M4 12h16M4 18h16"
                                />
                            </svg>
                            <!-- Icon when menu is open -->
                            <svg
                                v-else
                                class="block h-6 w-6"
                                fill="none"
                                viewBox="0 0 24 24"
                                stroke="currentColor"
                            >
                                <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    stroke-width="2"
                                    d="M6 18L18 6M6 6l12 12"
                                />
                            </svg>
                        </button>
                    </div>
                </div>
                <div class="flex-shrink-0 flex items-center lg:space-x-8">
                    <!-- Navigation Links - Desktop -->
                    <div class="hidden lg:flex lg:items-center lg:space-x-4">
                        <Link href="/"
                            class="text-gray-300 rounded-full hover:bg-white/10 px-5 py-4 text-sm font-medium flex items-center gap-2 bg-white/10">
                        <House class="w-4 h-4" />
                        {{ $t("Home") }}
                        </Link>
                        <Link href="/"
                            class="text-gray-300 rounded-full hover:bg-white/10 px-5 py-4 text-sm font-medium flex items-center gap-2">
                        <ChartPie class="w-4 h-4" />
                        {{ $t("Watchlist") }}
                        </Link>
                        <Link href="/"
                            class="text-gray-300 rounded-full hover:bg-white/10 px-5 py-4 text-sm font-medium flex items-center gap-2">
                        <Video class="w-4 h-4" />
                        {{ $t("Launch") }}
                        </Link>
                        <Link href="/"
                            class="text-gray-300 rounded-full hover:bg-white/10 px-5 py-4 text-sm font-medium flex items-center gap-2">
                        <MessageSquareMore class="w-4 h-4" />
                        {{ $t("Support") }}
                        </Link>
                    </div>
                </div>

                <!-- Right Side Actions -->
                <div class="hidden md:flex">
                    <NavActions />
                </div>

                <!-- Mobile menu button and actions -->
                <div v-if="!isConnected" class="flex md:hidden items-center gap-2">
                    <NavActions mobile />
                </div>

                <!-- Mobile menu -->
                
            </div>
        </div>
        <div
            v-show="isConnected && isMobileMenuOpen"
                class="w-full h-full bg-black/10 md:hidden"
            >
                <div class="px-2 pt-2 pb-3 space-y-1">
                    <Link href="/"
                        class="text-gray-300 rounded-full hover:bg-white/10 px-5 py-4 text-sm font-medium flex items-center gap-2 bg-white/10">
                    <House class="w-4 h-4" />
                    {{ $t("Home") }}
                    </Link>
                    <Link href="/"
                        class="text-gray-300 rounded-full hover:bg-white/10 px-5 py-4 text-sm font-medium flex items-center gap-2">
                    <ChartPie class="w-4 h-4" />
                    {{ $t("Watchlist") }}
                    </Link>
                    <Link href="/"
                        class="text-gray-300 rounded-full hover:bg-white/10 px-5 py-4 text-sm font-medium flex items-center gap-2">
                    <Video class="w-4 h-4" />
                    {{ $t("Launch") }}
                    </Link>
                    <Link href="/"
                        class="text-gray-300 rounded-full hover:bg-white/10 px-5 py-4 text-sm font-medium flex items-center gap-2">
                    <MessageSquareMore class="w-4 h-4" />
                    {{ $t("Support") }}
                    </Link>
                </div>
                <!-- Mobile Social Links and Actions -->
                <div class="pt-4 pb-3">
                    <div class="px-2 space-y-1">
                        <!-- Action Buttons -->
                        <div class="space-y-2 px-3">
                            <PrimaryButton
                                link
                                href="/"
                                class="w-full rounded-full px-5 py-4 text-white hover:bg-transparent flex items-center gap-1 border border-white/10 text-sm bg-primary"
                                >
                                {{ $t('Create Coin') }}
                                <Plus class="w-4 h-4" />
                            </PrimaryButton>

                            <!-- Action Buttons -->
                            <Web3Auth
                                class="flex-col gap-2 w-full !rounded-full"
                                full
                            />
                            <AuthLink full />
                        </div>
                    </div>
                </div>
            </div>
        <HowItWorksModal v-model:show="showHowItworks" />
    </nav>
</template>
