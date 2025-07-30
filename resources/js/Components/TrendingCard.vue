<script setup>
import { Link } from "@inertiajs/vue3";
const props = defineProps({
    launchpad: Object,
});

</script>
<template>
    <Link :href="route('launchpads.show', { launchpad: launchpad.contract })"
        class="bg-gray-800/50 rounded-[32px] py-1 px-3 flex items-center gap-4 w-[340px] flex-shrink-0"
        draggable="false">
    <div class="w-24 h-24 rounded-3xl overflow-hidden flex-shrink-0">
        <img :src="launchpad.logo ?? '/indexcard.png'" class="w-full h-full object-cover rounded-3xl" alt="Launchpad Image"
            draggable="false" @error="$event.target.src = '/indexcard.png'"/>
    </div>
    <div class="flex flex-col gap-2 justify-center overflow-hidden">
        <div>
            <h3 class="text-white font-normal truncate">
                {{ launchpad.name }}
            </h3>
            <p class="text-sm text-gray-400">({{ launchpad.symbol }})</p>
        </div>
        <div class="text-xs text-green-400 bg-green-500/10 rounded-full px-2 py-1 self-start">
            Market cap: ${{ launchpad.marketCap }}
        </div>
        <div class="text-sm text-gray-400">
            Replies: {{ launchpad.msg_count ?? 0 }}
        </div>
    </div>
    </Link>
</template>