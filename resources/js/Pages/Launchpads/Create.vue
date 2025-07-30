<script setup>
	import { computed, ref, onMounted } from "vue";

	import { useForm } from "@inertiajs/vue3";
	import { useChainId } from "@wagmi/vue";
	import { ChevronDown, CircleAlert, ImageIcon, Link, PenLine, Trash2 } from "lucide-vue-next";
	import { parseEventLogs } from "viem";

	import CollapseTransition from "@/Components/CollapseTransition.vue";
	import FormInput from "@/Components/FormInput.vue";
	import FormLabel from "@/Components/FormLabel.vue";
	import FormTextArea from "@/Components/FormTextArea.vue";
	import Loading from "@/Components/Loading.vue";
	import LogoInputLocal from "@/Components/LogoInputLocal.vue";
	import PrimaryButton from "@/Components/PrimaryButton.vue";
	import { Carousel, CarouselContent, CarouselItem } from "@/Components/ui/carousel";
	import {
		useContractFees,
		useReactiveContractCall,
	} from "@/hooks/useContractCall";
	import AppLayout from "@/Layouts/AppLayout.vue";
	import Web3Auth from "@/Pages/Auth/Web3Auth.vue";
	import BarButton from "@/Pages/Launchpads/BarButton.vue";

	const props = defineProps({
		factories: Array,
		top: Array,
	});
	const chainId = useChainId();
	const factory = computed(() => props.factories[chainId.value]);
	const factoryId = computed(() => factory.value?.id);
	const form = useForm({
		chainId,
		factory_id: factoryId,
		contract: "",
		token: "",
		name: "",
		symbol: "",
		description: "",
		twitter: "",
		discord: "",
		telegram: "",
		website: "",
		logo_uri: null,
		logo_path: null,
		logo_upload: true,
	});
	const save = () =>
		form.post(window.route("launchpads.store"), {
			preserveState: true,
			preserveScroll: true,
		});
	
	const navHeight = ref(90);
	const navRef = ref(null);
	const logoInputLocal = ref(null);
	const logo_base64 = ref(null);
	const addLinks = ref(false);
	const addBanner = ref(false);
	const showMobilePreview = ref(false);
	const abi = computed(() => factory.value.factory_abi);
	const contract = computed(() => factory.value.contract);
	const state = useReactiveContractCall(abi, contract);
	const { fees, feesFormatted } = useContractFees(
		abi,
		contract,
		"getDeploymentFee",
	);

	const deploy = async () => {
		if (form.logo_upload && !form.logo_path) {
		form.setError("logo_uri", "The photo is too large (max 15MB)");
		}
		if (!form.logo_upload && !form.logo_uri) {
			form.setError("logo_uri", "The photo is too large (max 15MB)");
		}
		if (!form.name) form.setError("name", "Error Message");
		if (!form.symbol) form.setError("symbol", "Error Message");
		if (!form.description) form.setError("description", "Error Message");
		await state.call(
			"deployBondingCurveSystem",
			[form.name, form.symbol],
			fees.value,
		);
		if (state.error) return;
		const logs = parseEventLogs({
			abi: abi.value,
			logs: state.receipt.logs,
			eventName: ["BondingCurveSystemDeployed"],
		});
		form.contract = logs?.[0]?.args?.bondingCurveAddress;
		form.token = logs?.[0]?.args?.tokenAddress;
		save();
	};

	function openLogoFileDialog() {
    logoInputLocal.value?.pond?.browse();
	}

	function removeImage() {
    form.logo_uri = null;
    form.logo_path = null;
    logoInputLocal.value?.clear();
	}


	onMounted(() => {
	if (navRef.value) {
		navHeight.value = navRef.value.offsetHeight;
	}
	});

</script>
<template>
	<Head :title="`New Launchpad`" />
	<AppLayout compact>
		<template #header>
            <div class="hidden md:flex items-center w-full bg-black relative bg-black/10" :style="{ paddingTop: `calc(10px + ${navHeight}px)` }">
                <div class="flex w-full items-center">
                    <div class="flex w-full items-center">
                    <Carousel class="w-full" :opts="{ align: 'start' }">
                        <CarouselContent>
							<CarouselItem
								v-for="(launch, i) in top"
								:key="launch.id"
								class="!basis-auto"
							>
								<BarButton :launch="launch" :active="i === 0" />
							</CarouselItem>
                        </CarouselContent>
                    </Carousel>
                    </div>
                </div>
                </div>
        </template>
		<div class="flex flex-col md:flex-row gap-6 mx-2 md:mx-5 lg:mx-24 xl:mx-36 md:my-10 my-0 pt-24 md:pt-4">
			<div class="lg:w-9/12 w-full md:w-7/12 mb-6 mx-auto md:bg-black/50 bg-transparent md:p-10 p-5 h-full rounded-3xl">
				<h3 class="mb-3 flex items-center gap-2 text-white font-normal text-3xl">
					{{ $t("Create new coin") }}
				</h3>
				<p class="text-white/50 text-sm md:max-w-[220px] max-w-full mb-6">
					{{ $t("Choose carefully, these can't be changed once the coin is created") }}
				</p>
				<div class="grid gap-6">
					<div class="flex flex-col md:flex-row gap-6">
						<FormInput
						:label="$t('Coin Name')"
						v-model="form.name"
						type="text"
						:error="form.errors.name"
						class="md:w-1/2 w-full"
						placeholder="Name your coin" />

						<FormInput
						:label="$t('Ticker')"
						v-model="form.symbol"
						type="text"
						:error="form.errors.symbol"
						class="md:w-1/2 w-full"
						placeholder="Add a coin ticker (e.g. DOGE)" />
					</div>
					<div>
						<FormLabel class="mb-2 flex items-center gap-1">
							<span class="text-white">{{ $t("Description") }}</span>
							<span class="text-white/50">{{ $t("(optional)") }}</span>
						</FormLabel>
						<FormTextArea :rows="3" v-model="form.description" />
						<p
							v-if="form.errors.description"
							class="text-sm font-normal !text-red-500 mt-2">
							{{ form.errors.description }}
						</p>
					</div>
					<button class="flex items-center gap-1 text-white/50 text-sm" @click="addLinks = !addLinks">
						<Link class="w-4 h-4 text-white" />
						<span class="text-white">{{ $t("Add social links") }}</span>
						<span class="text-white/50">{{ $t("(optional)") }}</span>
						<ChevronDown class="w-4 h-4 text-white" :class="{ 'rotate-180': addLinks }" />
					</button>
					<CollapseTransition>
						<div v-show="addLinks" class="grid gap-4">
							<div class="flex flex-col md:flex-row gap-6">
								<FormInput
								:label="$t('Website')"
								v-model="form.website"
								type="text"
								:error="form.errors.website"
								class="md:w-1/2 w-full"
								placeholder="Add URL"
								/>
								<FormInput
								:label="$t('X')"
								v-model="form.twitter"
								type="text"
								:error="form.errors.twitter"
								class="md:w-1/2 w-full"
								placeholder="Add URL"
								/>
							</div>
							<div class="flex flex-col md:flex-row gap-6">
								<FormInput
								:label="$t('Telegram')"
								v-model="form.telegram"
								type="text"
								:error="form.errors.telegram"
								class="md:w-1/2 w-full" 
								placeholder="Add URL"
								/>
								<div class="md:w-1/2 w-full"></div>
							</div>
						</div>
					</CollapseTransition>
						<div
						class="flex flex-col items-center justify-center border border-dashed border-gray-900 bg-black/40 rounded-2xl min-h-[355px] w-full mb-4 relative"
						>
						<LogoInputLocal
							ref="logoInputLocal"
							v-model="form.logo_uri"
							v-model:file="form.logo_path" 
							  @preview="logo_base64 = $event"
							/>
						<template v-if="form.logo_uri">
							<div class="absolute bottom-2 right-2 flex gap-4 items-center">
									<button
										type="button"
										class="text-gray-300 text-sm flex items-center gap-1"
										@click="openLogoFileDialog"
									>
										Replace
										<PenLine class="w-4 h-4" />
									</button>
									<button
										type="button"
										class="text-red-500 hover:text-red-700 text-sm flex items-center gap-1"
										@click="removeImage"
									>
										Remove
										<Trash2 class="w-4 h-4" />
									</button>
								</div>
						</template>
						</div>
						<div class="flex flex-col md:flex-row gap-6 text-white/80 text-sm mb-4">
							<!-- Image requirements -->
							<div>
								<div class="font-medium text-white mb-1">Image</div>
								<ul class="list-disc list-inside space-y-1 text-white/50">
								<li>Max 15mb. "jpg", "gif" or "png" recommended</li>
								<li>Min. 1000×1000px, 1:1 square recommended</li>
								</ul>
							</div>
							<!-- Video requirements -->
							<div>
								<div class="font-medium text-white mb-1">Video</div>
								<ul class="list-disc list-inside space-y-1 text-white/50">
								<li>Max 30mb. "mp4" recommended</li>
								<li>Video - 16:9 or 9:16, 1080p+ recommended</li>
								</ul>
							</div>
						</div>
						<hr class="border-t border-white/10 my-2" />
					<button class="flex items-center gap-1 text-white/50 text-sm" @click="addBanner = !addBanner">
						<ImageIcon class="w-4 h-4 text-white" />
						<span class="text-white">{{ $t("Add banner") }}</span>
						<span class="text-white/50">{{ $t("(optional)") }}</span>
						<ChevronDown class="w-4 h-4 text-white" :class="{ 'rotate-180': addBanner }" />
					</button>
					<CollapseTransition>
						<div v-show="addBanner">
							<div
							class="flex flex-col items-center justify-center border border-dashed border-gray-900 bg-black/40 rounded-2xl min-h-[355px] w-full mb-4 relative"
						>
							
						</div>
						</div>
					</CollapseTransition>
					<hr class="border-t border-white/10 my-2" />
					<span class="text-white/50 text-sm flex items-center gap-1">
						<CircleAlert class="w-3 h-3 text-white" />
						{{ $t("Coin data (social links, banner, etc) can only be added now, and can't be changed or edited after creation") }}
					</span>

					<div v-if="$page.props.auth.user">
						<div class="flex flex-col sm:flex-row items-center gap-3 justify-start w-full">
							<PrimaryButton
								class="w-64 rounded-xl text-white"
								@click="deploy"
								:disabled="state.busy || form.processing">
								<Loading
									class="mr-2 -ml-1 inline-block w-5 h-5"
									v-if="state.busy || form.processing" />
								<span>
									{{ $t("Create") }}
								</span>
							</PrimaryButton>
						</div>
					</div>
					<div v-else class="pt-5">
						<div
							class="flex flex-col sm:flex-row items-center gap-3 justify-end">
							<Web3Auth />
						</div>
					</div>
				</div>
			</div>
				<div class="hidden md:block lg:w-3/12 w-full md:w-5/12 mb-6 mx-auto md:bg-black/50 bg-transparent md:p-10 p-5 h-full rounded-3xl sticky top-0" :style="{ top: `calc(30px + ${navHeight}px)` }">
					<h3 class="mb-3 flex items-center gap-2 text-white font-normal text-xl">
						{{ $t("Preview") }}
					</h3>
					<div class="flex justify-center items-center relative mb-3 w-full h-64">
						<template v-if="form.logo_uri">
							<img
								v-if="logo_base64"
  								:src="logo_base64"
								class="w-full h-full object-cover rounded-2xl mx-auto"
								alt="Preview"
								/>
						</template>
						<template v-else>
							<div class="flex justify-center items-center w-full h-full">
								<div class="flex justify-center items-center w-full h-full bg-black/40 rounded-2xl"></div>
							</div>
						</template>
					</div>
					<div class="text-white text-lg font-semibold leading-tight">
						{{ form.name || '' }}
					</div>
					<div class="text-white/60 text-xs mb-2">
						{{ form.symbol || '' }}
					</div>
					<div class="flex items-center justify-between text-xs text-white/60 mb-2">
						<span>now</span>
						<span>0</span>
					</div>
					<div class="flex items-center gap-2">
						<span class="bg-orange-600 text-white text-xs px-2 py-1 rounded-lg font-bold">$0</span>
						<div class="flex-1 h-1 bg-gray-700 rounded mx-2"></div>
						<span class="text-xs text-white/40">ATH: $0</span>
					</div>
			</div>
		</div>
		<div
			class="fixed bottom-0 left-0 w-full bg-black text-white text-center py-4 z-50 md:hidden cursor-pointer"
			@click="showMobilePreview = true"
		>
			Open preview
		</div>
		<div
			v-if="showMobilePreview"
			class="fixed inset-0 z-50 flex items-end justify-center md:hidden bg-black/60"
			@click.self="showMobilePreview = false"
		>
			<div class="w-full max-w-md bg-[#181818] rounded-t-3xl p-0 pb-8 relative" style="min-height: 60vh;">
				<div class="flex justify-between items-center px-6 pt-6 pb-2">
					<h3 class="mb-3 flex items-center gap-2 text-white font-normal text-xl">
						{{ $t("Preview") }}
					</h3>
					<button @click="showMobilePreview = false" class="text-white text-2xl leading-none">&times;</button>
				</div>
				<div class="flex flex-col items-center justify-center px-6" style="min-height: 40vh;">
				<div class="w-full mb-6 mx-auto bg-black/30 md:p-10 p-0 px-8 py-8 h-full rounded-3xl md:border border-none border-white/10 sticky top-0" :style="{ top: `calc(30px + ${navHeight}px)` }">
					<div class="flex justify-center items-center relative mb-3 w-full h-64">
						<template v-if="form.logo_uri">
							<img
							v-if="logo_base64"
							:src="logo_base64"
							class="w-full h-full object-cover rounded-3xl mx-auto"
							alt="Preview"
							/>
						</template>
						<template v-else>
							<div class="flex justify-center items-center w-full h-full">
								<div class="flex justify-center items-center w-full h-full bg-black/40 rounded-2xl"></div>
							</div>
						</template>
					</div>
					<div class="text-white text-lg font-semibold leading-tight">
						{{ form.name || '' }}
					</div>
					<div class="text-white/60 text-xs mb-2">
						{{ form.symbol || '' }}
					</div>
					<div class="flex items-center justify-between text-xs text-white/60 mb-2">
						<span>now</span>
						<span>0</span>
					</div>
					<div class="flex items-center gap-2">
						<span class="bg-orange-600 text-white text-xs px-2 py-1 rounded-lg font-bold">$0</span>
						<div class="flex-1 h-1 bg-gray-700 rounded mx-2"></div>
						<span class="text-xs text-white/40">ATH: $0</span>
					</div>
					</div>
				</div>
			</div>
		</div>
	</AppLayout>
</template>
