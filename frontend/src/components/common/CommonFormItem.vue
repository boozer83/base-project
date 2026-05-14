<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-form-item v-bind="$attrs">
    <slot />
  </el-form-item>
</template>
