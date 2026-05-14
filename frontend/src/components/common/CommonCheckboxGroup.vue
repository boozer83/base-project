<script setup lang="ts">
defineOptions({ inheritAttrs: false })

export interface CheckboxOption {
  value: string | number
  label: string
  disabled?: boolean
}

const props = defineProps<{
  options: CheckboxOption[]
}>()

const model = defineModel<(string | number)[]>({ default: () => [] })
</script>

<template>
  <el-checkbox-group v-model="model" v-bind="$attrs">
    <el-checkbox
      v-for="opt in options"
      :key="opt.value"
      :value="opt.value"
      :disabled="opt.disabled"
    >
      {{ opt.label }}
    </el-checkbox>
  </el-checkbox-group>
</template>
