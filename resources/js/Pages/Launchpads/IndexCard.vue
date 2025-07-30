<script setup>
import { ref, computed, watch, onMounted } from 'vue';

import { Link } from '@inertiajs/vue3';
import { Star } from 'lucide-vue-next';

import {
  Select,
  SelectTrigger,
  SelectContent,
  SelectItem,
  SelectSeparator
} from '@/Components/ui/select';
import watchLists from '@/store/watchLists';

const useLists = () => {
    const lists = ref([
        { name: 'Main list', default: true },
        { name: 'List #1', default: false },
        { name: 'List #2', default: false },
    ]); 

    const loadLists = () => {
        try {
            const storedLists = localStorage.getItem('watchListsOptions');
            if (storedLists) {
                lists.value = JSON.parse(storedLists);
            }
        } catch (error) {
            console.error('Error loading lists from localStorage:', error);
        }
    };

    return {
        lists,
        loadLists
    };
};

const props = defineProps({
    launchpad: {
        type: Object,
        required: true,
    },
});

const selectedList = ref(null);
const selectOpen = ref(false);

const { lists, loadLists } = useLists();

const isWatchListed = computed(() => {
     const found = watchLists.value.find(
       (item) => item.c_address === props.launchpad.contract
     );
     return found && found.list;
   });

onMounted(() => {
  loadLists();
  const found = watchLists.value.find(
    (item) => item.c_address === props.launchpad.contract
  );
  if (found) {
    selectedList.value = found.list;
  }
});

const removeFromWatchlist = () => {
    const idx = watchLists.value.findIndex(
        (item) => item.c_address === props.launchpad.contract
    );
    if (idx !== -1) {
        watchLists.value.splice(idx, 1);
        selectedList.value = null;
    }
};

const handleStarClick = (event) => {
    event.preventDefault();
    event.stopPropagation();
    
    if (isWatchListed.value) {
        removeFromWatchlist();
    } else {
        selectOpen.value = true;
    }
};

watch(selectedList, (val) => {
     if (val === 'Manage lists') {
         selectOpen.value = false;
         selectedList.value = null;
         return;
     }
     
     if (val === null) {
         return;
     }
     
     const idx = watchLists.value.findIndex(
       (item) => item.c_address === props.launchpad.contract
     );
     if (idx !== -1) {
       watchLists.value[idx].list = val;
     } else {
       watchLists.value.push({
         c_address: props.launchpad.contract,
         list: val,
       });
     }
     selectOpen.value = false;
    });

</script>

<template>
    <Link :href="route('launchpads.show', { launchpad: launchpad.contract })"
        class="group relative bg-gray-800/50 rounded-[32px] p-4 flex flex-col gap-3">
        <div
            class="absolute top-4 right-4 transition z-20"
            :class="{
                'opacity-100': selectOpen,
                'opacity-0 group-hover:opacity-100': !selectOpen
            }"
        >
            <Select
                v-if="!isWatchListed"
                v-model="selectedList"
                :open="selectOpen"
                @update:open="val => selectOpen = val"
            >
                <SelectTrigger class="bg-transparent border-none shadow-none p-0 h-auto w-auto focus:ring-0 focus:outline-none">
                    <Star class="w-5 h-5 text-white" fill="none" />
                </SelectTrigger>
                <SelectContent class="w-40 min-w-0 right-0 left-auto mt-2">
                    <SelectItem 
                        v-for="list in lists" 
                        :key="list.name" 
                        :value="list.name"
                    >
                        {{ list.name }}
                    </SelectItem>
                    <SelectSeparator />
                    <SelectItem value="Manage lists" class="text-gray-400">Manage lists</SelectItem>
                </SelectContent>
            </Select>
            
            <button
                v-else
                @click="handleStarClick"
                class="bg-transparent border-none shadow-none p-0 h-auto w-auto focus:ring-0 focus:outline-none cursor-pointer"
            >
                <Star class="w-5 h-5 text-white" fill="white" />
            </button>
        </div>
        <div
            v-if="launchpad.status"
            :class="launchpad.status && launchpad.status.toLowerCase() === 'bonding'
                    ? 'bg-gray-500 text-white border-gray-400 border'
                    : launchpad.status && launchpad.status.toLowerCase() === 'prebond'
                        ? 'border-gray-700 bg-gray-900 text-white border'
                        : 'bg-[#DA5200]/30 text-[#DA5200] border-[#DA5200] border'"
            class="absolute flex items-center gap-2 -top-4 left-1/2 -translate-x-1/2 text-sm capitalize px-4 py-2 rounded-xl shadow text-center z-10"
        >
            {{ launchpad.status }}
            <img v-if="launchpad.status && launchpad.status.toLowerCase() === 'finalized'" :src="'/star.png'" alt="Status Icon" />
        </div>
        <div class="flex flex-row justify-center gap-3">
        <div class="w-1/3">
            <img :src="launchpad.logo" class="w-full h-full object-cover rounded-3xl"
                alt="Launchpad Image" @error="$event.target.src = '/indexcard.png'" />
        </div>
        <div class="flex flex-col gap-1 w-2/3 p-3">
            <div class="flex items-center gap-2">
                <img :src="launchpad.profile_photo_url ?? '/avatar.png'" class="w-6 h-6 rounded-full" alt="User Avatar"
                    @error="$event.target.src = '/avatar.png'" />
                <div class="text-sm text-gray-400">
                    <span class="font-semibold text-white">
                        @{{ launchpad.name }}
                    </span>
                    <span class="ml-2">{{ launchpad.createdAgo }}</span>
                </div>
            </div>
            <div>
                <h3 class="text-white font-normal">
                    {{ launchpad.name }} ({{ launchpad.symbol }})
                </h3>
            </div>
            <div class="text-xs text-green-400 bg-green-500/10 rounded-full px-2 py-1 self-start">
                Market cap: {{ launchpad.marketCap }}
            </div>
            <div class="text-sm text-gray-400">
                Replies: {{ launchpad.msg_count ?? 0 }}
            </div>
        </div>
    </div>
    <div>
        <p class="text-sm text-gray-400 line-clamp-3">
            {{ launchpad.description }}
        </p>
    </div>
    </Link>
</template>