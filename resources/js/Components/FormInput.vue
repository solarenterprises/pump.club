<script setup>
	import { computed, ref, useSlots } from "vue";

	import { ExclamationCircleIcon } from "@heroicons/vue/24/outline";
	import { nanoid } from "nanoid";
	const props = defineProps({
		modelValue: [String, Number],
		placeholder: [String, Number],
		autocomplete: [String, Number],
		id: [String, Number],
		inputClasses: [String, Array],
		hide: Boolean,
		disabled: Boolean,
		readonly: Boolean,
		required: Boolean,
		autofocus: Boolean,
		label: String,
		type: String,
		error: String,
		help: String,
		size: {
			type: String,
			default: "md",
		},
	});
	defineEmits([
		"update:modelValue",
		"changed",
		"focused",
		"unfocused",
		"onKeyUp",
	]);
	const slots = useSlots();
	const lg = computed(() => props.size === "lg");
	const sm = computed(() => props.size === "sm");
	const xs = computed(() => props.size === "xs");
	const xm = computed(() => props.size === "xm");
	const md = computed(() => props.size === "md");
	const xl = computed(() => props.size === "xl");
	const xl2 = computed(() => props.size === "2xl");
	const trail = computed(() => !!slots.trail);
	const lead = computed(() => !!slots.lead);
	const classes = computed(() => {
		if (xs.value)
			return `py-1 text-xs ${lead.value ? "pl-12" : "pl-1"} ${
				trail.value ? "pr-12" : "pr-1"
			}`;
		if (xm.value)
			return `py-1.5 text-sm ${lead.value ? "pl-6" : "pl-1"} ${
				trail.value ? "pr-6" : "pr-1"
			}`;
		if (sm.value)
			return `py-2 text-sm ${lead.value ? "pl-8" : "pl-2"} ${
				trail.value ? "pr-12" : "pr-2"
			}`;
		if (md.value)
			return `py-3 text-base ${lead.value ? "pl-12" : "pl-3"} ${
				trail.value ? "pr-12" : "pr-3"
			}`;
		if (lg.value)
			return `py-4 text-lg ${lead.value ? "pl-12" : "pl-4"} ${
				trail.value ? "pr-12" : "pr-4"
			}`;
		if (xl.value)
			return `py-5 text-xl ${lead.value ? "pl-6" : "pl-5"} ${
				trail.value ? "pr-6" : "pr-5"
			}`;
		if (xl2.value)
			return `py-6 text-2xl ${lead.value ? "pl-12" : "pl-6"} ${
				trail.value ? "pr-12" : "pr-6"
			}`;
		return "p-2";
	});
	const id = computed(() => props.id ?? nanoid());
	const input = ref();
	const focus = () => input.value.focus();
	defineExpose({ focus, input });
</script>
<template>
	<div>
		<label
			:for="id"
			v-if="label || $slots.label"
			:class="xs ? 'text-xs' : 'text-sm'"
			class="block mb-1 font-medium text-gray-900 dark:text-gray-300">
			<slot name="label">{{ label }}</slot>
		</label>

		<div
			v-if="$slots.trail || $slots.lead"
			class="relative rounded-full shadow-sm">
			<div
				v-if="$slots.lead"
				class="absolute inset-y-0 left-0 pl-1.5 flex items-center pointer-events-none">
				<slot name="lead" />
			</div>
			<input
				:id="id"
				:value="modelValue"
				:disabled="disabled"
				:readonly="readonly"
				:autocomplete="autocomplete"
				:required="required"
				:autofocus="autofocus"
				ref="input"
				@input="$emit('update:modelValue', $event.target.value)"
				@change="$emit('changed', $event)"
				@blur="$emit('unfocused', $event)"
				@focus="$emit('focused', $event)"
				@keyup="$emit('onKeyUp', $event)"
				:type="type ? type : hide ? 'password' : 'text'"
				class="block w-full focus:outline-none appearance-none transition-colors duration-300 disabled:dark:bg-gray-750"
				:class="[
					{ 'cursor-pointer': readonly },
					error
						? 'bg-red-50 text-red-900 placeholder-red-700 rounded-lg dark:bg-red-100'
						: 'bg-white text-gray-900 rounded-lg dark:bg-white/10 dark:border-white/10 dark:placeholder-gray-400 dark:text-white',
					classes,
					...(Array.isArray(inputClasses)
						? inputClasses
						: [inputClasses]),
				]"
				:placeholder="placeholder" />
			<div
				v-if="error"
				class="absolute inset-y-0 right-0 pr-3 flex items-center">
				<ExclamationCircleIcon
					class="h-5 w-5 text-red-500"
					aria-hidden="true" />
				<slot name="trail" />
			</div>
			<div
				v-else-if="$slots.trail"
				class="absolute inset-y-0 right-0 pr-3 flex items-center">
				<slot name="trail" />
			</div>
		</div>
		<input
			v-else
			:id="id"
			name="code"
			:disabled="disabled"
			:autocomplete="autocomplete"
			:required="required"
			:autofocus="autofocus"
			:value="modelValue"
			ref="input"
			@input="$emit('update:modelValue', $event.target.value)"
			class="appearance-none"
			:class="['bg-white border-gray-300 text-gray-900  rounded-md dark:bg-[#FFFFFF0A] dark:border-gray-600 dark:placeholder-gray-400 dark:text-white',
				'block w-full focus:outline-none appearance-none disabled:dark:bg-gray-750',
				classes,
				inputClasses,
			]"
			:type="type ? type : hide ? 'password' : 'text'"
			:placeholder="placeholder" />
		<p v-if="error" class="mt-2 text-sm !text-red-500 font-normal">
			<template
				v-if="typeof error === 'string' || error instanceof String">
				{{ error }}
			</template>
			<template v-else-if="Array.isArray(error)">
				<ul class="list-disc">
					<li v-for="err in error" :key="err">
						{{ err }}
					</li>
				</ul>
			</template>
		</p>
		<p
			v-else-if="help"
			class="mt-1 text-sm text-gray-600 dark:text-gray-300"
			id="email-error">
			{{ help }}
		</p>
	</div>
</template>
