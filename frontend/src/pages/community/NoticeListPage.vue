<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { noticeService } from '@/services/noticeService'
import { useAuthStore } from '@/stores/useAuthStore'
import type { NoticeListItem } from '@/types/notice'

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

onMounted(fetchList)
</script>

<template>
  <div class="notice-list-page">
    <div class="page-header">
      <h2 class="page-title">공지사항</h2>
      <el-button
        v-if="authStore.isAdmin"
        type="primary"
        @click="router.push('/community/notice/write')"
      >
        글쓰기
      </el-button>
    </div>

    <el-table
      v-loading="loading"
      :data="list"
      style="width: 100%"
      @row-click="(row: NoticeListItem) => goDetail(row.id)"
      row-class-name="clickable-row"
    >
      <el-table-column width="60" align="center">
        <template #default="{ row }">
          <el-tag v-if="row.isPinned" type="danger" size="small">공지</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="title" label="제목" min-width="300">
        <template #default="{ row }">
          <span :class="{ 'pinned-title': row.isPinned }">{{ row.title }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="authorName" label="작성자" width="120" align="center" />
      <el-table-column label="조회" prop="viewCount" width="80" align="center" />
      <el-table-column label="날짜" width="120" align="center">
        <template #default="{ row }">{{ formatDate(row.createdAt) }}</template>
      </el-table-column>
    </el-table>

    <div class="pagination-wrap">
      <el-pagination
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
.notice-list-page {
  max-width: 900px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.page-title {
  margin: 0;
  font-size: 22px;
}

.pagination-wrap {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.pinned-title {
  font-weight: 600;
  color: #303133;
}

:deep(.clickable-row) {
  cursor: pointer;
}

:deep(.clickable-row:hover td) {
  background-color: #f5f7fa !important;
}
</style>
