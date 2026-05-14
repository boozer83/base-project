<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-menu-item v-bind="$attrs">
    <slot />
  </el-menu-item>
</template>
