<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import DefaultLayout from '@/layouts/DefaultLayout.vue'
import ErrorLayout from '@/layouts/ErrorLayout.vue'

const route = useRoute()

const layout = computed(() => {
  return route.meta.layout === 'error' ? ErrorLayout : DefaultLayout
})
</script>

<template>
  <component :is="layout" />
</template>
