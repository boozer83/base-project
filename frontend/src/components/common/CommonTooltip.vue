<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-tooltip v-bind="$attrs">
    <slot />
  </el-tooltip>
</template>
