<script setup>
import { computed, reactive, ref, watch } from "vue";

import { useForm } from "@inertiajs/vue3";
import { useAccount } from "@wagmi/vue";
import { CheckCircle, Cog, Vault, X } from "lucide-vue-next";
import { formatEther, parseEther, parseEventLogs } from "viem";

import ApproveTokenButton from "@/Components/ApproveTokenButton.vue";
import BaseButton from "@/Components/BaseButton.vue";
import ChainSymbol from "@/Components/ChainSymbol.vue";
import FormInput from "@/Components/FormInput.vue";
import TxStatus from "@/Components/TxStatus.vue";
import { ethAmount, tokenAmount } from "@/hooks/swapMath";
import {
	useLaunchpadInfo,
	useReactiveContractCall,
} from "@/hooks/useContractCall";
import NetworkIcon from "@/Icons/NetworkIcon.vue";
import ArrowLeftRight from "@/Pages/Launchpads/TradingView/ArrowLeftRight.vue";

const tabs = [
	{ name: "buy" },
	{ name: "sell" },
];
const activeTab = ref("buy");
const slippage = ref(false);
const props = defineProps({
	launchpad: Object,
});
const tradeType = ref("buy");
const info = useLaunchpadInfo(props.launchpad);
const state = useReactiveContractCall(
	props.launchpad.factory.abi,
	props.launchpad.contract,
);
const useTokenInput = ref(false);
const slippagePercent = ref(5);
const amount = ref(0.1);
const tokens = ref(0);
const swapInfo = reactive({
	expectedOutputAmount: 0, // ETH formatted string
	minimumOutputAmount: 0, // ETH formatted string
	expectedOutputAmountWei: 0, // Wei as string
	minimumOutputAmountWei: 0, // Wei as string
	priceImpact: "0%",
});

const ethReserve = computed(() =>
	info.currentPhase === 0 ? info.virtualEth : info.ethReserve,
);
const tokenReserve = computed(() =>
	info.currentPhase === 0 ? info.tokenBalance : info.tokenReserve,
);
watch(
	[amount, ethReserve, tokenReserve, slippagePercent],
	([ethAmount, ethReserve, tokenReserve, slippagePercent]) => {
		if (useTokenInput.value) return;
		if (parseFloat(ethAmount) === 0) {
			tokens.value = "0";
			return;
		}

		const response = tokenAmount(
			ethReserve,
			tokenReserve,
			`${ethAmount}`,
			slippagePercent,
		);
		tokens.value = response.expectedOutputAmount;
		swapInfo.expectedOutputAmount = response.expectedOutputAmount;
		swapInfo.expectedOutputAmountWei = response.expectedOutputAmountWei;
		swapInfo.minimumOutputAmount = response.minimumOutputAmount;
		swapInfo.minimumOutputAmountWei = response.minimumOutputAmountWei;
		swapInfo.priceImpact = response.priceImpact;
	},
);

watch(
	[tokens, ethReserve, tokenReserve, slippagePercent],
	([tokenAmount, ethReserve, tokenReserve, slippagePercent]) => {
		if (!useTokenInput.value) return;
		const response = ethAmount(
			ethReserve,
			tokenReserve,
			`${tokenAmount}`,
			slippagePercent,
		);
		amount.value = response.expectedOutputAmount;
		swapInfo.expectedOutputAmount = response.expectedOutputAmount;
		swapInfo.expectedOutputAmountWei = response.expectedOutputAmountWei;
		swapInfo.minimumOutputAmount = response.minimumOutputAmount;
		swapInfo.minimumOutputAmountWei = response.minimumOutputAmountWei;
		swapInfo.priceImpact = response.priceImpact;
	},
);
const { address } = useAccount();
const tradeForm = useForm({
	launchpad_id: props.launchpad.id,
	address: address.value,
	qty: tokens.value,
	amount: amount.value,
	txid: null,
	type: info.currentPhase === 0 ? "prebond" : tradeType.value,
});
const setType = (type) => {
	tradeType.value = type;
	useTokenInput.value = type === "sell";
};
const saveTx = (txhash) => {
	tradeForm.txid = txhash;
	tradeForm.qty = tokens.value;
	tradeForm.amount = amount.value;
	tradeForm.type = info.currentPhase === 0 ? "prebond" : tradeType.value;
	tradeForm.post(window.route("trades.store"), {
		preserveState: true,
		preserveScroll: true,
	});
};
const updatePrebondLog = () => {
	const logs = parseEventLogs({
		abi: props.launchpad.factory.abi,
		logs: state.receipt.logs,
		eventName: ["PreBondingContribution"],
	});
	tradeForm.txid = state.txhash;
	tradeForm.type = info.currentPhase === 0 ? "prebond" : tradeType.value;
	tradeForm.qty = formatEther(logs?.[0]?.args?.tokenAmount);
	tradeForm.amount = formatEther(logs?.[0]?.args?.amount);
	tradeForm.address = logs?.[0]?.args?.contributor;
	tradeForm.post(window.route("trades.store"), {
		preserveState: true,
		preserveScroll: true,
	});
};
const updateBuyLog = () => {
	const logs = parseEventLogs({
		abi: props.launchpad.factory.abi,
		logs: state.receipt.logs,
		eventName: ["TokensPurchased"],
	});
	tradeForm.txid = state.txhash;
	tradeForm.type = info.currentPhase === 0 ? "prebond" : tradeType.value;
	tradeForm.qty = formatEther(logs?.[0]?.args?.tokenAmount);
	tradeForm.amount = formatEther(logs?.[0]?.args?.ethAmount);
	tradeForm.address = logs?.[0]?.args?.buyer;
	tradeForm.post(window.route("trades.store"), {
		preserveState: true,
		preserveScroll: true,
	});
};
const updateSellLog = () => {
	const logs = parseEventLogs({
		abi: props.launchpad.factory.abi,
		logs: state.receipt.logs,
		eventName: ["TokensSold"],
	});
	tradeForm.txid = state.txhash;
	tradeForm.qty = formatEther(logs?.[0]?.args?.tokenAmount);
	tradeForm.amount = formatEther(logs?.[0]?.args?.ethAmount);
	tradeForm.address = logs?.[0]?.args?.seller;
	tradeForm.post(window.route("trades.store"), {
		preserveState: true,
		preserveScroll: true,
	});
};

const swap = async () => {
	let method, args, amt, evt;
	if (info.currentPhase === 0) {
		method = "contributePreBonding";
		evt = updatePrebondLog;
		amt = parseEther(`${amount.value}`);
		args = [];
	}
	if (info.currentPhase === 1) {
		if (tradeType.value === "buy") {
			method = "buyTokens";
			amt = parseEther(`${amount.value}`);
			evt = updateBuyLog;
			const info = tokenAmount(
				ethReserve.value,
				tokenReserve.value,
				`${amount.value}`,
				slippagePercent.value,
			);
			args = [info.minimumOutputAmountWei];
		}
		if (tradeType.value === "sell") {
			method = "sellTokens";
			const qty = parseEther(`${tokens.value}`);
			amt = 0;
			evt = updateSellLog;
			const info = ethAmount(
				ethReserve.value,
				tokenReserve.value,
				`${tokens.value}`,
				slippagePercent.value,
			);
			args = [qty, info.minimumOutputAmountWei];
		}
	}
	if (info.currentPhase === 2) {
		// liquidity added
		return;
	}
	await state.call(method, args, amt, saveTx);
	if (state.error) return;
	evt();
	info.updateInfo();
};

const withdrawPrebond = async () => {
	await state.call("withdrawTokenAllocation", [address.value], 0, null);
	info.updateInfo();
};
const finalizeForm = useForm({
	pool: null,
});
const finalizeCurve = async () => {
	await state.call("finalizeCurve", []);
	await info.updateInfo();
	finalizeForm.pool = info.uniswapPool;
	finalizeForm.put(
		window.route("launchpads.finalize", {
			launchpad: props.launchpad.id,
		}),
		{ preserveScroll: true, preserveState: true },
	);
};

const maxPrebond = computed(() => {
	const max = info.preBondingTarget - info.totalPreBondingContributions;
	if (amount.value > max) return max;
	return null;
});

const visibleTabs = computed(() =>
	info.currentPhase === 0 ? tabs.filter(tab => tab.name === 'buy') : tabs
);
</script>

<template>
	<div class="w-full grid gap-4">
		<div v-if="info.currentPhase < 2" class="rounded-lg border border-none text-gray-400 grid gap-4">
			<div class="flex flex-col items-center justify-between gap-2 mb-2">
				<h3 class="text-xl font-extralight" v-if="info.currentPhase == 0">
					{{ $t("Prebond") }}
				</h3>
				<div class="flex bg-white/10 rounded-full p-1 gap-1 w-full">
					<button v-for="tab in visibleTabs" :key="tab.name" @click="activeTab = tab.name; setType(tab.name)"
						:class="[
							'px-7 py-2 text-base font-normal focus:outline-none transition-all rounded-full capitalize w-full',
							activeTab === tab.name
								? 'bg-gradient-to-r from-orange-500 to-orange-600 text-white shadow rounded-full'
								: 'bg-transparent text-gray-400 rounded-full hover:text-white'
						]">
						{{ tab.name }}
					</button>
				</div>
			</div>

			<div v-show="!slippage" class="flex flex-col">
				<FormInput v-if="useTokenInput" size="sm" v-model="tokens" input-classes="!pl-24 rounded-lg">
					<template #lead>
						<div v-if="useTokenInput" class="flex items-center gap-2 ml-2">
							<img class="w-4 h-4 rounded-full" :src="launchpad.logo" loading="lazy" />
							{{ launchpad.symbol }}
						</div>
						<div v-else class="flex items-center gap-2 ml-2">
							<NetworkIcon :chainId="launchpad.chainId" class="w-4 h-4 rounded-full" />

							<ChainSymbol :chainId="launchpad.chainId" />
						</div>
					</template>
					<template #trail>
						<div class="flex items-center gap-2 ml-2">
							<BaseButton @click="useTokenInput = !useTokenInput" size="xss" iconMode secondary>
								<ArrowLeftRight class="w-4 h-4" />
							</BaseButton>
							<BaseButton @click="slippage = true" size="xss" iconMode secondary>
								<Cog class="w-4 h-4" />
							</BaseButton>
						</div>
					</template>
				</FormInput>
				<FormInput v-else size="sm" v-model="amount" :error="maxPrebond ? `Max is ${maxPrebond}` : ''"
					input-classes="!pl-24 rounded-lg">
					<template #lead>
						<div v-if="useTokenInput" class="flex items-center gap-2 ml-2">
							<img class="w-4 h-4 rounded-full" :src="launchpad.logo" loading="lazy" />
							{{ launchpad.symbol }}
						</div>
						<div v-else class="flex items-center gap-2 ml-2">
							<NetworkIcon :chainId="launchpad.chainId" class="w-4 h-4 rounded-full" />

							<ChainSymbol :chainId="launchpad.chainId" />
						</div>
					</template>
					<template #trail>
						<div class="flex items-center gap-2 ml-2">
							<BaseButton v-if="maxPrebond" @click="amount = maxPrebond" size="xss" secondary>
								MAX
							</BaseButton>
							<BaseButton v-else @click="useTokenInput = !useTokenInput" size="xss" iconMode secondary>
								<ArrowLeftRight class="w-4 h-4" />
							</BaseButton>
							<BaseButton @click="slippage = true" size="xss" iconMode secondary>
								<Cog class="w-4 h-4" />
							</BaseButton>
						</div>
					</template>
				</FormInput>
				<div v-if="useTokenInput && tradeType === 'sell'" class="flex items-center gap-1 mt-2 p-1 rounded-lg">
					<BaseButton
						class="text-base font-normal focus:outline-none transition-all text-gray-400 rounded-lg hover:text-white bg-white/10"
						@click="tokens = 0" size="xss" icon-mode secondary>
						<X class="w-4 h-4 hover:rotate-90 hover:text-red-500 transition-all duration-300" />
					</BaseButton>
					<BaseButton
						class="text-base font-normal focus:outline-none transition-all text-gray-400 rounded-lg hover:text-white bg-white/10"
						@click="tokens = info.balance" size="xss" secondary>
						BAL
					</BaseButton>
					<BaseButton
						class="text-base font-normal focus:outline-none transition-all text-gray-400 rounded-lg hover:text-white bg-white/10"
						@click="tokens = info.balance * 0.1" size="xss" secondary>
						10%
					</BaseButton>
					<BaseButton
						class="text-base font-normal focus:outline-none transition-all text-gray-400 rounded-lg hover:text-white bg-white/10"
						@click="tokens = info.balance * 0.25" size="xss" secondary>
						25%
					</BaseButton>
					<BaseButton
						class="text-base font-normal focus:outline-none transition-all text-gray-400 rounded-lg hover:text-white bg-white/10"
						@click="tokens = info.balance * 0.5" size="xss" secondary>
						50%
					</BaseButton>
					<BaseButton
						class="text-base font-normal focus:outline-none transition-all text-gray-400 rounded-lg hover:text-white bg-white/10"
						@click="tokens = info.balance * 0.75" size="xss" secondary>
						75%
					</BaseButton>
				</div>
				<div v-else class="flex items-center gap-1 mt-2 p-1 rounded-lg">
					<BaseButton
						class="text-base font-normal focus:outline-none transition-all text-gray-400 rounded-lg hover:text-white bg-white/10"
						@click="amount = 0" size="xss" secondary>
						{{ $t("RESET") }}
					</BaseButton>
					<BaseButton
						class="text-base font-normal focus:outline-none transition-all text-gray-400 rounded-lg hover:text-white bg-white/10"
						@click="amount = 0.1" size="xss" secondary>
						0.1
						<ChainSymbol class="ml-1" :chainId="launchpad.chainId" />
					</BaseButton>
					<BaseButton
						class="text-base font-normal focus:outline-none transition-all text-gray-400 rounded-lg hover:text-white bg-white/10"
						@click="amount = 0.5" size="xss" secondary>
						0.5
						<ChainSymbol class="ml-1" :chainId="launchpad.chainId" />
					</BaseButton>
					<BaseButton
						class="text-base font-normal focus:outline-none transition-all text-gray-400 rounded-lg hover:text-white bg-white/10"
						@click="amount = 1" size="xss" secondary>
						1
						<ChainSymbol class="ml-1" :chainId="launchpad.chainId" />
					</BaseButton>
					<BaseButton
						class="text-base font-normal focus:outline-none transition-all text-gray-400 rounded-lg hover:text-white bg-white/10"
						@click="amount = 3" size="xss" secondary>
						3
						<ChainSymbol class="ml-1" :chainId="launchpad.chainId" />
					</BaseButton>
				</div>
			</div>

			<div v-show="slippage" class="flex flex-col">
				<FormInput v-model="slippagePercent" size="sm" input-classes="!pl-24">
					<template #lead>
						<span class="text-xs text-primary font-semibold ml-0.5">
							{{ $t("SLIPPAGE") }} %
						</span>
					</template>
					<template #trail>
						<div class="flex items-center gap-2 ml-2">
							<BaseButton @click="slippage = false" size="xss" iconMode primary>
								<Cog class="w-4 h-4" />
							</BaseButton>
						</div>
					</template>
				</FormInput>
				<div class="flex items-center gap-1 mt-2 bg-gray-800 p-1 rounded-lg">
					<BaseButton @click="slippagePercent = 5" size="xss" outlined secondary>
						5%
					</BaseButton>
					<BaseButton @click="slippagePercent = 10" size="xss" outlined secondary>
						10%
					</BaseButton>
					<BaseButton @click="slippagePercent = 15" size="xss" outlined secondary>
						15%
					</BaseButton>
					<BaseButton @click="slippagePercent = 20" size="xss" outlined secondary>
						20%
					</BaseButton>
					<BaseButton @click="slippagePercent = 25" size="xss" outlined secondary>
						25%
					</BaseButton>
					<BaseButton @click="slippagePercent = 30" size="xss" outlined secondary>
						30%
					</BaseButton>
				</div>
			</div>

			<div class="flex flex-col gap-2">
				<TxStatus v-if="
					[
						'sellTokens',
						'buyTokens',
						'contributePreBonding',
					].includes(state.called)
				" class="mb-2" :state="state" />
				<ApproveTokenButton class="flex-col" :contract="launchpad.token" :spender="launchpad.contract"
					:amount="parseEther(`${tokens}`)" shouldApprove v-if="tradeType == 'sell'">
					<BaseButton
						class="bg-gradient-to-r from-orange-500 to-orange-600 text-white shadow rounded-full px-7 py-2 text-base font-normal focus:outline-none transition-all"
						@click="swap" danger>
						{{ $t("Place trade") }}
					</BaseButton>
				</ApproveTokenButton>
				<BaseButton
					class="bg-gradient-to-r from-orange-500 to-orange-600 text-white shadow rounded-full px-7 py-2 text-base font-normal focus:outline-none transition-all"
					@click="swap" v-else>
					{{ $t("Place trade") }}
				</BaseButton>
			</div>

			<div class="text-xs">
				<div v-if="useTokenInput">
					<span v-if="tradeType === 'sell'">
						{{ $t("You receive min.") }}
					</span>
					<span v-else>{{ $t("You spend min.") }}</span>
					<b>{{ parseFloat(amount).toFixed(8) }}</b>
					<ChainSymbol class="ml-1" :chainId="launchpad.chainId" />
					(- {{ swapInfo.priceImpact }} impact)
				</div>
				<div v-else>
					<span v-if="tradeType === 'buy'">
						{{ $t("You receive min.") }}
					</span>
					<span v-else>{{ $t("You spend min.") }}</span>
					<b>{{ parseFloat(tokens).toFixed() }}</b>
					{{ launchpad.symbol }}
					(- {{ swapInfo.priceImpact }} impact)
				</div>
			</div>
		</div>
		<div v-if="info.contributions > 0 && info.tokenLocks"
			class="bg-white/10 p-4 text-center rounded-lg border border-none text-gray-400 grid gap-4">
			<h3 class="text-lg font-medium flex justify-center items-center">
				<Vault class="w-5 h-5 mr-2 inline-flex" />
				{{ $t("Prebond Purchase") }}
			</h3>
			<h3 class="font-extralight !text-primary">
				{{ parseFloat(info.tokenAllocations).toFixed() }}
				{{ launchpad.symbol }}
			</h3>
			<TxStatus v-if="state.called === 'withdrawTokenAllocation'" :state="state" />
			<BaseButton
				class="border border-white/10 bg-white/10 text-white shadow rounded-full px-7 py-2 text-base font-normal hover:bg-white/20 hover:text-white"
				@click="withdrawPrebond">
				{{ $t("Withdraw Prebond Allocation") }}
			</BaseButton>
		</div>
		<div v-if="info.currentPhase === 2 && !info.isFinalized"
			class="p-4 text-center rounded-lg border border-gray-800 text-gray-400 grid gap-4">
			<TxStatus v-if="state.called === 'finalizeCurve'" :state="state" />
			<BaseButton primary outlined @click="finalizeCurve">
				{{ $t("Finalize Launchpad") }}
			</BaseButton>
		</div>
		<div v-if="info.isFinalized"
			class="p-4 text-center bg-emerald-800/10 rounded-lg border border-emerald-800 text-gray-400 grid gap-4">
			<h3 class="font-extralight !text-emerald-500 flex justify-center items-center">
				<CheckCircle class="w-7 h-7 mr-2 inline-flex" />
				{{ $t("Launchpad Finalized") }}
			</h3>
			<a class="text-emerald-100 hover:text-emerald-200" ref="nofollow" target="_blank"
				:href="`https://app.uniswap.org/swap?inputCurrency=${launchpad.token}`">
				{{ $t("Swap on Uniswap") }}
			</a>
		</div>
	</div>
</template>
