import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/useAuthStore'
import type { Permission } from '@/constants/permissions'

declare module 'vue-router' {
  interface RouteMeta {
    requiresAuth?: boolean       // 로그인 필요
    requiresPermission?: Permission  // 특정 권한 필요
    requiresGuest?: boolean      // 비로그인 전용
  }
}

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
    meta: { requiresGuest: true },
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
    meta: { requiresPermission: 'NOTICE_WRITE' },
  },
  {
    path: '/community/notice/:id/edit',
    name: 'notice-edit',
    component: () => import('@/pages/community/NoticeWritePage.vue'),
    meta: { requiresPermission: 'NOTICE_WRITE' },
  },
  {
    path: '/community/notice/:id',
    name: 'notice-detail',
    component: () => import('@/pages/community/NoticeDetailPage.vue'),
  },
  {
    path: '/sample',
    name: 'sample',
    component: () => import('@/pages/sample/SamplePage.vue'),
    meta: { requiresPermission: 'SAMPLE_ACCESS' },
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: () => import('@/pages/NotFoundPage.vue'),
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach(async (to) => {
  const authStore = useAuthStore()

  // 토큰은 있지만 유저 정보가 없으면 먼저 로드 (새로고침 시 권한 확인 위해)
  if (authStore.isLoggedIn && !authStore.user) {
    await authStore.fetchUser()
  }

  if (to.meta.requiresGuest && authStore.isLoggedIn) {
    return { name: 'home' }
  }

  if (to.meta.requiresAuth && !authStore.isLoggedIn) {
    return { name: 'home' }
  }

  if (to.meta.requiresPermission && !authStore.hasPermission(to.meta.requiresPermission)) {
    return { name: 'home' }
  }
})

export default router
