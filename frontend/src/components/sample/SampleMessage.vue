<script setup lang="ts">
import { ElMessage, ElNotification } from 'element-plus'
import { Check, Warning, CircleCloseFilled, InfoFilled, Bell } from '@element-plus/icons-vue'
import { CommonButton, CommonAlert } from '@/components/common'

function showMessage(type: 'success' | 'warning' | 'error' | 'info') {
  ElMessage({ type, message: `${type} 메시지입니다.`, showClose: true })
}

function showNotification(type: 'success' | 'warning' | 'error' | 'info') {
  ElNotification({ type, title: '알림', message: `${type} 알림이 도착했습니다.`, duration: 3000 })
}
</script>

<template>
  <div class="message-wrap">
    <div class="row">
      <CommonButton type="success"  :icon="Check"             @click="showMessage('success')">Success 메시지</CommonButton>
      <CommonButton type="warning"  :icon="Warning"           @click="showMessage('warning')">Warning 메시지</CommonButton>
      <CommonButton type="danger"   :icon="CircleCloseFilled" @click="showMessage('error')">Error 메시지</CommonButton>
      <CommonButton type="info"     :icon="InfoFilled"        @click="showMessage('info')">Info 메시지</CommonButton>
    </div>
    <div class="row">
      <CommonButton :icon="Bell" @click="showNotification('success')">Success 알림</CommonButton>
      <CommonButton :icon="Bell" @click="showNotification('warning')">Warning 알림</CommonButton>
      <CommonButton :icon="Bell" @click="showNotification('error')">Error 알림</CommonButton>
      <CommonButton :icon="Bell" @click="showNotification('info')">Info 알림</CommonButton>
    </div>
    <div class="alert-area">
      <CommonAlert title="성공 알럿 — 작업이 완료되었습니다."         type="success" :closable="false" />
      <CommonAlert title="경고 알럿 — 주의가 필요합니다."             type="warning" show-icon />
      <CommonAlert title="오류 알럿 — 처리 중 오류가 발생했습니다."   type="error"   show-icon />
      <CommonAlert title="정보 알럿 — 참고해 주세요." description="자세한 내용은 문서를 확인하세요." type="info" show-icon />
    </div>
  </div>
</template>

<style scoped>
.message-wrap { display: flex; flex-direction: column; gap: 12px; }
.row { display: flex; flex-wrap: wrap; gap: 8px; }
.alert-area { display: flex; flex-direction: column; gap: 8px; }
</style>
