<script setup lang="ts">
import { useRouter } from 'vue-router'

const router = useRouter()
</script>

<template>
  <div class="error-page">
    <div class="error-code">404</div>
    <div class="error-title">페이지를 찾을 수 없습니다</div>
    <div class="error-description">
      요청하신 페이지가 존재하지 않거나 이동되었습니다.
    </div>
    <div class="error-actions">
      <button class="btn-home" @click="router.push('/')">홈으로 이동</button>
      <button class="btn-back" @click="router.back()">이전 페이지</button>
    </div>
  </div>
</template>

<style scoped>
.error-page {
  text-align: center;
  padding: 40px 20px;
}
.error-code {
  font-size: 120px;
  font-weight: 700;
  color: #409eff;
  line-height: 1;
  margin-bottom: 16px;
}
.error-title {
  font-size: 24px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 12px;
}
.error-description {
  font-size: 15px;
  color: #909399;
  margin-bottom: 32px;
}
.error-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
}
.btn-home,
.btn-back {
  padding: 10px 24px;
  border-radius: 6px;
  font-size: 14px;
  cursor: pointer;
  border: none;
  transition: opacity 0.2s;
}
.btn-home:hover,
.btn-back:hover {
  opacity: 0.85;
}
.btn-home {
  background-color: #409eff;
  color: #fff;
}
.btn-back {
  background-color: #fff;
  color: #606266;
  border: 1px solid #dcdfe6;
}
</style>
