<script setup>
	defineProps({
		stats: {
			type: Object,
			required: true,
		},
	});

	const formatPercentage = (value) => {
		return value > 0 ? `+${value}%` : `${value}%`;
	};

	const formatUSD = (value) => {
		return `$${Number(value).toLocaleString()}`;
	};
</script>
<template>
	<div v-if="stats">
		<!-- Price Changes -->
		<div class="grid grid-cols-4 mb-4">
			<div
				v-for="(change, period) in stats.price_changes"
				:key="period"
				class="text-center">
				<div class="text-gray-400 text-sm">
					{{ period.toUpperCase() }}
				</div>
				<div :class="change >= 0 ? 'text-green-400' : 'text-red-400'">
					{{ formatPercentage(change) }}
				</div>
			</div>
		</div>

		<!-- Trading Stats -->
		<div class="bg-white/10 rounded-lg p-4 mb-4">
			<!-- Transactions -->
			<div class="grid grid-cols-3 gap-4 mb-4">
				<div>
					<div class="text-gray-400 text-sm mb-1">TXNS</div>
					<div>{{ stats.transactions.total }}</div>
				</div>
				<div>
					<div class="text-gray-400 text-sm mb-1">BUYS</div>
					<div>{{ stats.transactions.buys }}</div>
				</div>
				<div>
					<div class="text-gray-400 text-sm mb-1">SELLS</div>
					<div>{{ stats.transactions.sells }}</div>
				</div>
			</div>

			<!-- Volume -->
			<div class="grid grid-cols-3 gap-4 mb-4">
				<div>
					<div class="text-gray-400 text-sm mb-1">VOLUME</div>
					<div>{{ formatUSD(stats.volume.total) }}</div>
				</div>
				<div>
					<div class="text-gray-400 text-sm mb-1">BUY VOL</div>
					<div>{{ formatUSD(stats.volume.buy) }}</div>
				</div>
				<div>
					<div class="text-gray-400 text-sm mb-1">SELL VOL</div>
					<div>{{ formatUSD(stats.volume.sell) }}</div>
				</div>
			</div>

			<!-- Participants -->
			<div class="grid grid-cols-3 gap-4">
				<div>
					<div class="text-gray-400 text-sm mb-1">MAKERS</div>
					<div>{{ stats.participants.total }}</div>
				</div>
				<div>
					<div class="text-gray-400 text-sm mb-1">BUYERS</div>
					<div>{{ stats.participants.buyers }}</div>
				</div>
				<div>
					<div class="text-gray-400 text-sm mb-1">SELLERS</div>
					<div>{{ stats.participants.sellers }}</div>
				</div>
			</div>
		</div>
	</div>
</template>
