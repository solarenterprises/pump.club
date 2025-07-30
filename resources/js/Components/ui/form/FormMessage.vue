<script setup>
import { toValue } from 'vue';

import { ErrorMessage } from 'vee-validate';

import { useFormField } from './useFormField';

const { name, formMessageId } = useFormField();
</script>

<template>
  <ErrorMessage
    :id="formMessageId"
    as="p"
    :name="toValue(name)"
    class="text-sm font-medium text-red-500 dark:text-red-900"
  />
</template>
