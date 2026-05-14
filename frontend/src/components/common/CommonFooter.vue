<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-footer v-bind="$attrs">
    <slot />
  </el-footer>
</template>
