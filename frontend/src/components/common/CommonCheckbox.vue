<script setup lang="ts">
defineOptions({ inheritAttrs: false })
const model = defineModel<boolean>()
</script>

<template>
  <el-checkbox v-model="model" v-bind="$attrs">
    <slot />
  </el-checkbox>
</template>
