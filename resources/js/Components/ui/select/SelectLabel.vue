<script setup>
import { SelectLabel, useForwardProps } from 'radix-vue';

import { cn } from '@/lib/utils';

const props = defineProps({
  for: { type: String, required: false },
  asChild: { type: Boolean, required: false },
  as: { type: null, required: false },
  class: { type: null, required: false },
});

const forwardedProps = useForwardProps(props);
</script>

<template>
  <SelectLabel :class="cn('py-1.5 pl-8 pr-2 text-sm font-semibold', props.class)" v-bind="forwardedProps">
    <slot />
  </SelectLabel>
</template>
