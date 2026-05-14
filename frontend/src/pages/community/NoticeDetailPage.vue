<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { noticeService } from '@/services/noticeService'
import { useAuthStore } from '@/stores/useAuthStore'
import type { Notice } from '@/types/notice'
import { CommonTag, CommonDivider, CommonButton } from '@/components/common'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const notice = ref<Notice | null>(null)
const loading = ref(false)

async function fetchNotice() {
  loading.value = true
  try {
    const res = await noticeService.getOne(Number(route.params.id))
    notice.value = res.data.data
  } catch {
    ElMessage.error('공지사항을 불러오는 데 실패했습니다.')
    router.push('/community/notice')
  } finally {
    loading.value = false
  }
}

async function handleDelete() {
  await ElMessageBox.confirm('삭제하시겠습니까?', '확인', { type: 'warning' })
  try {
    await noticeService.delete(Number(route.params.id))
    ElMessage.success('삭제되었습니다.')
    router.push('/community/notice')
  } catch {
    ElMessage.error('삭제에 실패했습니다.')
  }
}

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleString('ko-KR')
}

onMounted(fetchNotice)
</script>

<template>
  <div class="notice-detail-page" v-loading="loading">
    <template v-if="notice">
      <div class="detail-header">
        <CommonTag v-if="notice.isPinned" type="danger" class="pin-tag">공지</CommonTag>
        <h2 class="detail-title">{{ notice.title }}</h2>
        <div class="detail-meta">
          <span>{{ notice.authorName }}</span>
          <CommonDivider direction="vertical" />
          <span>{{ formatDate(notice.createdAt) }}</span>
          <CommonDivider direction="vertical" />
          <span>조회 {{ notice.viewCount }}</span>
        </div>
      </div>

      <CommonDivider />

      <div class="detail-content">{{ notice.content }}</div>

      <div class="detail-actions">
        <CommonButton @click="router.push('/community/notice')">목록</CommonButton>
        <template v-if="authStore.isAdmin">
          <CommonButton type="primary" @click="router.push(`/community/notice/${notice.id}/edit`)">수정</CommonButton>
          <CommonButton type="danger" @click="handleDelete">삭제</CommonButton>
        </template>
      </div>
    </template>
  </div>
</template>

<style scoped>
.notice-detail-page { max-width: 900px; margin: 0 auto; }
.detail-header { margin-bottom: 8px; }
.pin-tag { margin-bottom: 8px; }
.detail-title { font-size: 24px; margin: 0 0 12px; }
.detail-meta { color: #909399; font-size: 14px; }
.detail-content { min-height: 200px; line-height: 1.8; white-space: pre-wrap; color: #303133; }
.detail-actions { display: flex; gap: 8px; margin-top: 32px; }
</style>
