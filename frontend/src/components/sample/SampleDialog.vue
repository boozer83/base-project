<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { CommonButton, CommonDialog, CommonForm, CommonFormItem, CommonInput } from '@/components/common'

const dialogVisible = ref(false)

function onConfirm() {
  dialogVisible.value = false
  ElMessage({ type: 'success', message: '확인되었습니다.', showClose: true })
}
</script>

<template>
  <div>
    <CommonButton type="primary" @click="dialogVisible = true">다이얼로그 열기</CommonButton>

    <CommonDialog v-model="dialogVisible" title="샘플 다이얼로그" width="480px">
      <p>다이얼로그 본문 영역입니다. 확인이 필요한 내용이나 폼을 표시합니다.</p>
      <CommonForm label-width="80px" style="margin-top: 16px">
        <CommonFormItem label="이름"><CommonInput placeholder="이름 입력" /></CommonFormItem>
        <CommonFormItem label="이메일"><CommonInput placeholder="이메일 입력" /></CommonFormItem>
      </CommonForm>
      <template #footer>
        <CommonButton @click="dialogVisible = false">취소</CommonButton>
        <CommonButton type="primary" @click="onConfirm">확인</CommonButton>
      </template>
    </CommonDialog>
  </div>
</template>
