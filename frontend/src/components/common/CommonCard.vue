<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-card v-bind="$attrs">
    <template v-if="$slots.header" #header><slot name="header" /></template>
    <slot />
  </el-card>
</template>
