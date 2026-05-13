<script setup lang="ts">
import { onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/useAuthStore'
import { ElMessage } from 'element-plus'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

onMounted(async () => {
  const token = route.query.token as string | undefined
  const refreshToken = route.query.refreshToken as string | undefined
  if (token && refreshToken) {
    authStore.setTokens(token, refreshToken)
    await authStore.fetchUser()
    ElMessage.success('로그인되었습니다.')
    router.replace('/')
  } else {
    ElMessage.error('로그인에 실패했습니다.')
    router.replace('/')
  }
})
</script>

<template>
  <div class="callback-page">
    <el-icon class="loading-icon"><Loading /></el-icon>
    <p>로그인 처리 중...</p>
  </div>
</template>

<style scoped>
.callback-page {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 300px;
  gap: 16px;
  color: #606266;
}

.loading-icon {
  font-size: 40px;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
</style>
