<script setup>
	import { computed, ref, watch } from "vue";

	import { Link, router, useForm, usePage } from "@inertiajs/vue3";
	import { useInterval } from "@vueuse/core";
	import { Mail, UserIcon } from "lucide-vue-next";

	import ApplicationLogo from "@/Components/ApplicationLogo.vue";
	import CollapseTransition from "@/Components/CollapseTransition.vue";
	import FormInput from "@/Components/FormInput.vue";
	import Loading from "@/Components/Loading.vue";
	import PrimaryButton from "@/Components/PrimaryButton.vue";
	import {
		Dialog,
		DialogContent,
		DialogHeader,
	} from "@/Components/ui/dialog";
	import OtpInput from "@/Pages/Auth/OtpInput.vue";
	const { counter, reset, pause, resume, isActive } = useInterval(1000, {
		controls: true,
	});
	pause();
	watch(counter, (counter) => {
		if (counter === 60) {
			pause();
			reset();
		}
	});

	defineProps({
		show: Boolean,
	});

	const emit = defineEmits(["update:show"]);

	const needsOtp = computed(
		() =>
			!!usePage().props.auth.user?.email &&
			!usePage().props.auth.user?.email_verified_at,
	);
	const error = ref("");
	const loading = ref(false);
	const resendForm = useForm({});
	const requestForm = useForm({
		email: null,
		name: null,
		to: window.location.pathname,
	});
	const resend = async () => {
		resendForm.post(window.route("otp.resend"), {
			preserveScroll: true,
			preserveState: true,
			onFinish() {
				reset();
				resume();
			},
		});
	};
	const submitEmail = async () => {
		requestForm.post(window.route("otp.send"), {
			preserveScroll: true,
			preserveState: true,
			onFinish() {
				reset();
				resume();
			},
		});
	};
	const authForm = useForm({ otp: "" });
	const submitOTP = async () => {
		authForm.post(window.route("modal.verify"), {
			preserveState: true,
			preserveScroll: true,
			onSuccess() {
				emit("update:show", false);
				router.reload();
			},
		});
	};
</script>

<template>
	<Dialog :open="show" @update:open="(val) => $emit('update:show', val)">
		<DialogContent class="sm:max-w-[425px]">
			<DialogHeader>
				<Link class="flex mb-4 items-center" href="/">
					<ApplicationLogo class="block h-8 w-auto font-semibold" />
				</Link>
				<h3 class="text-2xl">Connect email address</h3>

				<p v-if="needsOtp">
					A code was sent to your email, Enter it below
				</p>
			</DialogHeader>
			<form @submit.prevent="needsOtp ? submitOTP() : submitEmail()">
				<div v-if="error" class="text-red-500 mb-4">{{ error }}</div>
				<div v-if="needsOtp">
					<OtpInput v-model="authForm.otp" :length="6" />
					<p
						class="!text-red-500 text-sm mt-2"
						v-if="authForm.errors.otp">
						{{ authForm.errors.otp }}
					</p>
				</div>
				<div v-else>
					<FormInput
						class="mt-1 block w-full"
						placeholder="Your Full Name"
						v-model="requestForm.name"
						:error="requestForm.errors.name"
						required
						type="text"
						size="md"
						autocomplete="name">
						<template #lead>
							<UserIcon class="w-4 h-4 ml-1 text-white" />
						</template>
					</FormInput>
					<FormInput
						class="mt-1 block w-full"
						placeholder="Email"
						:label="needsOtp ? 'Verify OTP' : 'Enter Email Address'"
						v-model="requestForm.email"
						:error="requestForm.errors.email"
						required
						autofocus
						type="email"
						size="md"
						autocomplete="username">
						<template #lead>
							<Mail class="w-4 h-4 ml-1 text-white" />
						</template>
					</FormInput>
				</div>
				<CollapseTransition>
					<div
						class="text-emerald-400 font-semibold text-sm py-3"
						v-if="resendForm.recentlySuccessful">
						{{ $t("Code resent successfully !") }}
					</div>
				</CollapseTransition>
				<div class="flex gap-3 justify-end mt-6">
					<PrimaryButton
						size="sm"
						outlined
						@click="resend"
						type="button"
						:disabled="resendForm.processing || isActive"
						v-if="needsOtp">
						<Loading
							v-if="resendForm.processing"
							class="!w-5 !h-5 mr-2 -ml-1" />
						{{ $t("Resend") }}
						{{ isActive ? `in ${60 - counter}s` : "" }}
					</PrimaryButton>
					<PrimaryButton
						type="submit"
						class="w-full"
						size="lg"
						:disabled="loading">
						{{ needsOtp ? $t("Verify") : $t("Continue") }}
					</PrimaryButton>
				</div>
			</form>
		</DialogContent>
	</Dialog>
</template>
