<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-container v-bind="$attrs">
    <slot />
  </el-container>
</template>
