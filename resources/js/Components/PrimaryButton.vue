<script setup>
import { computed } from "vue";

import { Link } from "@inertiajs/vue3";

const props = defineProps({
    outlined: {
        type: Boolean,
        default: false,
    },

    link: {
        type: Boolean,
        default: false,
    },
    url: {
        type: Boolean,
        default: false,
    },

    size: {
        type: String,
        default: "sm",
        validator: (value) =>
            ["xs", "sm", "md", "lg", "xl"].includes(value),
    },
    iconMode: {
        type: Boolean,
        default: false,
    },
});

const sizeClasses = computed(() => ({
    xss: props.iconMode
        ? "w-5 h-5 text-xs"
        : "px-2 py-1 font-semibold text-xs",
    xs: props.iconMode
        ? "w-6 h-6 text-xs"
        : "px-2.5 py-1.5 font-semibold text-xs",
    sm: props.iconMode ? "w-8 h-8 text-sm" : "px-3 py-2 text-sm",
    md: props.iconMode ? "w-10 h-10 text-base" : "px-4 py-2.5 text-base",
    lg: props.iconMode ? "w-12 h-12 text-lg" : "px-5 py-3 text-lg",
    xl: props.iconMode ? "w-14 h-14 text-xl" : "px-6 py-3.5 text-xl",
}));
const comp = computed(() =>
    props.link ? Link : props.url ? "a" : "button",
);
</script>

<template>
    <component
        :is="comp"
        :class="[
            'inline-flex items-center justify-center font-medium transition-colors duration-200',
            'focus:outline-none focus:ring-offset-2',
            sizeClasses[size],
            iconMode ? 'aspect-square p-0' : '',
            outlined
                ? 'bg-transparent border text-primary hover:bg-primary hover:text-black'
                : 'bg-primary text-black border border-transparent hover:bg-primary-dark',
            'rounded cursor-pointer disabled:pointer-events-none disabled:opacity-70',
        ]"
        v-bind="$attrs"
    >
        <slot></slot>
    </component>
</template>
