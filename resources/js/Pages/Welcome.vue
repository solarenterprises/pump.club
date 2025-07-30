<!-- eslint-disable import/order -->
<script setup>
import { computed, ref, onMounted } from "vue";

import { router } from "@inertiajs/vue3";
import { debouncedWatch, useUrlSearchParams } from "@vueuse/core";
import {
    LoaderCircle,
    PencilLine,
    Plus,
    Search,
    Star,
    Trash2,
    TrendingUp,
    ArrowUp,
    Zap,
    Clock,
    CheckCircle,
    X,
    Check,
} from "lucide-vue-next";

import BaseButton from "@/Components/BaseButton.vue";
import { Checkbox } from "@/Components/ui/checkbox";
import FormInput from "@/Components/FormInput.vue";
import Pagination from "@/Components/Pagination.vue";
import {
    Select,
    SelectContent,
    SelectGroup,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/Components/ui/select";
import {
    Carousel,
    CarouselContent,
    CarouselItem,
    CarouselNext,
    CarouselPrevious,
} from "@/Components/ui/carousel";
import { useLaunchpadsData } from "@/hooks/useLaunchpadsData";
import AppLayout from "@/Layouts/AppLayout.vue";
import HowItWorksModal from "@/Layouts/AppLayout/HowItWorksModal.vue";
import TrendingCard from "@/Components/TrendingCard.vue";
import BarButton from "@/Pages/Launchpads/BarButton.vue";
import IndexCard from "@/Pages/Launchpads/IndexCard.vue";
import { useChainId } from "@wagmi/vue";
import watchLists from '@/store/watchLists';
import PrimaryButton from "@/Components/PrimaryButton.vue";

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

    // Save lists to localStorage
    const saveLists = () => {
        try {
            localStorage.setItem('watchListsOptions', JSON.stringify(lists.value));
        } catch (error) {
            console.error('Error saving lists to localStorage:', error);
        }
    };

    // Add new list
    const addList = (name) => {
        if (name.trim()) {
            lists.value.push({ name: name.trim(), default: false });
            saveLists();
        }
    };

    // Delete list
    const deleteList = (idx) => {
        if (!lists.value[idx].default) {
            lists.value.splice(idx, 1);
            saveLists();
        }
    };

    // Edit list name
    const editList = (idx, newName) => {
        if (newName && newName.trim()) {
            lists.value[idx].name = newName.trim();
            saveLists();
        }
    };

    return {
        lists,
        loadLists,
        saveLists,
        addList,
        deleteList,
        editList
    };
};

const props = defineProps({
    launchpads: [Array, Object],
    top: Array,
    usdRates: [Array, Object],
    type: String,
});

const launchpadsList = computed(() => props.launchpads.data);
const launchpadsInfo = useLaunchpadsData(launchpadsList, props.usdRates);
const showHowItWorks = ref(false);
const filters = [
    { id: "trending", label: "Trending", icon: TrendingUp },
    { id: "top", label: "Top", icon: ArrowUp },
    { id: "rising", label: "Rising", icon: Zap },
    { id: "new", label: "New", icon: Clock },
    { id: "finalized", label: "Finalized", icon: CheckCircle },
];

const params = useUrlSearchParams("history");
const search = ref(params.search ?? "");
const chainId = useChainId();

debouncedWatch(
    [search],
    ([search]) => {
        router.get(
            window.route("launchpads.index"),
            { search },
            {
                preserveState: true,
                preserveScroll: true,
            },
        );
    },
    {
        maxWait: 700,
    },
);

const categories = ref([
    { emoji: '🐱', label: 'Animal' },
    { emoji: '🇺🇸', label: 'Trump Musk' },
    { emoji: '🐶', label: 'Viral Pets' },
    { emoji: '🌙', label: 'Moon Madness' },
    { emoji: '😸', label: 'Captain Meowrica' },
    { emoji: '🐱', label: 'Animal Vlogger' },
    { emoji: '🇺🇸', label: 'Trump Musk' },
    { emoji: '🌙', label: 'Moon Madness' },
    { emoji: '😸', label: 'Captain Meowrica' },
    { emoji: '🐱', label: 'Animal Vlogger' },
    { emoji: '🇺🇸', label: 'Trump Musk' },
    { emoji: '🌙', label: 'Moon Madness' },
    { emoji: '😸', label: 'Captain Meowrica' },
    { emoji: '🐱', label: 'Animal Vlogger' },
    { emoji: '🇺🇸', label: 'Trump Musk' },
    { emoji: '🌙', label: 'Moon Madness' },
    { emoji: '😸', label: 'Captain Meowrica' },
]);

const selectedTab = ref('all');
const showAddModal = ref(false);

const { lists, loadLists, addList, deleteList, editList } = useLists();
const selectedList = ref('Main list');
const newListName = ref('');

// Add state for editing
const editingListIndex = ref(null);
const editingListName = ref('');

onMounted(() => {
    loadLists();
    if (lists.value.length > 0) {
        selectedList.value = lists.value[0].name;
    }
});

function handleAddList() {
    if (newListName.value.trim()) {
        addList(newListName.value);
        newListName.value = '';
    }
}

function handleDeleteList(idx) {
    deleteList(idx);
    if (lists.value.length > 0 && selectedList.value === lists.value[idx]?.name) {
        selectedList.value = lists.value[0].name;
    }
}

function handleEditList(idx) {
    editingListIndex.value = idx;
    editingListName.value = lists.value[idx].name;
}

// Add function to save the edit
function saveEdit() {
    if (editingListName.value && editingListName.value.trim()) {
        editList(editingListIndex.value, editingListName.value);
        // Update selectedList if the edited list was selected
        if (selectedList.value === lists.value[editingListIndex.value].name) {
            selectedList.value = editingListName.value.trim();
        }
    }
    editingListIndex.value = null;
    editingListName.value = '';
}

// Add function to cancel edit
function cancelEdit() {
    editingListIndex.value = null;
    editingListName.value = '';
}

const selectedFilter = ref(props.type || 'trending');

const watchedLaunchpads = computed(() => {
    const filteredWatchList = watchLists.value.filter(watch => watch.list === selectedList.value);
    
    return filteredWatchList
        .map(watch => launchpadsInfo.launchpads.value.find(lp => lp.contract === watch.c_address))
        .filter(Boolean);
});

const sortedLaunchpads = computed(() => {
    return launchpadsInfo.launchpads.value.slice().sort((a, b) => Number(b.marketCap) - Number(a.marketCap));
});

const navHeight = ref(90);
const navRef = ref(null);

onMounted(() => {
  if (navRef.value) {
    navHeight.value = navRef.value.offsetHeight;
  }
});

</script>

<template>
    <AppLayout compact>
        <template #header>
            <div class="hidden md:flex items-center w-full bg-black relative bg-black/10" :style="{ paddingTop: `calc(10px + ${navHeight}px)` }">
                <div class="flex w-full items-center">
                    <div class="flex w-full items-center">
                    <Carousel class="w-full" :opts="{ align: 'start' }">
                        <CarouselContent>
                        <CarouselItem
                            v-for="(launch, i) in top"
                            :key="launch.id"
                            class="!basis-auto"
                        >
                            <BarButton :launch="launch" :active="i === 0" />
                        </CarouselItem>
                        </CarouselContent>
                    </Carousel>
                    </div>
                </div>
                </div>
        </template>
        <div class="flex flex-col md:grid mx-5 lg:mx-10 pt-24 md:pt-4 pb-12">
            <div v-if="type === 'mine'" class="flex flex-col justify-center">
                <h3 class="flex items-center">
                    <LoaderCircle v-if="launchpadsInfo.loading.value" class="w-6 h-6 mr-2 animate-spin" />
                    {{ $t("My Launchpads") }}
                </h3>
                <div class="flex items-center mt-4 gap-4">
                    <BaseButton link href="/launch" outlined>
                        {{ $t("Launch a new token") }}
                    </BaseButton>
                </div>
            </div>
            <template v-else>
                <div class="flex flex-col gap-4 justify-center items-center mt-10">
                    <h1 class="text-5xl lg:text-6xl font-normal text-white text-center">
                        {{ $t("Find a meme. Pump it. Enjoy") }}
                    </h1>
                    <div class="flex flex-col gap-4 w-full md:w-1/2 lg:w-1/3">
                        <FormInput v-model="search" class="ml-auto mr-auto w-full" size="md" inputClasses="!rounded-3xl"
                            placeholder="Search for meme">
                            <template #lead>
                                <Search class="w-4 h-4 ml-1 text-gray-400" />
                            </template>
                            <template #trail>
                                <PrimaryButton size="xs"
                                    class="rounded-full text-white hover:bg-transparent px-4 py-2.5 cursor-pointer"
                                    style="background: linear-gradient(to right, #6C2801 0%, #DA5200 34%, #E97C02 100%);">
                                    {{ $t("Search") }}
                                </PrimaryButton>
                            </template>
                        </FormInput>
                    </div>
                </div>
                <div class="my-8 overflow-hidden">
                    <Carousel class="w-full" :opts="{
                        align: 'start',
                    }">
                        <div class="flex justify-between items-center mb-4">
                            <h2 class="text-3xl font-semibold text-white">
                                Now trending
                            </h2>
                            <div class="flex items-center gap-2">
                                <CarouselPrevious
                                    class="relative top-auto left-auto right-auto bottom-auto translate-x-0 translate-y-0 text-white " />
                                <CarouselNext
                                    class="relative top-auto left-auto right-auto bottom-auto translate-x-0 translate-y-0 text-white" />
                            </div>
                        </div>
                        <CarouselContent>
                            <CarouselItem v-for="item in sortedLaunchpads" :key="item.id" class="!basis-auto">
                                <TrendingCard :launchpad="item" />
                            </CarouselItem>
                        </CarouselContent>
                    </Carousel>
                </div>
                <div class="my-8 overflow-hidden">
                    <div class="flex justify-between items-center mb-4">
                        <h2 class="text-3xl font-semibold text-white">
                            Explore
                        </h2>
                    </div>
                     <div class="flex flex-col md:flex-row justify-between items-start md:items-center mt-4 pt-4 pb-4 border-b border-b-white/10 gap-4">
                        <div class="flex items-center w-full md:w-auto justify-between gap-2">
                            <div class="flex items-center gap-2">
                                <button
                                    :class="[
                                        'px-4 md:px-8 py-2 md:py-4 text-sm font-medium rounded-full',
                                        selectedTab === 'all' ? 'text-white bg-gray-800/50 border border-zinc-700/50' : 'text-gray-500 bg-gray-800/50 border border-zinc-700/50'
                                    ]"
                                    @click="selectedTab = 'all'"
                                >
                                    All
                                </button>
                                <button
                                    :class="[
                                        'px-4 md:px-8 py-2 md:py-4 text-sm font-medium rounded-full flex items-center gap-1',
                                        selectedTab === 'watchlist' ? 'text-white bg-gray-800/50 border border-zinc-700/50' : 'text-gray-500 bg-gray-800/50 border border-zinc-700/50'
                                    ]"
                                    @click="selectedTab = 'watchlist'"
                                >
                                    <Star class="w-4 h-4" />
                                    Watchlist
                                </button>
                            </div>
                                <div class="text-sm text-gray-500 flex items-center gap-2">
                                    Sort by:
                                    <Select v-model="selectedFilter" @update:model-value="(value) => router.get(route('launchpads.index', { type: value === 'trending' ? '' : value }))">
                                        <SelectTrigger class="w-[120px] md:w-[140px]">
                                            <SelectValue>
                                                <div class="flex items-center gap-2">
                                                    {{ filters.find(f => f.id === selectedFilter)?.label }}
                                                </div>
                                            </SelectValue>
                                        </SelectTrigger>
                                        <SelectContent>
                                            <SelectGroup>
                                                <SelectItem v-for="filter in filters" :key="filter.id" :value="filter.id">
                                                    <div class="flex items-center gap-2">
                                                        {{ filter.label }}
                                                    </div>
                                                </SelectItem>
                                            </SelectGroup>
                                        </SelectContent>
                                    </Select>
                            </div>
                        </div>
                        <div class="flex justify-start items-center gap-4 border-t border-white/10 pt-4 md:pt-0 md:border-t-0 w-full md:w-auto">
                            <label class="flex items-center text-sm text-white gap-2">
                                <Checkbox id="animations" />
                                Animations
                            </label>
                            <label class="flex items-center text-sm text-white gap-2">
                                <Checkbox id="nsfw" />
                                NSFW
                            </label>
                        </div>
                    </div>
                    <template v-if="selectedTab === 'all'">
                        <!-- <div v-if="launchpads.length > 0"> -->
                            <Carousel class="w-full mt-4 mb-4" :opts="{
                                align: 'start',
                            }">
                                <CarouselContent>
                                    <CarouselItem v-for="(category, index) in categories" :key="index"
                                        class="!basis-auto pl-4">
                                        <button
                                            class="flex items-center gap-2 py-2 md:py-4 px-2 md:px-3 text-white bg-gray-800/50 text-sm border border-zinc-700/50 rounded-full hover:bg-zinc-800 whitespace-nowrap">
                                            <span>{{ category.emoji }}</span>
                                            <span>{{ category.label }}</span>
                                        </button>
                                    </CarouselItem>
                                </CarouselContent>
                                <CarouselPrevious
                                    class="absolute top-0 left-0 translate-x-0 translate-y-0 text-white border-none h-full !bg-transparent" />
                                <CarouselNext
                                    class="absolute top-0 right-0 translate-x-0 translate-y-0 text-white border-none h-full !bg-transparent" />
                            </Carousel>
                        <!-- </div> -->
                    </template>
                </div>
                <div class="">
                    <template v-if="selectedTab === 'watchlist'">
                        <div class="flex items-center gap-4 mb-8">
                            <Carousel class="w-full" :opts="{ align: 'start' }">
                                <CarouselContent>
                                    <CarouselItem
                                        v-for="list in lists"
                                        :key="list.name"
                                        class="!basis-auto"
                                    >
                                        <button
                                            :class="[
                                                'px-4 md:px-8 py-2 md:py-4 text-sm font-medium rounded-full whitespace-nowrap',
                                                selectedList === list.name 
                                                    ? 'text-white bg-gray-800/50 border border-zinc-700/50' 
                                                    : 'text-gray-500 bg-gray-800/50 border border-zinc-700/50'
                                            ]"
                                            @click="selectedList = list.name"
                                        >
                                            {{ list.name }}
                                        </button>
                                    </CarouselItem>
                                    <CarouselItem class="!basis-auto">
                                        <button
                                            class="px-4 md:px-8 py-2 md:py-4 text-sm font-medium text-gray-500 bg-gray-800/50 border border-zinc-700/50 rounded-full flex items-center gap-1 whitespace-nowrap"
                                            @click="showAddModal = true"
                                        >
                                            Add
                                            <Plus class="w-4 h-4" />
                                        </button>
                                    </CarouselItem>
                                </CarouselContent>
                            </Carousel>
                        </div>
                        <template v-if="watchedLaunchpads.length > 0">
                            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
                                <IndexCard v-for="(item, index) in watchedLaunchpads" :key="item.c_address"
                                    :launchpad="item" :watchList="true" />
                            </div>
                        </template>
                        <template v-else>
                            <div
                            class="col-span-full flex flex-col items-center justify-center py-20 text-center border border-white/10 rounded-3xl p-10 bg-gray-800/50">
                            <img src="/empty.png" alt="No launchpads found" class="w-24 h-24 text-gray-500" />
                            <h3 class="mt-4 text-xl font-semibold text-white">
                                Your watchlist is empty
                            </h3>
                            <p class="mt-2 text-sm text-gray-400 max-w-md">
                                to add a coin to the watchlist, click the or 'add to <br>watchlist' buttons on a
                                coin
                                detail screen.
                            </p>
                        </div>
                        </template>
                    </template>
                    <template v-else>
                        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
                            <IndexCard v-for="(launchpad, index) in launchpadsInfo.launchpads.value" :key="index"
                                :launchpad="launchpad" :watchList="false" />
                        </div>
                    </template>
                </div>
            </template>
            <LoaderCircle v-if="type !== 'mine' && launchpadsInfo.loading.value"
                class="w-8 mt-5 text-white h-8 mr-2 animate-spin" />
            <Pagination :meta="launchpads.meta" />
            <HowItWorksModal v-model:show="showHowItWorks" />
        </div>
    </AppLayout>
    <template v-if="showAddModal">
        <div class="fixed inset-0 z-50 flex items-end md:items-center justify-center bg-gray-900/50">
            <div class="bg-gray-900 rounded-3xl p-10 w-full max-w-fit relative shadow-xl border border-white/10">
                <button class="absolute top-4 right-4 text-gray-400 hover:text-white text-2xl" @click="showAddModal = false"><X class="w-5 h-5" /></button>
                <h2 class="text-3xl font-normal text-white text-center mb-2">Manage lists</h2>
                <div class="text-gray-400 text-center mb-6">Create new lists or manage your existing lists here</div>
                <div class="border-t border-white/10 mb-6"></div>
                <div class="space-y-3 max-h-[300px] overflow-y-auto scrollbar-thin scrollbar-thumb-gray-700 scrollbar-track-gray-900 pr-1">
                  <div class="flex items-center gap-2 bg-transparent">
                    <input
                      v-model="newListName"
                      type="text"
                      placeholder="Name list"
                      class="flex-1 bg-transparent border border-zinc-700/50 rounded-xl px-4 py-2 text-white placeholder-gray-500 outline-none focus:border-primary"
                      @keyup.enter="handleAddList"
                    />
                    <button
                      @click="handleAddList"
                      class="bg-gradient-to-r from-orange-400 to-yellow-500 text-white font-semibold rounded-xl px-6 py-2 disabled:opacity-50"
                      :disabled="!newListName.trim()"
                    >Add</button>
                  </div>
                  
                  <template v-for="(list, idx) in lists" :key="idx">
                    <div class="flex items-center justify-between bg-[#232326] rounded-xl px-4 py-3">
                        <div v-if="editingListIndex === idx" class="flex-1">
                            <input
                                v-model="editingListName"
                                type="text"
                                class="w-full bg-transparent border border-zinc-700/50 rounded-xl px-4 py-2 text-white outline-none focus:border-primary"
                                @keyup.enter="saveEdit"
                                @keyup.esc="cancelEdit"
                                ref="editInput"
                                @blur="saveEdit"
                            />
                        </div>
                        <span v-else class="text-white font-medium">{{ list.name }}</span>
                        
                        <div class="flex items-center gap-2">
                            <button v-if="!list.default && editingListIndex !== idx" @click="handleEditList(idx)" class="text-gray-400">
                                <PencilLine class="w-4 h-4" />
                            </button>
                            <button v-if="!list.default && editingListIndex !== idx" @click="handleDeleteList(idx)" class="text-red-500">
                                <Trash2 class="w-4 h-4" />
                            </button>
                            <div v-if="editingListIndex === idx" class="flex items-center gap-2">
                                <button @click="saveEdit" class="text-green-500">
                                    <Check class="w-4 h-4" />
                                </button>
                                <button @click="cancelEdit" class="text-red-500">
                                    <X class="w-4 h-4" />
                                </button>
                            </div>
                        </div>
                    </div>
                  </template>
                </div>
            </div>
        </div>
    </template>
</template>
