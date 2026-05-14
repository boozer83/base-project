<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { noticeService } from '@/services/noticeService'
import { useAuthStore } from '@/stores/useAuthStore'
import type { NoticeListItem } from '@/types/notice'
import { CommonButton, CommonTag, CommonTable, CommonPagination } from '@/components/common'
import type { TableColumn } from '@/components/common'

const router = useRouter()
const authStore = useAuthStore()

const list = ref<NoticeListItem[]>([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)
const loading = ref(false)

async function fetchList() {
  loading.value = true
  try {
    const res = await noticeService.getList(currentPage.value, pageSize.value)
    list.value = res.data.data.list
    total.value = res.data.data.total
  } catch {
    ElMessage.error('목록을 불러오는 데 실패했습니다.')
  } finally {
    loading.value = false
  }
}

function handlePageChange(page: number) {
  currentPage.value = page
  fetchList()
}

function goDetail(id: number) {
  router.push(`/community/notice/${id}`)
}

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleDateString('ko-KR')
}

const columns: TableColumn[] = [
  { prop: 'isPinned', label: '',        width: 60,  align: 'center', slot: true },
  { prop: 'title',    label: '제목',    minWidth: 300, slot: true },
  { prop: 'authorName', label: '작성자', width: 120, align: 'center' },
  { prop: 'viewCount',  label: '조회',  width: 80,  align: 'center' },
  { prop: 'createdAt',  label: '날짜',  width: 120, align: 'center', slot: true },
]

onMounted(fetchList)
</script>

<template>
  <div class="notice-list-page">
    <div class="page-header">
      <h2 class="page-title">공지사항</h2>
      <CommonButton
        v-if="authStore.isAdmin"
        type="primary"
        @click="router.push('/community/notice/write')"
      >
        글쓰기
      </CommonButton>
    </div>

    <CommonTable
      v-loading="loading"
      :columns="columns"
      :data="(list as Record<string, unknown>[])"
      :default-page-size="pageSize"
      style="width: 100%"
      row-class-name="clickable-row"
      @row-click="(row: Record<string, unknown>) => goDetail(row.id as number)"
    >
      <template #isPinned="{ row }">
        <CommonTag v-if="(row as NoticeListItem).isPinned" type="danger" size="small">공지</CommonTag>
      </template>
      <template #title="{ row }">
        <span :class="{ 'pinned-title': (row as NoticeListItem).isPinned }">
          {{ (row as NoticeListItem).title }}
        </span>
      </template>
      <template #createdAt="{ row }">
        {{ formatDate((row as NoticeListItem).createdAt) }}
      </template>
    </CommonTable>

    <div class="pagination-wrap">
      <CommonPagination
        v-model:current-page="currentPage"
        :page-size="pageSize"
        :total="total"
        layout="prev, pager, next"
        @current-change="handlePageChange"
      />
    </div>
  </div>
</template>

<style scoped>
.notice-list-page { max-width: 900px; margin: 0 auto; }
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.page-title { margin: 0; font-size: 22px; }
.pagination-wrap { display: flex; justify-content: center; margin-top: 20px; }
.pinned-title { font-weight: 600; color: #303133; }
:deep(.clickable-row) { cursor: pointer; }
:deep(.clickable-row:hover td) { background-color: #f5f7fa !important; }
</style>
