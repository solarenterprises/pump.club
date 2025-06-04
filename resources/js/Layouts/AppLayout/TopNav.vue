<script setup>
import { ref } from "vue";

import { Link } from "@inertiajs/vue3";
import { BookOpenText } from "lucide-vue-next";
import { TelegramIcon, XIcon } from "vue3-simple-icons";

import ApplicationLogo from "@/Components/ApplicationLogo.vue";
import BaseButton from "@/Components/BaseButton.vue";
import PrimaryButton from "@/Components/PrimaryButton.vue";
import HowItWorksModal from "@/Layouts/AppLayout/HowItWorksModal.vue";
import AuthLink from "@/Pages/Auth/AuthLink.vue";
import Web3Auth from "@/Pages/Auth/Web3Auth.vue";
const isMobileMenuOpen = ref(false);
const showHowItworks = ref(false);
</script>
<template>
    <nav class="bg-gray-800 border-b border-gray-700">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex items-center justify-between h-16">
                <!-- Logo and Brand -->
                <div class="flex-shrink-0 flex items-center lg:space-x-8">
                    <Link
                        class="flex items-center"
                        href="/"
                    >
                    <ApplicationLogo class="block h-5 w-auto font-semibold" />
                    </Link>
                    <!-- Navigation Links - Desktop -->
                    <div class="hidden lg:flex lg:items-center lg:space-x-4">
                        <Link
                            href="/mine"
                            class="text-gray-300 hover:text-primary px-3 py-2 text-sm font-medium"
                            :class="{
                                'text-primary': $page.props.type == 'mine',
                            }"
                        >
                        {{ $t("My Memes") }}
                        </Link>
                        <button
                            @click="showHowItworks = !showHowItworks"
                            class="text-gray-300 hover:text-primary px-3 py-2 text-sm font-medium"
                        >
                            {{ $t("How it works") }}
                        </button>
                    </div>
                </div>

                <!-- Right Side Actions -->
                <div class="hidden lg:flex lg:items-center lg:space-x-4">
                    <!-- Action Buttons -->
                    <PrimaryButton
                        link
                        href="/launch"
                        size="xs"
                        class="mr-2"
                    >
                        {{ $t("Launch Meme") }}
                    </PrimaryButton>
                    <Web3Auth />
                    <AuthLink />
                </div>

                <!-- Mobile menu button -->
                <div class="flex lg:hidden">
                    <button
                        @click="isMobileMenuOpen = !isMobileMenuOpen"
                        class="inline-flex items-center justify-center p-2 rounded text-gray-400 hover:text-white hover:bg-gray-700 focus:outline-none"
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
        </div>

        <!-- Mobile menu -->
        <div
            v-show="isMobileMenuOpen"
            class="lg:hidden"
        >
            <div class="px-2 pt-2 pb-3 space-y-1">
                <Link
                    href="/my-tokens"
                    class="block px-3 py-2 rounded text-base font-medium text-gray-300 hover:text-primary hover:bg-gray-700"
                    :class="{
                        'bg-gray-900 text-primary':
                            $page.url.startsWith('/my-tokens'),
                    }"
                >
                {{ $t("My Memes") }}
                </Link>
                <button
                    @click="showHowItworks = !showHowItworks"
                    class="block px-3 py-2 rounded text-base font-medium text-gray-300 hover:text-primary hover:bg-gray-700"
                >
                    {{ $t("How it works") }}
                </button>
            </div>
            <!-- Mobile Social Links and Actions -->
            <div class="pt-4 pb-3 border-t border-gray-700">
                <div class="px-2 space-y-1">
                    <!-- Social Links -->
                    <div class="flex items-center space-x-2 px-3 py-2">
                        <PrimaryButton
                            size="sm"
                            outlined
                            iconMode
                        >
                            <XIcon class="w-4 h-4" />
                        </PrimaryButton>
                        <PrimaryButton
                            size="sm"
                            outlined
                            iconMode
                        >
                            <BookOpenText class="w-5 h-5" />
                        </PrimaryButton>
                        <PrimaryButton
                            size="sm"
                            outlined
                            iconMode
                        >
                            <TelegramIcon class="w-4 h-4" />
                        </PrimaryButton>
                    </div>
                    <!-- Action Buttons -->
                    <div class="space-y-2 px-3">
                        <PrimaryButton
                            size="sm"
                            link
                            href="/launch"
                            class="w-full justify-center"
                        >
                            {{ $t("Launch Meme") }}
                        </PrimaryButton>

                        <!-- Action Buttons -->
                        <Web3Auth
                            size="sm"
                            class="flex-col gap-2"
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
