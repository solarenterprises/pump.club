<script setup>
import { useCarousel } from './useCarousel';
import { cn } from '@/lib/utils';

const { orientation } = useCarousel();
</script>

<template>
  <div
    :class="cn(
      'min-w-0 shrink-0 grow-0 basis-full',
      orientation === 'horizontal' ? 'pl-4' : 'pt-4',
    )"
  >
    <slot />
  </div>
</template> 