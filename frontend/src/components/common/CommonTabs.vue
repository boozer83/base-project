<script setup lang="ts">
defineOptions({ inheritAttrs: false })

export interface TabItem {
  name: string
  label: string
  disabled?: boolean
}

const props = defineProps<{
  tabs: TabItem[]
}>()

const model = defineModel<string>()
</script>

<template>
  <el-tabs v-model="model" v-bind="$attrs">
    <el-tab-pane
      v-for="tab in tabs"
      :key="tab.name"
      :name="tab.name"
      :label="tab.label"
      :disabled="tab.disabled"
    >
      <slot :name="tab.name" />
    </el-tab-pane>
  </el-tabs>
</template>
