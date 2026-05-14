<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-tag v-bind="$attrs">
    <slot />
  </el-tag>
</template>
