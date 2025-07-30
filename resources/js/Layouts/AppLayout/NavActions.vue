<script setup>
import { useAccount } from "@wagmi/vue";
import { Plus } from "lucide-vue-next";

import PrimaryButton from "@/Components/PrimaryButton.vue";
import Web3Auth from "@/Pages/Auth/Web3Auth.vue";

const { isConnected } = useAccount();

defineProps({
  mobile: Boolean
});
</script>

<template>
  <div v-if="mobile" class="flex items-center w-full">
    <div class="flex rounded-full gap-1 overflow-hidden">
      <PrimaryButton
        link
        href="/"
        class="!rounded-none !rounded-l-full !rounded-r-none !bg-transparent text-white px-5 py-2 font-normal border-r border-white/20 text-sm"
      >
        {{ $t('Create coin') }}
      </PrimaryButton>
      <Web3Auth class="!rounded-none !rounded-r-full !rounded-l-none !bg-gradient-to-r from-orange-500 to-orange-700 text-white px-5 py-2 border-0" full
      />
    </div>
  </div>
  <div v-else class="flex lg:items-center lg:space-x-4">
    <PrimaryButton
      link
      href="/"
      :class="'mr-2 rounded-full px-5 py-4 text-white hover:bg-transparent flex items-center gap-1 border border-white/10 text-sm ' + (isConnected ? 'bg-primary' : 'bg-transparent')"
    >
      {{ $t('Create Coin') }}
      <Plus class="w-4 h-4" />
    </PrimaryButton>
    <Web3Auth />
  </div>
</template> 