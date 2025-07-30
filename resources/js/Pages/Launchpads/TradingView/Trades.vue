<script setup>
	import { onMounted, onUnmounted, ref } from "vue";

	import { Link, usePage } from "@inertiajs/vue3";
	import { ExternalLink } from "lucide-vue-next";

	import ChainSymbol from "@/Components/ChainSymbol.vue";
	import LargeDecimal from "@/Components/LargeDecimal.vue";
	import Pagination from "@/Components/Pagination.vue";
	import { ScrollArea, ScrollBar } from '@/Components/ui/scroll-area';
	import { shortenAddress } from "@/lib/wagmi";

	const props = defineProps({
		trades: Object,
		chainId: Number,
	});
	const page = usePage();
	const launchpad = page.props.launchpad;
	const recentTrades = ref([...props.trades.data]);

	const formatNumber = (number) => {
		return new Intl.NumberFormat("en-US", {
			minimumFractionDigits: 2,
			maximumFractionDigits: 8,
		}).format(number);
	};

	// WebSocket handling
	const handleNewTrade = (trade) => {
		recentTrades.value.unshift(trade);
		if (recentTrades.value.length > 12) {
			recentTrades.value.pop();
		}
	};

	// Lifecycle
	onMounted(() => {
		window.Echo.channel(`launchpad.${launchpad.id}`).listen(
			"NewTradeEvent",
			handleNewTrade,
		);
	});

	onUnmounted(() => {
		window.Echo.leave(`launchpad.${launchpad.id}`);
	});
	console.log(recentTrades);
</script>

<template>
	<ScrollArea class="w-full overflow-x-hidden">
		<div class="w-full min-w-[700px]">
			<table class="w-full">
				<thead>
					<tr class="text-gray-500 text-xs uppercase">
						<th class="px-6 py-3 text-left font-medium">From Address</th>
						<th class="px-6 py-3 text-left font-medium">Time</th>
						<th class="px-6 py-3 text-left font-medium">Type</th>
						<th class="px-6 py-3 text-left font-medium">Amount</th>
						<th class="px-6 py-3 text-left font-medium">Transaction</th>
					</tr>
				</thead>
				<tbody class="border-t border-white/10">
					<tr v-for="trade in recentTrades" :key="trade.id" class="text-gray-400 text-sm">
						<td class="px-6 py-2 whitespace-nowrap">{{ shortenAddress(trade.address) ?? '' }}</td>
						<td class="px-6 py-2 whitespace-nowrap">{{ trade.date ?? '17s ago' }}</td>
						<td class="px-6 py-2 whitespace-nowrap font-semibold" :class="trade.type === 'buy' ? 'text-emerald-400' : 'text-red-500'">
							{{ trade.type === 'buy' ? 'Buy' : 'Sell' }}
						</td>
						<td class="px-6 py-2 whitespace-nowrap">{{ trade.amount ?? '0' }}</td>
						<td class="px-6 py-2 whitespace-nowrap">
							<a :href="`https://snowtrace.io/tx/${trade.txid}`" target="_blank" class="text-gray-400 text-xs flex items-center gap-1">
								{{ shortenAddress(trade.txid) ?? '' }}
								<ExternalLink class="w-3 h-3" />
							</a>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<ScrollBar orientation="horizontal" />
	</ScrollArea>
	<Pagination v-if="trades?.meta" :meta="trades.meta" />
</template>
