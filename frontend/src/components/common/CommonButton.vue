<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-button v-bind="$attrs">
    <template v-if="$slots.icon" #icon><slot name="icon" /></template>
    <slot />
  </el-button>
</template>
