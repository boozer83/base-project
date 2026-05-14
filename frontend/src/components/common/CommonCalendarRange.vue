<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  startPlaceholder?: string
  endPlaceholder?: string
  format?: string
  disabled?: boolean
}>()

const model = defineModel<[string, string] | null>({ default: null })

const fmt = computed(() => props.format ?? 'YYYY-MM-DD')
</script>

<template>
  <el-date-picker
    v-model="model"
    type="daterange"
    range-separator="~"
    :start-placeholder="startPlaceholder ?? '시작일'"
    :end-placeholder="endPlaceholder ?? '종료일'"
    :format="fmt"
    :value-format="fmt"
    :disabled="disabled"
  />
</template>
