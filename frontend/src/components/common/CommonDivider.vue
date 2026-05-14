<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-divider v-bind="$attrs">
    <slot />
  </el-divider>
</template>
