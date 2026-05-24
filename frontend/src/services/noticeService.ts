import http from './http'
import type { Notice, NoticeListResponse, NoticeRequest } from '@/types/notice'

interface ApiResponse<T> {
  success: boolean
  message: string
  data: T
}

export const noticeService = {
  getList(page = 1, size = 10, sortBy = 'createdAt', sortOrder = 'desc') {
    return http.get<ApiResponse<NoticeListResponse>>('/community/notices', {
      params: { page, size, sortBy, sortOrder },
    })
  },
  getOne(id: number) {
    return http.get<ApiResponse<Notice>>(`/community/notices/${id}`)
  },
  create(req: NoticeRequest) {
    return http.post<ApiResponse<Notice>>('/community/notices', req)
  },
  update(id: number, req: NoticeRequest) {
    return http.put<ApiResponse<Notice>>(`/community/notices/${id}`, req)
  },
  delete(id: number) {
    return http.delete(`/community/notices/${id}`)
  },
}
