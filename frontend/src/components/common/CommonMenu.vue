<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-menu v-bind="$attrs">
    <slot />
  </el-menu>
</template>
