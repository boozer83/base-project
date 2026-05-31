<script setup lang="ts">
import DefaultLayout from '@/layouts/DefaultLayout.vue'
import { useLoadingStore } from '@/stores/useLoadingStore'

const loadingStore = useLoadingStore()
</script>

<template>
  <div
    class="app-root"
    v-loading.fullscreen="loadingStore.isLoading"
    element-loading-text="로딩 중..."
    element-loading-background="rgba(0, 0, 0, 0.5)"
  >
    <DefaultLayout />
  </div>
</template>

<style>
html, body {
  margin: 0;
  padding: 0;
  height: 100%;
}
#app {
  height: 100%;
}
</style>

<style scoped>
.app-root {
  height: 100%;
}
</style>
