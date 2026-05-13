<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { noticeService } from '@/services/noticeService'
import type { NoticeRequest } from '@/types/notice'

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
  if (!form.value.title.trim()) {
    ElMessage.warning('제목을 입력해주세요.')
    return
  }
  if (!form.value.content.trim()) {
    ElMessage.warning('내용을 입력해주세요.')
    return
  }
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
  <div class="notice-write-page" v-loading="loading">
    <h2 class="page-title">{{ isEdit ? '공지사항 수정' : '공지사항 등록' }}</h2>

    <el-form label-position="top" class="write-form">
      <el-form-item label="제목">
        <el-input v-model="form.title" placeholder="제목을 입력하세요" maxlength="200" show-word-limit />
      </el-form-item>

      <el-form-item label="내용">
        <el-input
          v-model="form.content"
          type="textarea"
          :rows="15"
          placeholder="내용을 입력하세요"
        />
      </el-form-item>

      <el-form-item>
        <el-checkbox v-model="form.isPinned">공지로 고정</el-checkbox>
      </el-form-item>

      <div class="form-actions">
        <el-button @click="router.back()">취소</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">
          {{ isEdit ? '수정' : '등록' }}
        </el-button>
      </div>
    </el-form>
  </div>
</template>

<style scoped>
.notice-write-page {
  max-width: 900px;
  margin: 0 auto;
}

.page-title {
  font-size: 22px;
  margin-bottom: 24px;
}

.write-form {
  background: #fff;
  padding: 24px;
  border-radius: 4px;
  border: 1px solid #e4e7ed;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}
</style>
