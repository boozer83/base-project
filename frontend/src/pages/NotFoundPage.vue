<script setup lang="ts">
import { useRouter } from 'vue-router'
import { CommonButton } from '@/components/common'

const router = useRouter()
</script>

<template>
  <div class="not-found">
    <div class="not-found-content">
      <p class="error-code">404</p>
      <h1 class="error-title">페이지를 찾을 수 없습니다</h1>
      <p class="error-desc">요청하신 페이지가 존재하지 않거나 이동되었습니다.</p>
      <div class="actions">
        <CommonButton type="primary" @click="router.push('/')">홈으로 이동</CommonButton>
        <CommonButton @click="router.back()">이전 페이지</CommonButton>
      </div>
    </div>
  </div>
</template>

<style scoped>
.not-found {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 400px;
}
.not-found-content {
  text-align: center;
}
.error-code {
  font-size: 120px;
  font-weight: 700;
  color: #dcdfe6;
  line-height: 1;
  margin: 0 0 16px;
}
.error-title {
  font-size: 24px;
  color: #303133;
  margin: 0 0 12px;
}
.error-desc {
  font-size: 14px;
  color: #909399;
  margin: 0 0 32px;
}
.actions {
  display: flex;
  gap: 12px;
  justify-content: center;
}
</style>
