export interface NoticeListItem {
  id: number
  title: string
  authorName: string
  isPinned: boolean
  viewCount: number
  createdAt: string
}

export interface Notice {
  id: number
  title: string
  content: string
  authorId: number
  authorName: string
  isPinned: boolean
  viewCount: number
  createdAt: string
  updatedAt: string
}

export interface NoticeListResponse {
  list: NoticeListItem[]
  total: number
  page: number
  size: number
}

export interface NoticeRequest {
  title: string
  content: string
  isPinned: boolean
}
