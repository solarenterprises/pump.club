<script setup>
import { ChevronLeft, ChevronRight } from 'lucide-vue-next';

import { useCarousel } from './useCarousel';
import { Button } from '@/Components/ui/button';
import { cn } from '@/lib/utils';

const { orientation, scrollPrev, canScrollPrev } = useCarousel();
</script>

<template>
  <Button
    variant="ghost"
    size="icon"
    :class="cn(
      'absolute h-8 w-8',
      orientation === 'horizontal'
        ? '-left-12 top-1/2 -translate-y-1/2'
        : '-top-12 left-1/2 -translate-x-1/2 rotate-90'
    )"
    :disabled="!canScrollPrev"
    @click="scrollPrev"
  >
    <slot>
      <ChevronLeft class="h-4 w-4" />
    </slot>
  </Button>
</template> 