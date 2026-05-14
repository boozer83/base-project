<script setup lang="ts">
const props = defineProps<{
  min?: number
  max?: number
  step?: number
  precision?: number
  disabled?: boolean
  controls?: boolean
}>()

const model = defineModel<number>({ default: 0 })
</script>

<template>
  <el-input-number
    v-model="model"
    :min="min"
    :max="max"
    :step="step ?? 1"
    :precision="precision"
    :disabled="disabled"
    :controls="controls !== false"
  />
</template>
