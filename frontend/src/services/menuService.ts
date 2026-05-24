import http from './http'
import type { Menu } from '@/types/menu'

interface ApiResponse<T> {
  success: boolean
  message: string
  data: T
}

export const menuService = {
  getMenus() {
    return http.get<ApiResponse<Menu[]>>('/menus')
  },
}
