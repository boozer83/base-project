<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-form v-bind="$attrs">
    <slot />
  </el-form>
</template>
