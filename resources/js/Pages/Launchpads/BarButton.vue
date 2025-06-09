<script setup>
	import { Link } from "@inertiajs/vue3";
	import { UseTimeAgo } from "@vueuse/components";
	import { Clock } from "lucide-vue-next";
	import { DateTime } from "luxon";

	import { useBillions } from "@/hooks";

	defineProps({
		active: Boolean,
		launch: Object,
	});
</script>
<template>
	<Link
		class="px-2"
		v-if="launch?.contract"
		:href="route('launchpads.show', { launchpad: launch?.contract })">
		<div
			:class="
				active
					? 'bg-gray-750 hover:bg-gray-700 '
					: 'bg-transparent hover:bg-gray-750'
			"
			class="flex items-center gap-2 py-1.5 px-3 rounded transition-colors duration-200">
			<span class="text-gray-500 font-bold">#{{ launch.position }}</span>
			<img
				alt="SMOKINCAT"
				class="block w-4 h-4 rounded-[3px] max-w-[initial]"
				:src="launch.logo"
				loading="lazy" />
			<span
				class="box-border text-sm font-semibold break-words max-w-32 overflow-hidden text-ellipsis whitespace-nowrap text-transparent bg-clip-text bg-[length:200%] bg-gradient-to-r from-[#ff7700] to-[#f0b90b]">
				{{ launch.symbol }}
			</span>
			<div class="flex items-center text-xs font-semibold text-[#f0b90b]">
				<svg
					stroke="currentColor"
					fill="currentColor"
					stroke-width="0"
					viewBox="0 0 448 512"
					focusable="false"
					height="1em"
					width="1em"
					xmlns="http://www.w3.org/2000/svg">
					<path
						d="M349.4 44.6c5.9-13.7 1.5-29.7-10.6-38.5s-28.6-8-39.9 1.8l-256 224c-10 8.8-13.6 22.9-8.9 35.3S50.7 288 64 288H175.5L98.6 467.4c-5.9 13.7-1.5 29.7 10.6 38.5s28.6 8 39.9-1.8l256-224c10-8.8 13.6-22.9 8.9-35.3s-16.6-20.7-30-20.7H272.5L349.4 44.6z"
						class=""></path>
				</svg>
				${{ useBillions(launch.total_volume) }}
			</div>
			<span class="text-xs">
				<span class="text-[#a4cf5e]">
					{{
						(() => {
							const high = parseFloat(launch.high) || 0;
							const low = parseFloat(launch.low) || 0;
							if (low === 0) return '0.000';
							return (((high - low) / low) * 100).toFixed(3);
						})()
					}}%
				</span>
			</span>
			<div
				class="text-[#68D391] uppercase flex items-center tracking-widest text-[10px]">
				<Clock class="w-3 h-3 mr-0.5" />
				<UseTimeAgo
					v-slot="time"
					:time="
						DateTime.fromFormat(
							launch.created_at,
							'yyyy-MM-dd HH:mm:ss',
						).toJSDate()
					">
					{{ time?.timeAgo }}
				</UseTimeAgo>
			</div>
		</div>
	</Link>
</template>
