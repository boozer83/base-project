<script setup lang="ts">
import { computed } from 'vue'
import { Search } from '@element-plus/icons-vue'

type InputType = 'text' | 'password' | 'textarea' | 'search'

const props = defineProps<{
  type?: InputType
  placeholder?: string
  clearable?: boolean
  disabled?: boolean
  rows?: number
  maxlength?: number
  showWordLimit?: boolean
}>()

const model = defineModel<string>({ default: '' })

const elType = computed(() => {
  if (props.type === 'textarea') return 'textarea'
  if (props.type === 'password') return 'password'
  return 'text'
})

const prefixIcon = computed(() => (props.type === 'search' ? Search : undefined))
</script>

<template>
  <el-input
    v-model="model"
    :type="elType"
    :placeholder="placeholder ?? '입력'"
    :clearable="clearable"
    :disabled="disabled"
    :rows="rows ?? 3"
    :maxlength="maxlength"
    :show-word-limit="showWordLimit"
    :show-password="type === 'password'"
    :prefix-icon="prefixIcon"
  />
</template>
