<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-popover v-bind="$attrs">
    <template #reference>
      <slot name="reference" />
    </template>
    <slot />
  </el-popover>
</template>
