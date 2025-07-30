<script setup>
import { ref } from 'vue';

import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  LineElement,
  PointElement,
  CategoryScale,
  LinearScale,
} from 'chart.js';
import { Line } from 'vue-chartjs';

ChartJS.register(Title, Tooltip, Legend, LineElement, PointElement, CategoryScale, LinearScale);

const chartData = ref({
  labels: ['13 May', '15 May', '17 May', '19 May', '21 May', '23 May'],
  datasets: [
    {
      label: 'Rewards',
      data: [40, 60, 30, 72.46, 120, 80],
      borderColor: '#FF7300',
      backgroundColor: 'rgba(255, 115, 0, 0.1)',
      tension: 0.4,
      pointRadius: 0,
      fill: false,
    },
  ],
});

const chartOptions = ref({
  responsive: true,
  plugins: {
    legend: { display: false },
    tooltip: {
      backgroundColor: '#232323',
      titleColor: '#fff',
      bodyColor: '#fff',
      callbacks: {
        label: (ctx) => [
          `Total:`,
          `19 May, 01:00`,
          `\u0024${ctx.parsed.y.toFixed(2)}`,
          `0.411 SOL`
        ],
        labelTextColor: () => '#FF7300',
      },
      displayColors: false,
      padding: 12,
      caretSize: 6,
      borderColor: '#232323',
      borderWidth: 1,
    },
  },
  scales: {
    x: {
      display: false,
      grid: { display: false },
    },
    y: {
      display: false,
      grid: { display: false },
    },
  },
  elements: {
    line: { borderWidth: 2 },
    point: { radius: 0 },
  },
});
</script>

<template>
  <div class="bg-[#131212] rounded-2xl p-6 shadow flex flex-col w-full mb-8 relative">
    <div class="flex items-center justify-between mb-4">
      <div>
        <div class="text-white font-semibold text-lg mb-2">Creator rewards</div>
        <div class="flex gap-8">
          <div>
            <div class="text-xs text-gray-400">Total:</div>
            <div class="text-2xl text-white font-bold leading-tight">$121.31</div>
            <div class="text-xs text-gray-400">0,7844 SOL</div>
          </div>
          <div>
            <div class="text-xs text-gray-400">Unclaimed:</div>
            <div class="text-2xl text-white font-bold leading-tight">$101.42</div>
            <div class="text-xs text-gray-400">0,6554 SOL</div>
          </div>
        </div>
      </div>
      <button class="bg-gradient-to-r from-[#FF7300] to-[#DA5200] text-white font-normal text-sm px-7 py-2 rounded-full shadow transition hover:brightness-110">
        Claim rewards
      </button>
    </div>
    <div class="w-full h-40 mb-2">
      <Line :data="chartData" :options="chartOptions" />
    </div>
    <div class="flex items-center gap-2 mt-2">
      <button class="text-xs text-white bg-[#232323] rounded-full px-3 py-1 font-semibold mr-1">1D</button>
      <button class="text-xs text-gray-400 hover:text-white rounded-full px-3 py-1">1W</button>
      <button class="text-xs text-gray-400 hover:text-white rounded-full px-3 py-1">1M</button>
      <button class="text-xs text-gray-400 hover:text-white rounded-full px-3 py-1">3M</button>
      <button class="text-xs text-gray-400 hover:text-white rounded-full px-3 py-1">1Y</button>
      <button class="text-xs text-gray-400 hover:text-white rounded-full px-3 py-1">ALL</button>
      <span class="flex-1"></span>
      <button class="bg-[#232323] rounded-lg p-2">
        <svg width="18" height="18" fill="none" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="2" fill="#fff" fill-opacity="0.1"/><rect x="14" y="3" width="7" height="7" rx="2" fill="#fff" fill-opacity="0.1"/><rect x="14" y="14" width="7" height="7" rx="2" fill="#fff" fill-opacity="0.1"/><rect x="3" y="14" width="7" height="7" rx="2" fill="#fff" fill-opacity="0.1"/></svg>
      </button>
    </div>
  </div>
</template>