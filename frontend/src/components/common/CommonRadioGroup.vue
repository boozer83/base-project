<script setup lang="ts">
defineOptions({ inheritAttrs: false })

export interface RadioOption {
  value: string | number
  label: string
  disabled?: boolean
}

const props = defineProps<{
  options: RadioOption[]
  buttonStyle?: boolean
}>()

const model = defineModel<string | number>()
</script>

<template>
  <el-radio-group v-model="model" v-bind="$attrs">
    <template v-if="buttonStyle">
      <el-radio-button
        v-for="opt in options"
        :key="opt.value"
        :value="opt.value"
        :disabled="opt.disabled"
      >
        {{ opt.label }}
      </el-radio-button>
    </template>
    <template v-else>
      <el-radio
        v-for="opt in options"
        :key="opt.value"
        :value="opt.value"
        :disabled="opt.disabled"
      >
        {{ opt.label }}
      </el-radio>
    </template>
  </el-radio-group>
</template>
