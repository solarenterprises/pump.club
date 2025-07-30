<script setup>
import { onMounted, ref, computed } from 'vue';

import { Head } from '@inertiajs/vue3';
import { useAccount } from '@wagmi/vue';
import { Camera, Copy, X } from 'lucide-vue-next';

import CreatorRewardsCard from '@/Components/CreatorRewardsCard.vue';
import Pagination from "@/Components/ui/pagination/Pagination.vue";
import { ScrollArea, ScrollBar } from '@/Components/ui/scroll-area';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/Components/ui/tabs';
import AppLayout from '@/Layouts/AppLayout.vue';
import { shortenAddress } from '@/lib/wagmi';

const user = {
  username: '@kevin_91',
  avatar: '/profile_avatar.png',
  address: 'ZGHBM...bD7z',
  solscanUrl: 'https://solscan.io/account/youraddress',
  followers: 123,
  following: 0,
  createdCoins: 3,
  balances: [
    { name: 'Avalanche', amount: '0.0200 AVAX', marketCap: '$83B', value: '$3.12', icon: '/avax-icon.svg' },
    { name: 'Avalanche', amount: '0.0200 AVAX', marketCap: '$83B', value: '$3.12', icon: '/avax-icon.svg' },
    { name: 'Avalanche', amount: '0.0200 AVAX', marketCap: '$83B', value: '$3.12', icon: '/avax-icon.svg' },
    { name: 'Avalanche', amount: '0.0200 AVAX', marketCap: '$83B', value: '$3.12', icon: '/avax-icon.svg' },
    { name: 'Avalanche', amount: '0.0200 AVAX', marketCap: '$83B', value: '$3.12', icon: '/avax-icon.svg' },
    { name: 'Avalanche', amount: '0.0200 AVAX', marketCap: '$83B', value: '$3.12', icon: '/avax-icon.svg' },
    { name: 'Avalanche', amount: '0.0200 AVAX', marketCap: '$83B', value: '$3.12', icon: '/avax-icon.svg' },
    { name: 'Avalanche', amount: '0.0200 AVAX', marketCap: '$83B', value: '$3.12', icon: '/avax-icon.svg' },
    { name: 'Avalanche', amount: '0.0200 AVAX', marketCap: '$83B', value: '$3.12', icon: '/avax-icon.svg' },
  ],
  coins: [
    { name: 'Doggy', symbol: 'DOGY', value: '$4.4K', time: '4m ago', icon: '/sample_coin.svg' },
    { name: 'Catty', symbol: 'CATY', value: '$4.4K', time: '4m ago', icon: '/sample_coin.svg' },
    { name: 'Dino', symbol: 'DINO', value: '$4.4K', time: '4m ago', icon: '/sample_coin.svg' },
    { name: 'Dino', symbol: 'DINO', value: '$4.4K', time: '4m ago', icon: '/sample_coin.svg' }
  ],
  whoToFollow: [
    { username: '@CHVw3r', followers: 1306, avatar: '/sample_follower.svg' },
    { username: '@ZHVg2r', followers: 1403, avatar: '/sample_follower.svg' },
    { username: '@KHVw4r', followers: 1201, avatar: '/sample_follower.svg' },
    { username: '@KHVw4r', followers: 1201, avatar: '/sample_follower.svg' }
  ],
  followers: [
    { username: '@CHVw3r', avatar: 'https://randomuser.me/api/portraits/men/32.jpg', message: 'followed you' },
    { username: '@JaneDoe', avatar: 'https://randomuser.me/api/portraits/women/44.jpg', message: 'followed you' },
    { username: '@CryptoKing', avatar: 'https://randomuser.me/api/portraits/men/65.jpg', message: 'followed you' },
    { username: '@Alice', avatar: 'https://randomuser.me/api/portraits/women/12.jpg', message: 'followed you' },
    { username: '@Bob', avatar: 'https://randomuser.me/api/portraits/men/23.jpg', message: 'followed you' },
  ]
};

const tabList = [
  { value: 'balances', label: 'Balances' },
  { value: 'coins', label: 'Coins' },
  { value: 'replies', label: 'Replies' },
  { value: 'followers', label: 'Followers' }
];

const { address } = useAccount();
const copied = ref(false);
const showEditModal = ref(false);

function openEditModal() {
  showEditModal.value = true;
}

function closeEditModal() {
  showEditModal.value = false;
}

function copyAddress() {
  if (address?.value) {
    navigator.clipboard.writeText(address.value);
    copied.value = true;
    setTimeout(() => copied.value = false, 1200);
  }
}

const currentPage = ref(1);
const followersPerPage = 3;

const paginatedFollowers = computed(() => {
  const start = (currentPage.value - 1) * followersPerPage;
  return user.followers.slice(start, start + followersPerPage);
});

const totalPages = computed(() =>
  Math.ceil(user.followers.length / followersPerPage)
);

function onPageChange(page) {
  currentPage.value = page;
}

const navHeight = ref(90);
const navRef = ref(null);

onMounted(() => {
  if (navRef.value) {
    navHeight.value = navRef.value.offsetHeight;
  }
});

const stats = [
  { label: "Followers", value: 123 },
  { label: "Following", value: 0 },
  { label: "Created coins", value: 3 }
];

</script>

<template>
    <Head title="Profile" />
    <AppLayout compact>
		<div class="flex flex-col md:flex-row gap-8 py-10 mx-4 md:mx-24" :style="{ paddingTop: `calc(50px + ${navHeight}px)` }">
			<div class="md:w-8/12 w-full p-2 md:p-0">
				<div class="flex flex-col bg-black/50 rounded-3xl p-10 w-full">
					<!-- Profile Header -->
					<div class="flex flex-col md:flex-row items-center justify-between mb-8 gap-6">
						<div class="flex flex-col md:flex-row items-center gap-6">
							<img :src="user.avatar" class="w-24 h-24 rounded-full object-cover border-4 border-black/30" />
							<div class="flex flex-col items-center gap-2">
								<span class="text-3xl text-white font-semibold">{{ user.username }}</span>
								<div class="flex items-center gap-2">
									<span
										class="bg-[#232323] text-white/60 px-3 py-1 rounded-lg text-sm font-mono flex items-center gap-2 cursor-pointer relative"
										@click="copyAddress"
									>
										{{ shortenAddress(address) }}
                    <Copy :class="['w-3 h-3 transition-colors', copied ? 'text-primary' : 'text-white/40']" />
									</span>
									<a :href="`https://snowtrace.io/address/${address}`" target="_blank" class="text-white/60 hover:text-orange-400 text-xs ml-2 transition">View on snowtrace &rsaquo;</a>
								</div>
							</div>
						</div>
            <button class="md:w-auto w-full px-8 py-2 rounded-lg font-medium text-[1rem] text-[#da5200] bg-[#da520024] hover:bg-[#da520044] transition text-center shadow-none border-none cursor-pointer" 
            @click="openEditModal"
            >
                Edit
            </button>
					</div>
          <div class="flex justify-start items-start py-4 px-2 w-full max-w-md gap-10">
            <div
              v-for="(stat, idx) in stats"
              :key="stat.label"
              class="flex flex-col items-center"
            >
              <span class="text-2xl md:text-3xl font-semibold text-white">{{ stat.value }}</span>
              <span class="text-xs md:text-sm text-gray-400 mt-1">{{ stat.label }}</span>
            </div>
          </div>
					<!-- Tabs using shadcn-vue -->
				</div>
        <Tabs default-value="balances" class="w-full mt-8">
          <ScrollArea class="w-full overflow-x-hidden">
              <TabsList class="flex items-center justify-start border-b border-white/10 bg-transparent px-0 mb-2 w-full min-w-[700px]">
              <TabsTrigger
                v-for="tab in tabList"
                :key="tab.value"
                :value="tab.value"
                class="pb-2 mr-5 text-white/60 font-normal border-b border-transparent data-[state=active]:text-white data-[state=active]:border-orange-500"
              >
                {{ tab.label }}
              </TabsTrigger>
            </TabsList>
            <ScrollBar orientation="horizontal" />
          </ScrollArea>
          <TabsContent value="balances" class="mt-4">
            <div v-for="bal in user.balances" :key="bal.name" class="flex items-center justify-between bg-black/30 px-2 md:px-6 py-3 border-b border-white/10 last:border-b-0">
              <div class="flex items-center gap-3">
                  <img :src="bal.icon" class="w-5 h-5" />
                <span class="text-white text-sm">{{ bal.name }}</span>
                <span class="text-white/60 text-sm">{{ bal.amount }}</span>
              </div>
              <div class="flex gap-2 md:gap-6 text-white/60 text-sm">
                <span>Market cap: <span class="font-normal text-white">{{ bal.marketCap }}</span></span>
                <span>Value: <span class="font-normal text-white">{{ bal.value }}</span></span>
              </div>
            </div>
          </TabsContent>
          <TabsContent value="coins" class="text-white/60">
            <CreatorRewardsCard />
                <div class="divide-y divide-[#232323] max-w-2xl mx-auto">
                    <div
                    v-for="coin in user.coins"
                    :key="coin.symbol"
                    class="flex items-center py-4"
                    >
                        <img
                            :src="coin.icon"
                            class="w-10 h-10 rounded-lg object-cover mr-4"
                            alt="coin"
                        />
                        <div class="flex flex-col flex-1">
                            <span class="text-white font-semibold">{{ coin.name }}</span>
                            <span class="text-xs text-gray-400">{{ coin.symbol }}</span>
                        </div>
                        <div class="text-sm text-white/80 ml-auto">
                            Market cap: <span class="font-semibold text-white">${{ coin.value }}</span>
                        </div>
                    </div>
                </div>
          </TabsContent>
          <TabsContent value="replies" class="text-white/60">
                         Replies content here
                      </TabsContent>
          <TabsContent value="followers" class="text-white/60">
            <div
                v-for="follower in paginatedFollowers"
                :key="follower.username"
                class="bg-[#131212] rounded-xl flex items-center justify-between px-6 py-4 mb-6 shadow-sm w-full"
            >
            
                <div class="flex items-center gap-4">
                <img
                    :src="follower.avatar"
                    alt="Avatar"
                    class="w-12 h-12 rounded-full object-cover border-2 border-[#232323]"
                />
                <div>
                    <span class="font-semibold text-white text-base">{{ follower.username }}</span>
                    <span class="ml-2 text-gray-400 text-base">{{ follower.message }}</span>
                </div>
                </div>
  
                <button class="ml-auto bg-gradient-to-r to-orange-900 from-primary text-white px-7 py-2 rounded-full font-normal">Follow</button>
            </div>
            <Pagination
                :current-page="currentPage"
                :total-pages="totalPages"
                @update:page="onPageChange"
            />
        </TabsContent>
        </Tabs>
			</div>
			<div class="flex flex-col md:w-4/12 w-full gap-6">
				<!-- Created Coins -->
				<div class="bg-black/50 rounded-3xl p-6">
					<h3 class="text-white font-normal text-lg mb-4 flex items-center gap-2">
						Created coins <span class="bg-white/10 text-xs px-2 py-0.5 rounded-full">{{ user.coins.length }}</span>
					</h3>
					<div v-for="coin in user.coins" :key="coin.name" class="flex items-center gap-3 mb-3 border-b border-white/10 last:border-b-0 pb-3">
						<img :src="coin.icon" class="w-10 h-10 rounded-xl" />
						<div>
							<div class="text-white font-normal">{{ coin.name }}</div>
							<div class="text-white/40 text-xs">{{ coin.symbol }}</div>
						</div>
						<div class="ml-auto text-white/80 text-sm">{{ coin.value }}</div>
						<div class="text-white/40 text-xs ml-2">{{ coin.time }}</div>
					</div>
				</div>
				<!-- Who to Follow -->
				<div class="bg-black/50 rounded-3xl p-6">
					<h3 class="text-white font-normal text-lg mb-4">Who to follow</h3>
					<div v-for="person in user.whoToFollow" :key="person.username" class="flex items-center gap-3 mb-3 border-b border-white/10 last:border-b-0 pb-3">
						<img :src="person.avatar" class="w-10 h-10 rounded-full" />
						<div>
							<div class="text-white font-normal">{{ person.username }}</div>
							<div class="text-white/40 text-xs">{{ person.followers }} followers</div>
						</div>
						<button class="ml-auto bg-gradient-to-r to-orange-900 from-primary text-white px-7 py-2 rounded-full font-normal">Follow</button>
					</div>
				</div>
			</div>
		</div>
        <template v-if="showEditModal">
            <div class="fixed inset-0 z-50 flex md:items-center items-end justify-center bg-gray-900/50">
                <div class="relative bg-[#181818] rounded-3xl w-full max-w-sm mx-auto p-10 shadow-lg flex flex-col items-center">
                <!-- Close button -->
                <button
                    class="absolute top-6 right-6 text-gray-400 hover:text-white text-2xl"
                    @click="closeEditModal"
                    aria-label="Close"
                >
                    <X class="w-6 h-6" />
                </button>
                <!-- Title -->
                <div class="text-white text-2xl font-semibold mb-1 text-center">Fill in the profile</div>
                <div class="text-gray-400 text-center mb-6 text-sm">Download the avatar and install username</div>
                <!-- Avatar upload -->
                <div class="flex flex-col items-center mb-6">
                    <div class="bg-gradient-to-br from-[#FF7300] to-[#DA5200] rounded-full p-0.5 mb-2">
                    <div class="bg-[#232323] rounded-full w-24 h-24 flex items-center justify-center">
                        <!-- Camera Icon SVG -->
                        <Camera class="w-8 h-8 text-white" />
                    </div>
                    </div>
                    <button class="text-white mt-2 text-sm font-medium hover:underline">Upload photo &rsaquo;</button>
                </div>
                <!-- Form -->
                <form class="w-full flex flex-col gap-4">
                    <div>
                    <label class="text-white text-sm mb-1 block">Username</label>
                    <input
                        type="text"
                        placeholder="Enter your username"
                        class="w-full bg-[#232323] text-white/80 rounded-lg px-4 py-2 mt-1 outline-none border-none placeholder:text-gray-500"
                    />
                    <div class="text-xs text-gray-500 mt-1">You can change your username once every day</div>
                    </div>
                    <div>
                    <label class="text-white text-sm mb-1 block">Bio</label>
                    <textarea
                        rows="3"
                        placeholder="Write a short description"
                        class="w-full bg-[#232323] text-white/80 rounded-lg px-4 py-2 mt-1 outline-none border-none placeholder:text-gray-500 resize-none"
                    ></textarea>
                    </div>
                    <div class="flex justify-center">
                    <button
                    type="submit"
                    class="mt-2 bg-gradient-to-r to-orange-900 from-primary text-white font-semibold py-2 px-10 rounded-full shadow transition hover:brightness-110"
                        >
                        Save changes
                        </button>
                    </div>
                </form>
                </div>
            </div>
        </template>
    </AppLayout>
</template>