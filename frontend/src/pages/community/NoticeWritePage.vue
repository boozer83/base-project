<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { noticeService } from '@/services/noticeService'
import type { NoticeRequest } from '@/types/notice'
import { CommonForm, CommonFormItem, CommonInput, CommonCheckbox, CommonButton } from '@/components/common'

const route = useRoute()
const router = useRouter()

const isEdit = ref(!!route.params.id)
const loading = ref(false)
const submitting = ref(false)

const form = ref<NoticeRequest>({
  title: '',
  content: '',
  isPinned: false,
})

async function fetchForEdit() {
  if (!isEdit.value) return
  loading.value = true
  try {
    const res = await noticeService.getOne(Number(route.params.id))
    const data = res.data.data
    form.value = { title: data.title, content: data.content, isPinned: data.isPinned }
  } catch {
    ElMessage.error('데이터를 불러오는 데 실패했습니다.')
    router.push('/community/notice')
  } finally {
    loading.value = false
  }
}

async function handleSubmit() {
  if (!form.value.title.trim()) { ElMessage.warning('제목을 입력해주세요.'); return }
  if (!form.value.content.trim()) { ElMessage.warning('내용을 입력해주세요.'); return }
  submitting.value = true
  try {
    if (isEdit.value) {
      await noticeService.update(Number(route.params.id), form.value)
      ElMessage.success('수정되었습니다.')
    } else {
      const res = await noticeService.create(form.value)
      ElMessage.success('등록되었습니다.')
      router.push(`/community/notice/${res.data.data.id}`)
      return
    }
    router.push(`/community/notice/${route.params.id}`)
  } catch {
    ElMessage.error('저장에 실패했습니다.')
  } finally {
    submitting.value = false
  }
}

onMounted(fetchForEdit)
</script>

<template>
  <div v-loading="loading" class="notice-write-page">
    <h2 class="page-title">{{ isEdit ? '공지사항 수정' : '공지사항 등록' }}</h2>

    <CommonForm label-position="top" class="write-form">
      <CommonFormItem label="제목">
        <CommonInput v-model="form.title" placeholder="제목을 입력하세요" :maxlength="200" show-word-limit />
      </CommonFormItem>
      <CommonFormItem label="내용">
        <CommonInput v-model="form.content" type="textarea" :rows="15" placeholder="내용을 입력하세요" />
      </CommonFormItem>
      <CommonFormItem>
        <CommonCheckbox v-model="form.isPinned">공지로 고정</CommonCheckbox>
      </CommonFormItem>
      <div class="form-actions">
        <CommonButton @click="router.back()">취소</CommonButton>
        <CommonButton type="primary" :loading="submitting" @click="handleSubmit">
          {{ isEdit ? '수정' : '등록' }}
        </CommonButton>
      </div>
    </CommonForm>
  </div>
</template>

<style scoped>
.notice-write-page { max-width: 900px; margin: 0 auto; }
.page-title { font-size: 22px; margin-bottom: 24px; }
.write-form { background: #fff; padding: 24px; border-radius: 4px; border: 1px solid #e4e7ed; }
.form-actions { display: flex; justify-content: flex-end; gap: 8px; }
</style>
