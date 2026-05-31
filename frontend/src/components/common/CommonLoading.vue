<script setup lang="ts">
interface Props {
  loading?: boolean
  text?: string
  background?: string
  minHeight?: string
}

withDefaults(defineProps<Props>(), {
  loading: false,
  text: '로딩 중...',
  background: 'rgba(255, 255, 255, 0.8)',
  minHeight: '80px',
})
</script>

<template>
  <div
    v-loading="loading"
    :element-loading-text="text"
    :element-loading-background="background"
    :style="{ minHeight }"
    class="common-loading"
  >
    <slot />
  </div>
</template>

<style scoped>
.common-loading {
  position: relative;
}
</style>
