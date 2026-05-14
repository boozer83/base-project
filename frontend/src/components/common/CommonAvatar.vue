<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-avatar v-bind="$attrs">
    <slot />
  </el-avatar>
</template>
