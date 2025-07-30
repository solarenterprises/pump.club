<script setup>
import {
  SelectRoot,
  useForwardPropsEmits,
} from 'radix-vue';

const props = defineProps({
  modelValue: { type: String, required: false },
  defaultValue: { type: String, required: false },
  open: { type: Boolean, required: false },
  defaultOpen: { type: Boolean, required: false },
  disabled: { type: Boolean, required: false },
  name: { type: String, required: false },
});

const emits = defineEmits(['update:modelValue', 'update:open']);

const forwarded = useForwardPropsEmits(props, emits);
</script>

<template>
  <SelectRoot v-bind="forwarded">
    <slot />
  </SelectRoot>
</template>
