<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-header v-bind="$attrs">
    <slot />
  </el-header>
</template>
