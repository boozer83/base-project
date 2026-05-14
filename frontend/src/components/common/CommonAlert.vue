<script setup lang="ts">
defineOptions({ inheritAttrs: false })
</script>

<template>
  <el-alert v-bind="$attrs">
    <template v-if="$slots.default" #default><slot /></template>
    <template v-if="$slots.title" #title><slot name="title" /></template>
  </el-alert>
</template>
