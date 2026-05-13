import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/useAuthStore'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'home',
    component: () => import('@/pages/HomePage.vue'),
  },
  {
    path: '/auth/callback',
    name: 'auth-callback',
    component: () => import('@/pages/AuthCallbackPage.vue'),
  },
  {
    path: '/community/notice',
    name: 'notice-list',
    component: () => import('@/pages/community/NoticeListPage.vue'),
  },
  {
    path: '/community/notice/write',
    name: 'notice-write',
    component: () => import('@/pages/community/NoticeWritePage.vue'),
    meta: { requiresAdmin: true },
  },
  {
    path: '/community/notice/:id/edit',
    name: 'notice-edit',
    component: () => import('@/pages/community/NoticeWritePage.vue'),
    meta: { requiresAdmin: true },
  },
  {
    path: '/community/notice/:id',
    name: 'notice-detail',
    component: () => import('@/pages/community/NoticeDetailPage.vue'),
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to) => {
  if (to.meta.requiresAdmin) {
    const authStore = useAuthStore()
    if (!authStore.isAdmin) {
      return { name: 'home' }
    }
  }
})

export default router
