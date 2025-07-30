<script setup>
import { Check } from 'lucide-vue-next';
import {
  SelectItem,
  useForwardProps,
  SelectItemIndicator,
  SelectItemText,
} from 'radix-vue';

import { cn } from '@/lib/utils';

const props = defineProps({
  value: { type: String, required: true },
  disabled: { type: Boolean, required: false },
  textValue: { type: String, required: false },
  asChild: { type: Boolean, required: false },
  as: { type: null, required: false },
  class: { type: null, required: false },
});

const forwardedProps = useForwardProps(props);
</script>

<template>
  <SelectItem
    v-bind="forwardedProps"
    :class="cn(
      'relative flex w-full cursor-default select-none items-center rounded-lg py-1.5 pl-2 pr-2 text-sm outline-none focus:bg-white/10 focus:text-white data-[disabled]:pointer-events-none data-[disabled]:opacity-50',
      props.class,
    )"
  >
    <SelectItemText>
      <slot />
    </SelectItemText>
  </SelectItem>
</template>
