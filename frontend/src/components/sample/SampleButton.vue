<script setup lang="ts">
import { Edit, Check, Delete, Download, Upload } from '@element-plus/icons-vue'
import { CommonButton } from '@/components/common'
</script>

<template>
  <div class="btn-section">
    <div class="row">
      <CommonButton>기본</CommonButton>
      <CommonButton type="primary">Primary</CommonButton>
      <CommonButton type="success">Success</CommonButton>
      <CommonButton type="warning">Warning</CommonButton>
      <CommonButton type="danger">Danger</CommonButton>
      <CommonButton type="info">Info</CommonButton>
    </div>
    <div class="row">
      <CommonButton plain>Plain</CommonButton>
      <CommonButton type="primary" plain>Primary Plain</CommonButton>
      <CommonButton type="success" round>Round</CommonButton>
      <CommonButton type="danger" round>Round Danger</CommonButton>
      <CommonButton type="primary" :icon="Edit" circle />
      <CommonButton type="success" :icon="Check" circle />
      <CommonButton type="danger" :icon="Delete" circle />
    </div>
    <div class="row">
      <CommonButton size="large" type="primary">Large</CommonButton>
      <CommonButton type="primary">Default</CommonButton>
      <CommonButton size="small" type="primary">Small</CommonButton>
      <CommonButton type="primary" :icon="Download">다운로드</CommonButton>
      <CommonButton type="primary" :icon="Upload">업로드</CommonButton>
      <CommonButton type="primary" loading>로딩 중</CommonButton>
      <CommonButton disabled>비활성</CommonButton>
    </div>
  </div>
</template>

<style scoped>
.btn-section { display: flex; flex-direction: column; gap: 12px; }
.row { display: flex; align-items: center; flex-wrap: wrap; gap: 8px; }
</style>
