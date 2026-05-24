import { defineStore } from 'pinia'
import { ref } from 'vue'
import { menuService } from '@/services/menuService'
import type { Menu } from '@/types/menu'

export const useMenuStore = defineStore('menu', () => {
  const menus = ref<Menu[]>([])

  async function fetchMenus() {
    try {
      const res = await menuService.getMenus()
      menus.value = res.data.data
    } catch {
      menus.value = []
    }
  }

  return { menus, fetchMenus }
})
