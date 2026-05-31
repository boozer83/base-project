import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useLoadingStore = defineStore('loading', () => {
  const pendingCount = ref(0)
  const isLoading = computed(() => pendingCount.value > 0)

  function start() {
    pendingCount.value++
  }

  function done() {
    if (pendingCount.value > 0) pendingCount.value--
  }

  return { isLoading, start, done }
})
