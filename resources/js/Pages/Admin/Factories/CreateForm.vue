<script setup>
import { computed, nextTick, ref, watch } from "vue";

import { useForm } from "@inertiajs/vue3";
import { useAccount, useChainId } from "@wagmi/vue";
import { parseEther, parseEventLogs } from "viem";

import ChainInfo from "@/Components/ChainInfo.vue";
import FormInput from "@/Components/FormInput.vue";
import FormSwitch from "@/Components/FormSwitch.vue";
import Loading from "@/Components/Loading.vue";
import PrimaryButton from "@/Components/PrimaryButton.vue";
import TxStatus from "@/Components/TxStatus.vue";
import { isAddress } from "@/hooks/explorers";
import {
    useContractFees,
    useReactiveContractCall,
} from "@/hooks/useContractCall";

const props = defineProps({
    foundry: { required: true, type: Object },
    config: { required: true, type: Object },
});
const chainId = useChainId();
const { address, chain } = useAccount();
const form = useForm({
    name: "My Factory",
    chainId: chainId.value,
    foundry: "",
    contract: "",
    lock: "",
    fees: 0.1,
    // for error tracking, valuese will not be uses
    // see form below
    virtualEth: 0,
    preBondingTarget: 0,
    bondingTarget: 0,
    minContribution: 0,
    poolFee: 0,
    sellFee: 0,
    uniswapV3Factory: 0,
    positionManager: 0,
    weth: 0,
    feeTo: 0,
    ...(props.config[chainId.value] ?? {}),
    ...{ feeTo: address.value },
});

watch(chainId, (chainId) => {
    // update defualts
    form.chainId = chainId;
    if (props.config[chainId]) {
        const config = props.config[chainId];
        form.virtualEth = config.virtualEth;
        form.preBondingTarget = config.preBondingTarget;
        form.bondingTarget = config.bondingTarget;
        form.minContribution = config.minContribution;
        form.poolFee = config.poolFee;
        form.sellFee = config.sellFee;
        form.uniswapV3Factory = config.uniswapV3Factory;
        form.positionManager = config.positionManager;
        form.weth = config.weth;
    }
});
watch(address, (address) => {
    form.feeTo = address;
});
const save = () => form.post(window.route("admin.factories.store"));
const supportedChains = computed(() =>
    Object.keys(props.foundry.addresses),
);

const foundryAddress = computed(
    () => props.foundry.addresses[chainId.value],
);
const state = useReactiveContractCall(props.foundry.abi, foundryAddress);
const uniswapV3 = ref(false);
const { fees, feesFormatted, loadFees } = useContractFees(
    props.foundry.abi,
    foundryAddress,
    "getDeploymentFee",
);
nextTick(loadFees);
const deployContract = async () => {
    form.clearErrors();
    const settings = {
        virtualEth: parseEther(`${form.virtualEth}`),
        preBondingTarget: 0,
        bondingTarget: parseEther(`${form.bondingTarget}`),
        minContribution: parseEther(`${form.minContribution}`),
        poolFee: `${form.poolFee}`,
        sellFee: `${form.sellFee}`,
        uniswapV3Factory: isAddress(form.uniswapV3Factory),
        positionManager: isAddress(form.positionManager),
        weth: isAddress(form.weth),
        feeTo: isAddress(form.feeTo),
    };
    if (!form.name) form.setError("name", "Please create a name");
    if (!form.fees) form.setError("fees", "Cannot be empty or 0");
    if (!settings.virtualEth)
        form.setError("virtualEth", "Cannot be empty or 0");
    if (!settings.bondingTarget)
        form.setError("bondingTarget", "Cannot be empty or 0");
    if (!settings.minContribution)
        form.setError("minContribution", "Cannot be empty or 0");
    if (!settings.poolFee) form.setError("poolFee", "Cannot be empty or 0");
    if (!settings.feeTo) form.setError("feeTo", "Invalid address");
    if (!settings.uniswapV3Factory)
        form.setError("uniswapV3Factory", "Invalid address");
    if (!settings.positionManager)
        form.setError("positionManager", "Invalid address");
    if (!settings.weth) form.setError("weth", "Invalid address");
    if (form.hasErrors) {
        state.error =
            "It seems you missed you stuff we need. check the form!";
        return;
    }
    await state.call(
        "deploySystem",
        [address.value, parseEther("0.1"), settings],
        fees.value,
    );
    if (state.error) return;
    const logs = parseEventLogs({
        abi: props.foundry.abi,
        logs: state.receipt.logs,
        eventName: ["SystemDeployed"],
    });
    form.foundry = foundryAddress.value;
    form.contract = logs?.[0]?.args?.factoryAddress;
    form.lock = logs?.[0]?.args?.lockAddress;
    form.chainId = chainId.value;
    save();
};
</script>
<template>

    <div class="card sm:p-12 h-full border-0 card-border">
        <div class="card-body card-gutterless h-full">
            <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
                <appkit-network-button />
                <FormInput
                    label="Factory Name. (A simple label for your private use)"
                    v-model="form.name"
                    class="sm:col-span-2"
                    type="text"
                    help="This name is meant for local use"
                    :error="form.errors.name"
                />

                <div
                    class="sm:col-span-2 lg:col-span-4 grid md:grid-cols-2 lg:grid-cols-4 gap-3 p-6 border border-gray-750">
                    <FormInput
                        label="Deployment Fees"
                        v-model="form.fees"
                        help="Price of launching on your platform"
                        type="text"
                        :error="form.errors.fees"
                    >
                        <template #trail>
                            {{ chain?.nativeCurrency?.symbol }}
                        </template>
                    </FormInput>
                    <FormInput
                        label="Virtual Liquidity"
                        v-model="form.virtualEth"
                        :error="form.errors.virtualEth"
                        type="text"
                    >
                        <template #trail>
                            {{ chain?.nativeCurrency?.symbol }}
                        </template>
                    </FormInput>

                    <FormInput
                        label="Bonding Target"
                        v-model="form.bondingTarget"
                        :error="form.errors.bondingTarget"
                        type="text"
                    >
                        <template #trail>
                            {{ chain?.nativeCurrency?.symbol }}
                        </template>
                    </FormInput>
                    <FormInput
                        label="Min Contribution"
                        v-model="form.minContribution"
                        :error="form.errors.minContribution"
                        type="text"
                    >
                        <template #trail>
                            {{ chain?.nativeCurrency?.symbol }}
                        </template>
                    </FormInput>
                    <FormInput
                        label="Uniswap Pool Percentage Fees Tier (*10000)"
                        help="Liquidity will be added to uniswap under this fee tier"
                        class="md:col-span-2"
                        v-model="form.poolFee"
                        :error="form.errors.poolFee"
                        type="text"
                    >
                        <template #trail>
                            {{
                                (form.poolFee / 10000).toFixed(
                                    4,
                                ) * 1
                            }}%
                        </template>
                    </FormInput>
                    <FormInput
                        label="Sell Token Fees (Percent x 100)"
                        help="A fee charged when users sell tokens on the bonding curve"
                        class="md:col-span-2"
                        v-model="form.sellFee"
                        :error="form.errors.sellFee"
                        type="text"
                    >
                        <template #trail>
                            {{
                                (form.sellFee / 100).toFixed(
                                    4,
                                ) * 1
                            }}%
                        </template>
                    </FormInput>

                    <div class="sm:col-span-2 lg:col-span-4">
                        <h3 class="!text-red-500">
                            Important !
                        </h3>
                        <p class="mb-3">
                            Donot Edit edit the UniswapV3
                            addresses unless you know what you
                            are doing. Wrong addresses could
                            lead to contributions getting stuck
                            for good on the launchpad pool.
                        </p>
                        <FormSwitch v-model="uniswapV3">
                            I want to change the UniswapV3
                            addresses
                        </FormSwitch>
                    </div>
                    <FormInput
                        label="UniswapV3 Factory"
                        class="md:col-span-2"
                        :disabled="!uniswapV3"
                        v-model="form.uniswapV3Factory"
                        :error="form.errors.uniswapV3Factory"
                        type="text"
                    />
                    <FormInput
                        label="UniswapV3 Nonfungible Position Manager"
                        class="md:col-span-2"
                        :disabled="!uniswapV3"
                        v-model="form.positionManager"
                        :error="form.errors.positionManager"
                        type="text"
                    />
                    <FormInput
                        label="UniswapV3 WETH"
                        class="md:col-span-2"
                        :disabled="!uniswapV3"
                        v-model="form.weth"
                        :error="form.errors.weth"
                        type="text"
                    />
                    <FormInput
                        label="Pool Fees sent to"
                        class="md:col-span-2"
                        v-model="form.feeTo"
                        :error="form.errors.feeTo"
                        type="text"
                    />
                </div>

                <div
                    v-if="!foundryAddress"
                    class="pt-5 sm:col-span-2 grid gap-3 lg:col-span-4"
                >
                    <h3>{{ chain.name }} is not supported</h3>
                    <p>Allowed chains are</p>
                    <div class="flex items-center gap-3">
                        <ChainInfo
                            v-for="chId in supportedChains"
                            :chain-id="chId"
                            :key="chId"
                        />
                    </div>
                    <h3 class="text-sm">Switch Chain</h3>
                    <appkit-network-button />
                </div>
                <div
                    v-else
                    class="pt-5 sm:col-span-2 lg:col-span-4"
                >
                    <TxStatus
                        class="my-5"
                        :state="state"
                    />
                    <div class="flex items-center gap-3">
                        <PrimaryButton
                            secondary
                            as="button"
                            :href="route('admin.factories.index')
                                "
                            type="button"
                            link
                        >
                            {{ $t("Cancel") }}
                        </PrimaryButton>
                        <PrimaryButton
                            type="button"
                            @click.prevent="deployContract"
                            :disabled="form.processing"
                        >
                            <Loading
                                class="mr-2 -ml-1 inline-block w-5 h-5"
                                v-if="form.processing"
                            />
                            {{ $t("Deploy Factory") }}
                            {{ feesFormatted }}
                            {{ chain?.nativeCurrency?.symbol }}
                        </PrimaryButton>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
