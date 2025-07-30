<script setup>
	import { FileCode, Filter } from "lucide-vue-next";

	import AddressLink from "@/Components/AddressLink.vue";
	import { useBillions } from "@/hooks";
	import usePriceInfo from "@/hooks/usePriceInfo";

	const props = defineProps({
		holders: Array,
		bcurve: String,
		chainId: Number,
		launchpad: {
			type: Object,
			required: true,
		},
		usdRate: {
			type: [String, Number],
			required: true,
		},
	});

	const { formatted } = usePriceInfo(props.launchpad, props.usdRate);
	console.log(props.holders);
</script>
<template>
	<div class="w-fulln text-sm bg-gray-850 rounded-lg overflow-hidden">
		<table class="w-full">
			<thead>
				<tr class="text-left text-gray-400 text-sm">
					<th class="px-6 py-3">#</th>
					<th class="px-6 py-3">ADDRESS</th>
					<th class="px-6 py-3">%</th>
					<th class="px-6 py-3">AMOUNT</th>
					<th class="px-6 py-3">VALUE</th>
					<th class="px-6 py-3">TXNS</th>
				</tr>
			</thead>
			<tbody>
				<tr
					v-for="(holder, rank) in holders"
					:key="holder.id"
					class="border-t border-gray-750 text-gray-300">
					<td class="px-4 py-2 text-gray-500">#{{ rank + 1 }}</td>
					<td class="px-4 py-2 font-mono">
						<div class="flex items-center">
							<AddressLink
								class="text-primary hover:text-primary-dark"
								:address="holder.address"
								:len="6"
								:chainId="chainId" />

							<FileCode
								v-if="
									`${holder.address}`.toLowerCase() ==
									`${bcurve}`.toLowerCase()
								"
								class="w-4 h-4 ml-2 inline-flex" />
						</div>
					</td>
					<td class="px-4 py-2">{{ holder.percentage }}%</td>
					<td class="px-4 py-2 relative">
						<div class="flex items-center">
							<span class="mr-2">
								{{ useBillions(holder.qty) }}
							</span>
							<div class="w-48 bg-gray-700 h-2 rounded-full">
								<div
									class="bg-primary h-2 rounded-full"
									:style="{
										width: `${holder.percentage}%`,
									}"></div>
							</div>
							<span class="ml-2">999.9M</span>
						</div>
					</td>
					<td class="px-4 py-2">
						${{ (holder.qty * formatted.priceInUsd).toFixed(6) }}
					</td>
					<td class="px-4 py-2">
						<div class="flex justify-center">
							<Filter class="w-5 h-5 text-gray-500" />
						</div>
					</td>
				</tr>
			</tbody>
		</table>
	</div>
</template>
