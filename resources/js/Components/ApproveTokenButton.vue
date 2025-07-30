<script setup>
	import { computed, ref, watch } from "vue";

	import { getPublicClient } from "@wagmi/core";
	import { useAccount, useConfig } from "@wagmi/vue";
	import { erc20Abi, isAddress, zeroAddress } from "viem";

	import BaseButton from "@/Components/BaseButton.vue";
	import CollapseTransition from "@/Components/CollapseTransition.vue";
	import Loading from "@/Components/Loading.vue";
	import TxStatus from "@/Components/TxStatus.vue";
	import { useReactiveContractCall } from "@/hooks/useContractCall";
	const props = defineProps({
		contract: { type: String, required: true },
		spender: { type: String, required: true },
		amount: { type: BigInt, default: 0n },
		shouldApprove: { type: Boolean, default: true },
	});
	const emit = defineEmits(["approve"]);
	const { address } = useAccount();
	const publicClient = getPublicClient(useConfig());
	const allowance = ref(0);
	const loading = ref(false);
	const approved = (reciept) => emit("approve", reciept);
	const update = async () => {
		loading.value = true;
		allowance.value = await publicClient.readContract({
			address: props.contract,
			abi: erc20Abi,
			functionName: "allowance",
			args: [address.value, props.spender],
		});
		loading.value = false;
	};
	const contractAddress = computed(() => props.contract);
	const state = useReactiveContractCall(erc20Abi, contractAddress);
	state.status = "Approve tokens to deposit";
	const approve = async () => {
		await state.call("approve", [props.spender, props.amount]);
		await update();
		approved(state.receipt);
	};

	const requiresApproval = computed(
		() =>
			props.contract !== zeroAddress &&
			props.shouldApprove &&
			allowance.value < props.amount,
	);
	watch(
		[() => props.shouldApprove, () => props.contract, () => props.spender],
		([shouldApprove, contract, spender, amount]) => {
			if (
				!shouldApprove ||
				!isAddress(contract) ||
				!isAddress(spender) ||
				contract === zeroAddress
			)
				return;

			update();
		},
		{ immediate: true },
	);
</script>
<template>
	<CollapseTransition>
		<div
			class="relative mt-6 flex gap-3"
			v-bind="$attrs"
			v-show="requiresApproval">
			<slot name="approval" :state="state" :approve="approve">
				<TxStatus v-if="state.called === 'approve'" :state="state" />
				<BaseButton
					class="bg-gradient-to-r from-orange-500 to-orange-600 text-white shadow rounded-full px-7 py-2 text-base font-normal focus:outline-none transition-all hover:text-white"
					:disabled="state.busy || state.confirming"
					outlined
					@click.prevent="approve">
					<slot name="button">
						<Loading
							v-if="state.busy || state.confirming"
							class="-ml-1 !mr-2 inline-flex" />
						{{ $t("Approve Tokens") }}
					</slot>
				</BaseButton>
			</slot>
		</div>
	</CollapseTransition>
	<CollapseTransition>
		<div v-bind="$attrs" v-show="!requiresApproval">
			<slot />
		</div>
	</CollapseTransition>
</template>
