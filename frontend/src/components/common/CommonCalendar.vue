<script setup lang="ts">
import { computed } from 'vue'

type CalendarType = 'date' | 'datetime'

const props = defineProps<{
  type?: CalendarType
  placeholder?: string
  format?: string
  disabled?: boolean
}>()

const model = defineModel<string>({ default: '' })

const resolvedFormat = computed(() =>
  props.format ?? (props.type === 'datetime' ? 'YYYY-MM-DD HH:mm' : 'YYYY-MM-DD'),
)
</script>

<template>
  <el-date-picker
    v-model="model"
    :type="type ?? 'date'"
    :placeholder="placeholder ?? '날짜 선택'"
    :format="resolvedFormat"
    :value-format="resolvedFormat"
    :disabled="disabled"
  />
</template>
