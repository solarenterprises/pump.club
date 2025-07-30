<script setup>
import { computed } from 'vue';

const props = defineProps({
  currentPage: { type: Number, required: true },
  totalPages: { type: Number, required: true },
});

const emit = defineEmits(['update:page']);

const pages = computed(() => {
  const { currentPage, totalPages } = props;
  let start = Math.max(1, currentPage - 2);
  let end = Math.min(totalPages, currentPage + 2);

  if (end - start < 4) {
    if (start === 1) end = Math.min(totalPages, start + 4);
    if (end === totalPages) start = Math.max(1, end - 4);
  }

  const arr = [];
  for (let i = start; i <= end; i++) arr.push(i);
  return arr;
});

function goTo(page) {
  if (page >= 1 && page <= props.totalPages && page !== props.currentPage) {
    emit('update:page', page);
  }
}
</script>

<template>
  <nav class="flex items-center gap-2 mt-6 select-none" aria-label="Pagination">
    <!-- Prev -->
    <button
      class="w-8 h-8 flex items-center justify-center rounded-full text-white/80 hover:text-white transition disabled:opacity-30 disabled:cursor-not-allowed bg-transparent"
      :disabled="currentPage === 1"
      @click="goTo(currentPage - 1)"
      aria-label="Previous"
    >
      <svg width="18" height="18" fill="none" viewBox="0 0 24 24"><path d="M15 6l-6 6 6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
    </button>

    <!-- Page numbers -->
    <button
      v-for="page in pages"
      :key="page"
      @click="goTo(page)"
      :aria-current="page === currentPage ? 'page' : undefined"
      :class="[
        'w-8 h-8 flex items-center justify-center rounded-full mx-0.5 text-base font-medium transition',
        page === currentPage
          ? 'bg-neutral-900 text-white font-bold shadow-none'
          : 'bg-transparent text-white/80 hover:text-white hover:bg-white/10',
        page === currentPage ? '' : 'cursor-pointer'
      ]"
      :disabled="page === currentPage"
    >
      {{ page }}
    </button>

    <!-- Next -->
    <button
      class="w-8 h-8 flex items-center justify-center rounded-full text-white/80 hover:text-white transition disabled:opacity-30 disabled:cursor-not-allowed bg-transparent"
      :disabled="currentPage === totalPages"
      @click="goTo(currentPage + 1)"
      aria-label="Next"
    >
      <svg width="18" height="18" fill="none" viewBox="0 0 24 24"><path d="M9 6l6 6-6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
    </button>
  </nav>
</template> 