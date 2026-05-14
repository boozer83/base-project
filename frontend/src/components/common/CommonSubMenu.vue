<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-sub-menu v-bind="$attrs">
    <template v-if="$slots.title" #title><slot name="title" /></template>
    <slot />
  </el-sub-menu>
</template>
