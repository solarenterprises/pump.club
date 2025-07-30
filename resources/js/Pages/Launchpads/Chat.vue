<!-- LaunchpadChat.vue -->
<script setup>
import { nextTick, onMounted, ref, watch } from "vue";

import { PaperAirplaneIcon } from "@heroicons/vue/24/outline";
import { useForm } from "@inertiajs/vue3";
import { MessageSquareHeart } from "lucide-vue-next";

import BaseButton from "@/Components/BaseButton.vue";
import FormInput from "@/Components/FormInput.vue";
import Web3Auth from "@/Pages/Auth/Web3Auth.vue";

const props = defineProps({
	launchpadId: {
		type: Number,
		required: true,
	},
	devId: {
		type: Number,
		required: true,
	},
	initialMessages: {
		type: Array,
		default: () => [],
	},
});

const messages = ref([...props.initialMessages]);
const imagePreview = ref(null);
const uploadPath = ref(null);

const form = useForm({
	message: "",
	image_path: null,
	image_upload: false,
	launchpad_id: props.launchpadId,
});



// Websocket connection
onMounted(() => {
	const channel = window.Echo.channel(`launchpad.${props.launchpadId}`);
	channel.listen('NewMessage', (e) => {
		console.log('Received new message:', e);
		if (e.message) {
			messages.value = [...messages.value, e.message];
			scrollToBottom();
		} else {
			console.warn('Received event without message data:', e);
		}
	});
});

const submitMessage = () => {
	if (!form.message && !form.image_path) return;

	form.post(window.route("msgs.store"), {
		preserveScroll: true,
		onSuccess: (...args) => {
			form.reset();
			imagePreview.value = null;
			uploadPath.value = null;
		},
	});
};
const scrollToBottom = () => {
	console.log("aaaa");
	const container = document.querySelector('.messages-container');
	if (container) {
		container.scrollTop = container.scrollHeight;
	} else {
		console.error('Messages container not found');
	}
};
onMounted(() => {
	nextTick(() => {
		scrollToBottom();
	});
});
watch(
	messages,
	() => {
		nextTick(() => {
			scrollToBottom();
		});
	},
	{ deep: true },
);
watch(
	() => props.initialMessages,  // Watch prop change
	(newMessages) => {
		if (Array.isArray(newMessages)) {
			messages.value = [...newMessages];
		} else {
			console.error('Invalid initialMessages prop:', newMessages);
		}
	}
);

</script>

<template>
	<div class="flex flex-col h-[800px] bg-white/10 p-4 rounded-lg shadow">
		<!-- Messages Container -->
		<div v-if="messages.length == 0" class="w-full flex flex-col items-center justify-center h-full">
			<div class="p-8 bg-gray-800 rounded">
				<MessageSquareHeart class="w-16 h-16 stroke-[0.8]" />
				<h3 class="text-xl font-extralight">No chat messages found</h3>
				<h3>Be the first to Leave a message</h3>
			</div>
		</div>
		<div v-if="messages.length != 0" class="overflow-y-auto pb-4 messages-container h-[750px]">
			<div v-for="message in messages" :key="message.uuid" class="mb-4" :class="{
				'flex justify-end':
					message.user_id === $page.props.auth.user?.id,
			}">
				<div :class="{
					'bg-blue-100 dark:bg-blue-900':
						message.user_id === $page.props.auth.user?.id,
					'bg-white/10':
						message.user_id !== $page.props.auth.user?.id,
				}" class="rounded-lg p-3">
					<div class="flex items-start">
						<img :src="message.user.profile_photo_url" :alt="message.user.name"
							class="w-8 h-8 rounded-full mr-2" />
						<div>
							<div class="text-sm font-semibold mb-1">
								{{
									message.user.name ||
									message.user.address.substring(0, 6)
								}}
								<BaseButton v-if="message.user_id === devId"
									class="self-center ml-3 pointer-events-none" size="xss" outlined>
									DEV
								</BaseButton>
							</div>
							<p class="text-sm">{{ message.message }}</p>
							<img v-if="message.image" :src="message.image" class="mt-2 rounded-lg max-w-full h-auto"
								@click="$emit('image-click', message.image)" />
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- Input Area -->
		<div class="pt-4">
			<form @submit.prevent="submitMessage" class="space-y-4">
				<!-- Image Preview -->
				<div class="flex items-center space-x-4">
					<div class="flex-1">
						<FormInput v-model="form.message" type="text" size="md" placeholder="Type your message...">
						</FormInput>
					</div>
					<button v-if="$page.props.auth.user"
						class="bg-gradient-to-r from-orange-500 to-orange-600 text-white shadow rounded-full px-3 py-3 text-base font-normal focus:outline-none transition-all">
						<PaperAirplaneIcon class="w-6 h-6 text-white" />
					</button>
					<Web3Auth size="md" v-else />
				</div>
			</form>
		</div>
	</div>
</template>
