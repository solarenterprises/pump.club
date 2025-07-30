<script setup>
import {
  SelectContent,
  useForwardProps,
 SelectPortal } from 'radix-vue';

import { cn } from '@/lib/utils';

const props = defineProps({
  class: { type: null, required: false },
  asChild: { type: Boolean, required: false },
  as: { type: null, required: false },
  position: { type: String, default: 'popper' },
});

const forwardedProps = useForwardProps(props);
</script>

<template>
  <SelectPortal>
    <SelectContent
      v-bind="{ ...forwardedProps, ...$attrs }"
      :class="cn(
        'relative z-50 min-w-[4rem] overflow-hidden rounded-lg border border-white/10 bg-gray-900 text-white shadow-md p-3',
        position === 'popper' &&
          'data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2',
        props.class,
      )"
    >
      <slot />
    </SelectContent>
  </SelectPortal>
</template>
