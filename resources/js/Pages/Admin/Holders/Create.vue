<script setup>
import { Link, useForm } from "@inertiajs/vue3";
import { HiArrowLeft } from "oh-vue-icons/icons";

import FormInput from "@/Components/FormInput.vue";
import FormSwitch from "@/Components/FormSwitch.vue";
import Loading from "@/Components/Loading.vue";
import PrimaryButton from "@/Components/PrimaryButton.vue";
import VueIcon from "@/Components/VueIcon.vue";
import AdminLayout from "@/Layouts/AdminLayout.vue";
defineProps({
    title:{required:false,type:String},
});
const form = useForm({
		launchpad_id:"",
		user_id:"",
		address:"",
		qty:"",
		prebond:""
});
const save = () => form.post(window.route("admin.holders.store"));
</script>
<template>
	<Head :title="title ?? `New Holder`" />
	<AdminLayout>
        <main class="h-full container sm:p-8">
			<div class="relative h-full flex flex-auto flex-col px-4 sm:px-6 py-12 sm:py-6 md:px-8">
				<div class="flex flex-col gap-4 h-full">
					<div class="lg:flex items-center justify-between mb-4 gap-3">
						<div class="mb-4 lg:mb-0">
							<h3 class="h3">Add New Holder</h3>
						</div>
						<div class="flex flex-col lg:flex-row lg:items-center gap-3">
							<PrimaryButton
                                secondary
                                link
								:href="route('admin.holders.index')"
							>
								
                                <VueIcon :icon="HiArrowLeft" class="w-4 h-4 -ml-1 mr-2 inline-block" />
								{{ $t("Back to holders list") }}</PrimaryButton
							>
						</div>
					</div>
					<div class="card sm:p-12 h-full border-0 card-border">
						<div class="card-body card-gutterless h-full">
							<form
        						class="grid sm:grid-cols-2 lg:grid-cols-4 gap-4"
        						@submit.prevent="save()">
        												 
<FormInput
    :label="Launchpad_id"
	v-model="form.launchpad_id"
	class="col-span-3"
    :type="number"
	:error="form.errors.launchpad_id"
    
    
/>
        
						 
<FormInput
    :label="User_id"
	v-model="form.user_id"
	class="col-span-3"
    :type="number"
	:error="form.errors.user_id"
    
    
/>
        
						 
<FormInput
    :label="Address"
	v-model="form.address"
	class="col-span-3"
    :type="text"
	:error="form.errors.address"
    
    
/>
        
						 
<FormInput
    :label="Qty"
	v-model="form.qty"
	class="col-span-3"
    :type="text"
	:error="form.errors.qty"
    
    
/>
        
						         <FormSwitch v-model="form.prebond">{{$t('Prebond')}}</FormSwitch>
        						<div class="pt-5 sm:col-span-2 lg:col-span-4">
        							<div class="flex items-center gap-3 justify-end">
        								<PrimaryButton
                                            secondary
        									as="button"
        									:href="route('admin.holders.index')"
        									type="button"
                                            link
                                        >
        									{{ $t("Cancel") }}
        								</PrimaryButton>
        								<PrimaryButton
        									type="submit"
        									:disabled="form.processing"
        									>
        									<Loading
        										class="mr-2 -ml-1 inline-block w-5 h-5"
        										v-if="form.processing" />
        									{{ $t("Save Holder") }}
        								</PrimaryButton>
        							</div>
        						</div>
        					</form>
						</div>
					</div>
				</div>
			</div>
		</main>
	</AdminLayout>
</template>
