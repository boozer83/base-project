<script setup lang="ts">
defineOptions({ inheritAttrs: false })
const model = defineModel<boolean>({ default: false })
</script>

<template>
  <el-dialog v-model="model" v-bind="$attrs">
    <slot />
    <template v-if="$slots.footer" #footer>
      <slot name="footer" />
    </template>
  </el-dialog>
</template>
