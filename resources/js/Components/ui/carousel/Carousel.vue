<script setup>
import { computed } from 'vue';

import { useCarouselProvider } from './useCarousel';

const props = defineProps({
  opts: { type: Object, default: () => ({}) },
  plugins: { type: Array, default: () => [] },
  orientation: { type: String, default: 'horizontal' },
});

const options = computed(() => ({
  ...props.opts,
  axis: props.orientation === 'horizontal' ? 'x' : 'y',
}));

useCarouselProvider(options, props.plugins);
</script>

<template>
  <div class="relative">
    <slot />
  </div>
</template> 