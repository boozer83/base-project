<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-icon v-bind="$attrs">
    <slot />
  </el-icon>
</template>
