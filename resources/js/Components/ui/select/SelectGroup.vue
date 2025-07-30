<script setup>
import { SelectGroup } from 'radix-vue';

const props = defineProps({
  asChild: { type: Boolean, required: false },
  as: { type: null, required: false },
});
</script>

<template>
  <SelectGroup v-bind="props">
    <slot />
  </SelectGroup>
</template>
