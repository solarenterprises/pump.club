<script setup>
import { SelectValue, useForwardProps } from 'radix-vue';

import { cn } from '@/lib/utils';

const props = defineProps({
  placeholder: { type: String, required: false },
  asChild: { type: Boolean, required: false },
  as: { type: null, required: false },
  class: { type: null, required: false },
});

const forwardedProps = useForwardProps(props);
</script>

<template>
  <SelectValue
    v-bind="forwardedProps"
    :class="cn('text-sm text-white', props.class)"
  >
    <slot />
  </SelectValue>
</template>
