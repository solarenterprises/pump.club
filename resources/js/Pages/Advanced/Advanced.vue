<script setup>
import { computed, ref, onMounted } from "vue";
import { useStore } from 'vuex';
import { FunnelIcon } from "@heroicons/vue/24/outline";
import { debouncedWatch, useUrlSearchParams } from "@vueuse/core";
import { CircleAlert, EyeOff, GripVertical, Inbox, PackagePlus, PlayIcon, Settings, X } from "lucide-vue-next";

import AdvancedCard from "./AdvancedCard.vue";
import FormInput from "@/Components/FormInput.vue";
import { ScrollArea } from "@/Components/ui/scroll-area";
import { Select, SelectContent, SelectItem, SelectTrigger } from "@/Components/ui/select";
import { Switch } from "@/Components/ui/switch";
import { useLaunchpadsData } from "@/hooks/useLaunchpadsData";
import useLocalStorage from '@/hooks/useLocalStorage';
import { TRADE_SETTINGS } from "@/store/constants";
import AdvancedLayout from "@/Layouts/AdvancedLayout.vue";

const props = defineProps({
  launchpads: [Array, Object],
  top: Array,
  usdRates: [Array, Object],
  type: String,
});

const presetsLists = [
  {
    name: "Preset 1",
    value: "p1",
  },
  {
    name: "Preset 2",
    value: "p2",
  },
  {
    name: "Preset 3",
    value: "p3",
  }
];

const defaultColumns = [
  { title: "Newly Created", subtitle: "newly created", enabled: true },
  { title: "About To Graduate", subtitle: "about to graduate", enabled: true },
  { title: "Graduated", subtitle: "graduated", enabled: true },
  { title: "Watchlist", subtitle: "watchlist", enabled: false },
  { title: "Featured", subtitle: "featured", enabled: false },
];

const selectedPreset = ref(presetsLists[0].value);
const addColumnModal = ref(false);
const tempColumnManage = ref([]);
const columnManage = useLocalStorage('advanced_column_manage', defaultColumns);
const tradeSettingsModal = ref(false);
const tradeTab = ref('buy');
const tradePreset = ref('p1');
const slippage = ref(20);
const priority = ref(0.001);
const bribe = ref(0.001);
const autoBribe = ref(true);
const autoBribeMax = ref(0.01);
const mevProtection = ref(true);
const launchpadsList = computed(() => props.launchpads?.data || []);
const launchpadsInfo = useLaunchpadsData(launchpadsList, props.usdRates);

function resetAllColumns() {
  tempColumnManage.value.forEach((col, idx) => {
    col.enabled = idx < 3;
  });
}

function saveColumns() {
  columnManage.value = JSON.parse(JSON.stringify(tempColumnManage.value));
  addColumnModal.value = false;
}

function openColumnModal() {
  tempColumnManage.value = JSON.parse(JSON.stringify(columnManage.value));
  addColumnModal.value = true;
}

function openTradeSettings() {
  tradeSettingsModal.value = true;
}

function setTradeTab(tab) {
  tradeTab.value = tab;
}

function setTradePreset(preset) {
  tradePreset.value = preset;
}

function closeTradeSettings() {
  tradeSettingsModal.value = false;
}

// Computed property for enabled columns
const enabledColumns = computed(() => {
  if (!columnManage.value || !Array.isArray(columnManage.value)) {
    return defaultColumns.filter(col => col.enabled);
  }
  return columnManage.value.filter(col => col.enabled === true);
});

const getWatchlistContracts = () => {
  try {
    const stored = localStorage.getItem('watchLists');
    if (stored) {
      return JSON.parse(stored).map(item => item.c_address);
    }
  } catch { }
  return [];
};

// Computed property: map column title to filtered launchpads
const launchpadsByColumn = computed(() => {
  const map = {};
  const watchlistContracts = getWatchlistContracts();
  enabledColumns.value.forEach(col => {
    let filtered;
    if (col.title === 'Newly Created') {
      filtered = launchpadsInfo.launchpads.value.filter(lp => (lp.status || '').toLowerCase() === 'prebond');
    } else if (col.title === 'About To Graduate') {
      filtered = launchpadsInfo.launchpads.value.filter(lp => (lp.status || '').toLowerCase() === 'bonding');
    } else if (col.title === 'Graduated') {
      filtered = launchpadsInfo.launchpads.value.filter(lp => (lp.status || '').toLowerCase() === 'finalized');
    } else if (col.title === 'Watchlist') {
      filtered = launchpadsInfo.launchpads.value.filter(lp => watchlistContracts.includes(lp.contract));
    } else {
      filtered = [];
    }
    map[col.title] = filtered;
  });
  return map;
});

onMounted(() => {
  if (!localStorage.getItem('advanced_column_manage')) {
    localStorage.setItem('advanced_column_manage', JSON.stringify(defaultColumns));
  }
});

</script>

<template>
  <AdvancedLayout>
    <div class="flex flex-row items-center gap-3 py-2 px-2 border-b border-white/10">
      <div class="flex items-center">
        <div class="relative flex items-center bg-white/4 rounded-lg">
          <div class="flex items-center">
            <button class="flex items-center gap-2 text-white/80 whitespace-nowrap text-sm font-normal px-2 py-1">
              <img src="/avax-icon.svg" class="w-4 h-4" />
              Quick Buy
            </button>
          </div>
          <FormInput size="sm" class="w-24" type="number" inputClasses="!bg-transparent">
            <template #trail>
              <button class="flex items-center" @click="openTradeSettings">
                <Settings class="w-4 h-4 ml-1 text-gray-400" />
              </button>
            </template>
          </FormInput>
        </div>
      </div>
      <!-- Dropdown -->
      <div class="flex items-center gap-1 bg-white/4 rounded-lg px-3 py-2 cursor-pointer">
        <Select v-model="selectedPreset">
          <SelectTrigger
            class="bg-transparent border-none shadow-none p-0 h-auto w-auto focus:ring-0 focus:outline-none">
            <span class="text-white/80 text-sm capitalize">{{ selectedPreset }}</span>
          </SelectTrigger>
          <SelectContent class="w-40 min-w-0 right-0 left-auto mt-2 bg-black/40">
            <SelectItem v-for="list in presetsLists" :key="list.value" :value="list.value">
              {{ list.name }}
            </SelectItem>
          </SelectContent>
        </Select>
      </div>
      <!-- Hidden -->
      <button class="flex items-center gap-1 text-white/40 text-sm cursor-pointer">
        <EyeOff class="w-4 h-4" />
        Hidden
      </button>
      <!-- Add columns -->
      <button class="flex items-center gap-1 text-white/40 text-sm cursor-pointer" @click="openColumnModal">
        <PackagePlus class="w-4 h-4" />
        Add columns
      </button>
      <!-- Legend -->
      <button class="flex items-center gap-1 text-white/40 text-sm cursor-pointer">
        <CircleAlert class="w-4 h-4" />
        Legend
      </button>
    </div>
    <div class="flex flex-row w-full py-5 flex-1">
      <div v-for="(col, index) in enabledColumns" :key="col.title"
        class="flex flex-col border-r border-r-white/10 last:border-r-0"
        :style="{ width: `${100 / enabledColumns.length}%` }">
        <div class="flex flex-row items-center justify-between gap-2 px-2 py-1">
          <div class="flex flex-row items-center gap-2">
            <GripVertical class="w-4 h-4 text-white/50 cursor-pointer" />
            <span class="text-white font-medium text-lg">{{ col.title }}</span>
            <FunnelIcon class="w-4 h-4 text-white cursor-pointer" />
          </div>
          <button class="text-white/50 hover:text-white transition-colors bg-[#da540061] rounded-xl py-1 px-2">
            <PlayIcon class="w-4 h-4 fill-white" />
          </button>
        </div>
        <div class="flex flex-col flex-1 relative">
          <div class="flex flex-col w-full h-full absolute inset-0">
            <ScrollArea class="w-full overflow-hidden p-2">
              <div v-if="launchpadsByColumn[col.title].length > 0" class="flex flex-col w-full">
                <AdvancedCard v-for="(launchpad, idx) in launchpadsByColumn[col.title]" :key="idx"
                  :launchpad="launchpad" />
              </div>
              <div v-else class="flex flex-col items-center justify-center bg-white/10 rounded-lg p-4 w-full gap-2">
                <Inbox class="w-7 h-7 text-white/50" />
                <div class="text-white/50 text-sm">It's empty here so far</div>
              </div>
            </ScrollArea>
          </div>
        </div>
      </div>
    </div>
  </AdvancedLayout>

  <!-- Add Column Modal -->
  <template v-if="addColumnModal">
    <div class="fixed inset-0 bg-gray-900/50 flex items-center justify-center z-[999999]">
      <div class="bg-gray-900 rounded-3xl p-8 w-full max-w-sm relative shadow-xl border border-white/10">
        <!-- Close button -->
        <button class="absolute top-4 right-4 text-gray-400 hover:text-white text-2xl" @click="addColumnModal = false">
          <X class="w-5 h-5" />
        </button>
        <!-- Title and subtitle -->
        <h2 class="text-2xl font-semibold text-white mb-1">Column Manager</h2>
        <div class="text-gray-400 mb-4">You can manage your existing columns below</div>
        <!-- Reset all -->
        <button @click="resetAllColumns"
          class="mb-4 px-4 py-1 rounded-lg bg-white/10 text-white text-sm hover:bg-white/20 transition">Reset
          all</button>
        <!-- Column list -->
        <div class="flex flex-col gap-3 mb-6">
          <div v-for="(col, idx) in tempColumnManage" :key="idx"
            class="flex items-center justify-between rounded-lg px-4 py-3 border border-white/10 w-full">
            <div class="flex items-center gap-3">
              <div class="flex flex-col gap-1">
                <div class="text-white font-medium">{{ col.title }}</div>
                <div class="text-xs text-gray-400">{{ col.subtitle }}</div>
              </div>
            </div>
            <Switch :checked="col.enabled" @update:checked="col.enabled = $event" />
          </div>
        </div>
        <!-- Save changes -->
        <button @click="saveColumns"
          class="w-full py-3 rounded-xl bg-gradient-to-r from-orange-400 to-orange-600 text-white font-semibold text-lg shadow hover:opacity-90 transition">
          Save changes
        </button>
      </div>
    </div>
  </template>

  <!-- Trade Settings Modal -->
  <template v-if="tradeSettingsModal">
    <div class="fixed inset-0 bg-gray-900/50 flex items-center justify-center z-[999999]">
      <div class="bg-gray-900 rounded-3xl p-8 w-full max-w-sm relative shadow-xl border border-white/10">
        <!-- Close button -->
        <button class="absolute top-4 right-4 text-gray-400 hover:text-white text-2xl" @click="closeTradeSettings">
          <X class="w-5 h-5" />
        </button>
        <!-- Title and subtitle -->
        <h2 class="text-2xl font-semibold text-white mb-1">Advanced Trade Settings</h2>
        <div class="text-gray-400 mb-4 text-sm">These settings will apply to all advanced quick buy and sell orders,
          including those placed on the advanced coin page order form.</div>
        <!-- Buy/Sell Tabs -->
        <div class="flex mb-4 bg-white/5 rounded-full p-1">
          <button v-for="tab in TRADE_SETTINGS" :key="tab.value"
            :class="['flex-1 py-2 rounded-full font-semibold text-sm transition', tradeTab === tab.value ? 'bg-gradient-to-r from-orange-400 to-orange-600 text-white shadow' : 'text-white/40']"
            @click="setTradeTab(tab.value)">{{ tab.name }}</button>
        </div>
        <!-- Preset Tabs -->
        <div class="flex gap-2 mb-4">
          <button v-for="list in presetsLists" :key="list.value"
            :class="['px-4 py-1 rounded-lg text-sm font-medium', tradePreset === list.value ? 'bg-white/10 text-white' : 'bg-transparent text-white/40']"
            @click="setTradePreset(list.value)">{{ list.name }}</button>
        </div>
        <!-- Settings Fields -->
        <div class="grid grid-cols-3 gap-3 mb-4">
          <div class="flex flex-col justify-between rounded-lg p-3 border border-white/10">
            <span class="text-xs text-white/50 mb-1">Slippage</span>
            <FormInput v-model="slippage" type="number" min="0" max="100"
              inputClasses="bg-transparent text-white text-lg font-semibold outline-none" size="sm">
              <template #trail>
                <span class="text-white/40 text-sm">%</span>
              </template>
            </FormInput>
          </div>
          <div class="flex flex-col justify-between rounded-lg p-3 border border-white/10">
            <span class="text-xs text-white/50 mb-1">Priority</span>
            <FormInput v-model="priority" type="number" step="0.001" min="0"
              inputClasses="bg-transparent text-white text-lg font-semibold w-full outline-none" size="sm" />
          </div>
          <div class="flex flex-col justify-between rounded-lg p-3 border border-white/10">
            <span class="text-xs text-white/50 mb-1">Bribe</span>
            <FormInput v-model="bribe" type="number" step="0.001" min="0"
              inputClasses="bg-transparent text-white text-lg font-semibold w-full outline-none" size="sm" />
          </div>
        </div>
        <!-- Auto Bribe -->
        <div class="flex items-center justify-between border border-white/10 rounded-lg p-3 mb-3">
          <div class="flex items-center gap-2">
            <span class="text-white/80 text-sm">Auto Bribe</span>
            <span class="text-white/40 text-xs">Max</span>
            <FormInput v-model="autoBribeMax" type="number" step="0.01" min="0"
              inputClasses="bg-transparent text-white text-sm outline-none" />
          </div>
          <Switch v-model:checked="autoBribe" />
        </div>
        <!-- MEV Protection -->
        <div class="flex items-center justify-between border border-white/10 rounded-lg p-3 mb-6">
          <span class="text-white/80 text-sm">MEV Protection</span>
          <Switch v-model:checked="mevProtection" />
        </div>
        <!-- Done Button -->
        <button @click="closeTradeSettings"
          class="w-full py-3 rounded-xl bg-gradient-to-r from-orange-400 to-orange-600 text-white font-semibold text-lg shadow hover:opacity-90 transition">
          Done
        </button>
      </div>
    </div>
  </template>
</template>