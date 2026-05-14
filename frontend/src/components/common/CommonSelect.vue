<script setup lang="ts">
export interface SelectOption {
  value: string | number
  label: string
  disabled?: boolean
}

export interface SelectOptionGroup {
  label: string
  options: SelectOption[]
}

const props = defineProps<{
  options?: SelectOption[]
  groups?: SelectOptionGroup[]
  placeholder?: string
  clearable?: boolean
  disabled?: boolean
  filterable?: boolean
}>()

const model = defineModel<string | number>({ default: '' })
</script>

<template>
  <el-select
    v-model="model"
    :placeholder="placeholder ?? '선택'"
    :clearable="clearable"
    :disabled="disabled"
    :filterable="filterable"
  >
    <template v-if="groups?.length">
      <el-option-group
        v-for="group in groups"
        :key="group.label"
        :label="group.label"
      >
        <el-option
          v-for="opt in group.options"
          :key="opt.value"
          :label="opt.label"
          :value="opt.value"
          :disabled="opt.disabled"
        />
      </el-option-group>
    </template>
    <template v-else>
      <el-option
        v-for="opt in options ?? []"
        :key="opt.value"
        :label="opt.label"
        :value="opt.value"
        :disabled="opt.disabled"
      />
    </template>
  </el-select>
</template>
