<script setup lang="ts">
defineOptions({ inheritAttrs: false })
const model = defineModel<boolean>()
</script>

<template>
  <el-switch v-model="model" v-bind="$attrs" />
</template>
