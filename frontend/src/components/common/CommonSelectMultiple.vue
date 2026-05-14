<script setup lang="ts">
import type { SelectOption } from './CommonSelect.vue'

const props = defineProps<{
  options: SelectOption[]
  placeholder?: string
  collapseTags?: boolean
  disabled?: boolean
  filterable?: boolean
}>()

const model = defineModel<(string | number)[]>({ default: () => [] })
</script>

<template>
  <el-select
    v-model="model"
    multiple
    :collapse-tags="collapseTags ?? true"
    :collapse-tags-tooltip="collapseTags ?? true"
    :placeholder="placeholder ?? '항목 선택'"
    :disabled="disabled"
    :filterable="filterable"
  >
    <el-option
      v-for="opt in options"
      :key="opt.value"
      :label="opt.label"
      :value="opt.value"
      :disabled="opt.disabled"
    />
  </el-select>
</template>
