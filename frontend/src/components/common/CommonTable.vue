<script setup lang="ts">
import { ref, computed } from 'vue'
import { Search } from '@element-plus/icons-vue'

export interface TableColumn {
  prop: string
  label: string
  width?: number
  minWidth?: number
  align?: 'left' | 'center' | 'right'
  slot?: boolean
  type?: 'index'
}

const props = defineProps<{
  columns: TableColumn[]
  data: Record<string, unknown>[]
  searchFields?: string[]
  pageSizes?: number[]
  defaultPageSize?: number
  searchPlaceholder?: string
}>()

const searchQuery = ref('')
const currentPage = ref(1)
const pageSize = ref(props.defaultPageSize ?? 10)

const filteredData = computed(() => {
  if (!searchQuery.value || !props.searchFields?.length) return props.data
  const q = searchQuery.value.toLowerCase()
  return props.data.filter((row) =>
    props.searchFields!.some((field) =>
      String(row[field] ?? '').toLowerCase().includes(q),
    ),
  )
})

const pagedData = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  return filteredData.value.slice(start, start + pageSize.value)
})
</script>

<template>
  <div>
    <div v-if="searchFields?.length" class="toolbar">
      <el-input
        v-model="searchQuery"
        :placeholder="searchPlaceholder ?? '검색'"
        :prefix-icon="Search"
        clearable
        style="width: 260px"
        @input="currentPage = 1"
      />
      <slot name="toolbar-right" />
    </div>

    <el-table :data="pagedData" stripe border style="width: 100%; margin-top: 12px">
      <template v-for="col in columns" :key="col.prop">
        <el-table-column
          v-if="col.type === 'index'"
          type="index"
          :label="col.label"
          :width="col.width ?? 50"
          align="center"
        />
        <el-table-column
          v-else-if="col.slot"
          :prop="col.prop"
          :label="col.label"
          :width="col.width"
          :min-width="col.minWidth"
          :align="col.align ?? 'left'"
        >
          <template #default="{ row }">
            <slot :name="col.prop" :row="row" />
          </template>
        </el-table-column>
        <el-table-column
          v-else
          :prop="col.prop"
          :label="col.label"
          :width="col.width"
          :min-width="col.minWidth"
          :align="col.align ?? 'left'"
        />
      </template>
    </el-table>

    <div class="pagination">
      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :page-sizes="pageSizes ?? [10, 20, 50]"
        :total="filteredData.length"
        layout="total, sizes, prev, pager, next"
        background
      />
    </div>
  </div>
</template>

<style scoped>
.toolbar { display: flex; justify-content: space-between; align-items: center; }
.pagination { margin-top: 16px; display: flex; justify-content: flex-end; }
</style>
