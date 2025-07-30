<script setup>
import { computed } from "vue";

import {
    CheckCircleIcon,
    InformationCircleIcon,
    XCircleIcon,
    XMarkIcon,
} from "@heroicons/vue/24/outline";
import { usePage } from "@inertiajs/vue3";

// Check if there are any messages to display
const hasMessages = computed(() => {
    const flash = usePage().props.flash;
    return flash.success || flash.error || flash.info;
});

// Dismiss functions using Inertia
const dismiss = (type) => {
    const props = { ...usePage().props };
    if (props.flash) {
        props.flash[type] = null;
    }
};

const dismissSuccess = () => dismiss("success");
const dismissError = () => dismiss("error");
const dismissInfo = () => dismiss("info");
</script>

<template>
    <div v-if="hasMessages" aria-live="assertive"
        class="z-[9999] mt-12 pointer-events-none fixed inset-0 flex items-start px-4 py-6 sm:p-6">
        <div class="flex w-full flex-col items-center space-y-4 sm:items-end">
            <!-- Success Message -->
            <transition enter-active-class="transform ease-out duration-300 transition"
                enter-from-class="translate-y-2 opacity-0 sm:translate-y-0 sm:translate-x-2"
                enter-to-class="translate-y-0 opacity-100 sm:translate-x-0"
                leave-active-class="transition ease-in duration-100" leave-from-class="opacity-100"
                leave-to-class="opacity-0">
                <div v-if="$page.props.flash.success"
                    class="pointer-events-auto w-full max-w-sm overflow-hidden rounded-lg bg-green-50 shadow-lg ring-1 ring-black ring-opacity-5">
                    <div class="p-4">
                        <div class="flex items-center">
                            <div class="flex-shrink-0">
                                <CheckCircleIcon class="h-6 w-6 text-green-400" aria-hidden="true" />
                            </div>
                            <div class="ml-3 w-0 flex-1">
                                <p class="text-sm font-medium text-green-800">
                                    {{ $page.props.flash.success }}
                                </p>
                            </div>
                            <div class="ml-4 flex flex-shrink-0">
                                <button type="button"
                                    class="inline-flex rounded-md bg-green-50 text-green-500 hover:text-green-600 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2"
                                    @click="dismissSuccess">
                                    <span class="sr-only">Close</span>
                                    <XMarkIcon class="h-5 w-5" aria-hidden="true" />
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </transition>

            <!-- Error Message -->
            <transition enter-active-class="transform ease-out duration-300 transition"
                enter-from-class="translate-y-2 opacity-0 sm:translate-y-0 sm:translate-x-2"
                enter-to-class="translate-y-0 opacity-100 sm:translate-x-0"
                leave-active-class="transition ease-in duration-100" leave-from-class="opacity-100"
                leave-to-class="opacity-0">
                <div v-if="$page.props.flash.error"
                    class="pointer-events-auto w-full max-w-sm overflow-hidden rounded-lg bg-red-50 shadow-lg ring-1 ring-black ring-opacity-5">
                    <div class="p-4">
                        <div class="flex items-center">
                            <div class="flex-shrink-0">
                                <XCircleIcon class="h-6 w-6 text-red-400" aria-hidden="true" />
                            </div>
                            <div class="ml-3 w-0 flex-1">
                                <p class="text-sm font-medium text-red-800">
                                    {{ $page.props.flash.error }}
                                </p>
                            </div>
                            <div class="ml-4 flex flex-shrink-0">
                                <button type="button"
                                    class="inline-flex rounded-md bg-red-50 text-red-500 hover:text-red-600 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2"
                                    @click="dismissError">
                                    <span class="sr-only">Close</span>
                                    <XMarkIcon class="h-5 w-5" aria-hidden="true" />
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </transition>

            <!-- Info Message -->
            <transition enter-active-class="transform ease-out duration-300 transition"
                enter-from-class="translate-y-2 opacity-0 sm:translate-y-0 sm:translate-x-2"
                enter-to-class="translate-y-0 opacity-100 sm:translate-x-0"
                leave-active-class="transition ease-in duration-100" leave-from-class="opacity-100"
                leave-to-class="opacity-0">
                <div v-if="$page.props.flash.info"
                    class="pointer-events-auto w-full max-w-sm overflow-hidden rounded-lg bg-blue-50 shadow-lg ring-1 ring-black ring-opacity-5">
                    <div class="p-4">
                        <div class="flex items-center">
                            <div class="flex-shrink-0">
                                <InformationCircleIcon class="h-6 w-6 text-blue-400" aria-hidden="true" />
                            </div>
                            <div class="ml-3 w-0 flex-1">
                                <p class="text-sm font-medium text-blue-800">
                                    {{ $page.props.flash.info }}
                                </p>
                            </div>
                            <div class="ml-4 flex flex-shrink-0">
                                <button type="button"
                                    class="inline-flex rounded-md bg-blue-50 text-blue-500 hover:text-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
                                    @click="dismissInfo">
                                    <span class="sr-only">Close</span>
                                    <XMarkIcon class="h-5 w-5" aria-hidden="true" />
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </transition>
        </div>
    </div>
</template>
