<script setup>
import { ChevronRight } from 'lucide-vue-next';

import { useCarousel } from './useCarousel';
import { Button } from '@/Components/ui/button';
import { cn } from '@/lib/utils';

const { orientation, scrollNext, canScrollNext } = useCarousel();
</script>

<template>
  <Button
    variant="ghost"
    size="icon"
    :class="cn(
      'absolute h-8 w-8',
      orientation === 'horizontal'
        ? '-right-12 top-1/2 -translate-y-1/2'
        : '-bottom-12 left-1/2 -translate-x-1/2 rotate-90'
    )"
    :disabled="!canScrollNext"
    @click="scrollNext"
  >
    <slot>
      <ChevronRight class="h-4 w-4" />
    </slot>
  </Button>
</template> 