import axios from 'axios'
import type { TableRow } from '@/stores/useSampleStore'

export interface TablePageResult {
  data: TableRow[]
  total: number
  page: number
  size: number
}

export interface TableParams {
  page: number
  size: number
  query?: string
}

interface MockResponse {
  data: TableRow[]
  total: number
  page: number
  size: number
}

// mock JSON을 axios로 가져온 뒤, 서버가 처리하는 것처럼 필터링·페이지네이션을 시뮬레이션
export async function fetchTableItems(params: TableParams): Promise<TablePageResult> {
  const res = await axios.get<MockResponse>('/mock/table-items.json')
  let rows = res.data.data

  // 검색 필터링 (name, category 대상)
  if (params.query?.trim()) {
    const q = params.query.trim().toLowerCase()
    rows = rows.filter(
      (r) =>
        r.name.toLowerCase().includes(q) ||
        r.category.toLowerCase().includes(q),
    )
  }

  const total = rows.length
  const start = (params.page - 1) * params.size
  const data = rows.slice(start, start + params.size)

  return { data, total, page: params.page, size: params.size }
}
