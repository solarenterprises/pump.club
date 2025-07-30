<script setup>
import { Braces, Crosshair, Crown, EyeOff, Star, User } from 'lucide-vue-next';
import { Link } from '@inertiajs/vue3';

// Props: expects a launchpad object
const props = defineProps({
  launchpad: {
    type: Object,
    required: true,
  },
});

</script>

<template>
  <Link :href="route('advanced.advancedTradingView', { contract: launchpad.contract })"
    class="group relative py-2 px-4 flex flex-row gap-4 w-full items-stretch overflow-hidden border-b border-white/10 hover:bg-white/10 transition-colors">
  <div class="text-white/50 text-xs">{{ launchpad.mintId }}</div>
  <!-- Left: Image with orange border and overlay -->
  <div class="flex flex-col items-center justify-center mr-4">
    <div
      class="w-16 h-16 rounded-xl border border-orange-500 overflow-hidden relative flex items-center justify-center">
      <img :src="launchpad.logo" alt="View coin" class="object-cover w-full h-full"
        @error="$event.target.src = '/indexcard.png'" />
      <div
        class="absolute inset-0 flex items-center justify-center bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity cursor-pointer text-white text-xs font-normal">
        View coin
      </div>
    </div>
    <!-- Bottom: Username -->
    <div class="text-gray-400 text-xs mt-2 truncate">{{ launchpad.username || launchpad.owner || 'Azo7...pump' }}
    </div>
  </div>
  <!-- Main Content -->
  <div class="flex-1 flex flex-col justify-between min-w-0">
    <!-- Top Row: Title, subtitle, stats -->
    <div class="flex items-start justify-between w-full">
      <div>
        <div class="text-white font-medium text-lg leading-tight">
          {{ launchpad.name || 'Panda' }}
          <span class="text-gray-400 font-normal text-base">{{ launchpad.symbol || 'PNDA' }}</span>
        </div>
        <div class="flex flex-row items-center gap-2 mt-1">
          <div class="text-[#93FF83] text-sm">{{ launchpad.createdAgo || '29m' }}</div>
          <EyeOff class="w-3 h-3 text-white/50 cursor-pointer" />
          <Star class="w-3 h-3 text-white/50 cursor-pointer" />
        </div>
      </div>
      <div class="flex flex-col items-end min-w-max">
        <div>
          <span class="text-white font-medium text-sm">V {{ launchpad.volume || '$90.1K' }}</span>
          <span class="text-[#93FF83] font-normal text-sm ml-2">MC {{ launchpad.marketCap || '$60.4K' }}</span>
        </div>
        <div class="flex flex-row items-center justify-end w-full gap-1">
          <div class="flex w-full max-w-12">
            <div class="h-1 bg-white/10 rounded-full w-full">
              <div class="h-1 bg-orange-500 rounded-full" :style="{ width: (launchpad.progress ?? 50) + '%' }"></div>
            </div>
          </div>
          <div class="text-gray-400 text-xs">TX <span class="text-white ml-1">{{ launchpad.tx || '614' }}</span></div>
        </div>
      </div>
    </div>
    <!-- Stat Pills Row -->
    <div class="flex flex-row items-center gap-2 justify-between">
      <div class="flex items-center gap-2 mt-2 flex-wrap">
        <span
          class="flex items-center bg-black/40 border border-[#93FF83] text-[#93FF83] rounded-lg px-1 py-0.5 text-xs font-normal">
          <User class="w-3 h-3 mr-1" />
          {{ launchpad.stat1 || 139 }}
        </span>
        <span
          class="flex items-center bg-black/40 border border-[#FF4A4D] text-[#FF4A4D] rounded-lg px-1 py-0.5 text-xs font-normal">
          <Crosshair class="w-3 h-3 mr-1" />
          {{ launchpad.stat2 || 139 }}
        </span>
        <span
          class="flex items-center bg-black/40 border border-[#93FF83] text-[#93FF83] rounded-lg px-1 py-0.5 text-xs font-normal">
          <Braces class="w-3 h-3 mr-1" />
          {{ launchpad.stat3 || 139 }}
        </span>
        <span
          class="flex items-center bg-black/40 border border-[#FF4A4D] text-[#FF4A4D] rounded-lg px-1 py-0.5 text-xs font-normal">
          <Crown class="w-3 h-3 mr-1" />
          {{ launchpad.stat4 || 139 }}
        </span>
      </div>
    </div>
  </div>
  </Link>
</template>
