<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-avatar-group v-bind="$attrs">
    <slot />
  </el-avatar-group>
</template>
