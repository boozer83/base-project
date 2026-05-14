<script setup lang="ts">
defineOptions({ inheritAttrs: false })
const model = defineModel<number>({ default: 0 })
</script>

<template>
  <el-rate v-model="model" v-bind="$attrs" />
</template>
