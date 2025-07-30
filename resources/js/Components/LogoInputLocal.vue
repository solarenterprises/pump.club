<script setup>
import { computed, reactive, ref } from "vue";

import { usePage } from "@inertiajs/vue3";
import FilePondPluginFileValidateType from "filepond-plugin-file-validate-type";
import FilePondPluginImagePreview from "filepond-plugin-image-preview";
import "filepond-plugin-image-preview/dist/filepond-plugin-image-preview.min.css";
import vueFilePond from "vue-filepond";

defineProps({
    modelValue: String,
    file: Object,
    errors: String,
    label: String,
});

const pond = ref(null);
defineExpose({
    clear: () => pond.value?.removeFile(),
    pond,
});

const emit = defineEmits(["update:modelValue", "update:file"]);
const FilePond = vueFilePond(
    FilePondPluginFileValidateType,
    FilePondPluginImagePreview
);

const server = reactive({
    url: "/filepond/api",
    process: "/process",
    revert: "/process",
    patch: "?patch=",
    headers: {
        "X-CSRF-TOKEN": computed(() => usePage().props.csrf_token),
    },
});

const uploadError = ref(null);
const uploadIcon = computed(() => {
    return `
        <div class="upload-area-inner">
            <div class="mb-2">
                <img src="/file-upload.svg" class="w-12 h-12 text-white mx-auto" />
            </div>
            <div class="upload-title">Select video or image to upload</div>
            <div class="upload-subtitle">Or drag and drop it here</div>
            <div class="upload-btn">Select file</div>
        </div>
    `;
});

const handleProcessFile = (error, file) => {
    if (error) uploadError.value = error;
    emit("update:file", {
        serverId: file.serverId,
        fileExtension: file.fileExtension,
        fileType: file.fileType,
        filenameWithoutExtension: file.filenameWithoutExtension,
        filename: file.filename,
        id: file.id,
    });
    if (file && file.filename) {
        emit("update:modelValue", file.filename);
    } else {
        emit("update:modelValue", "");
    }
    if (file && file.file) {
        const reader = new FileReader();
        reader.onload = (e) => {
            emit("preview", e.target.result);
        };
        reader.readAsDataURL(file.file);
    }
};

</script>
<template>
    <div class="flex items-center">
        <div>
            <FilePond
                name="filepond"
                ref="pond"
                class-name="logo filepond fp-bordered label-icon "
                :allow-multiple="false"
                :allowImagePreview="true"
                stylePanelAspectRatio="1:1"
                stylePanelLayout="compact"
                :label-idle="uploadIcon"
                accepted-file-types="image/jpeg, image/png, image/svg+xml"
                :server="server"
                @processfile="handleProcessFile"
                :allowBrowse="true"
                :allowDrop="true"
                :allowPaste="true"  
                :allowReplace="true"
                :allowRevert="true"
                :instantUpload="true"
            />
        </div>
        <p
            v-if="errors || uploadError"
            class="text-sm mb-4 ml-4 font-medium text-red"
        >
            {{ errors ?? uploadError }}
        </p>
        <p
            v-else-if="label"
            class="text-sm mb-4 ml-4 font-medium text-gray-900 dark:text-gray-300"
        >
            {{ label }}
        </p>
    </div>
</template>
<style>
.filepond.filepond--root[data-style-panel-layout~="circle"]
    .filepond--file
    [data-align*="right"] {
    right: calc(50% - 1em);
    top: calc(50% - 1em);
}

/* Make the FilePond component larger */
.filepond.filepond--root {
    min-height: 200px;
    max-height: 300px;
    min-width: 300px;
    max-width: 400px;
}

.filepond--panel-root {
    min-height: 200px;
    max-height: 300px;
    min-width: 300px;
    max-width: 400px;
}

.filepond--drop-label {
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    width: 100%;
    height: 100%;
}

.filepond--file-info {
    font-size: 14px;
}

.filepond--image-preview-wrapper {
    min-height: 200px;
    max-height: 300px;
    min-width: 300px;
    max-width: 400px;
}

/* Remove dotted border */
.filepond--panel-root {
    border: none !important;
    outline: none !important;
}

.filepond--drop-label {
    border: none !important;
    outline: none !important;
}

.filepond--root {
    border: none !important;
    outline: none !important;
}

.filepond--root {
    border-radius: 16px;
    min-width: 300px;
    min-height: 200px;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 1.5px dashed #fff2;
    box-shadow: 0 2px 16px #0004;
    position: relative;
}

.upload-area-inner {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100%;
    width: 100%;
    text-align: center;
}

.upload-area-inner svg {
    margin-bottom: 18px;
}

.upload-title {
    color: #fff;
    font-size: 1.25rem;
    font-weight: 600;
    margin-bottom: 4px;
    text-align: center;
}

.upload-subtitle {
    color: #fff8;
    font-size: 1rem;
    margin-bottom: 18px;
    text-align: center;
}

.upload-btn {
    background: #da520024;
    color: #da5200;
    border-radius: 8px;
    padding: 8px 32px;
    font-size: 1rem;
    font-weight: 500;
    cursor: pointer;
    text-align: center;
}

.upload-btn:hover {
    background: #ff7300;
    color: #fff;
}

.filepond--action-remove,
.filepond--file-action-button[data-align="right"] {
    display: none !important;
}
</style>
