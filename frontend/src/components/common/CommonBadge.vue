<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-badge v-bind="$attrs">
    <slot />
  </el-badge>
</template>
