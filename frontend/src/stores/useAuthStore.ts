import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User } from '@/types/auth'
import http from '@/services/http'

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(localStorage.getItem('token'))
  const refreshToken = ref<string | null>(localStorage.getItem('refreshToken'))
  const user = ref<User | null>(null)

  const isLoggedIn = computed(() => !!token.value)
  const isAdmin = computed(() => user.value?.role === 'ADMIN')

  function setTokens(accessToken: string, newRefreshToken: string) {
    token.value = accessToken
    refreshToken.value = newRefreshToken
    localStorage.setItem('token', accessToken)
    localStorage.setItem('refreshToken', newRefreshToken)
  }

  function clearSession() {
    token.value = null
    refreshToken.value = null
    user.value = null
    localStorage.removeItem('token')
    localStorage.removeItem('refreshToken')
  }

  async function logout() {
    try {
      if (token.value) {
        await http.post('/auth/logout')
      }
    } catch {
      // ignore
    } finally {
      clearSession()
    }
  }

  async function fetchUser() {
    if (!token.value) return
    try {
      const res = await http.get<{ data: User }>('/auth/me')
      user.value = res.data.data
    } catch {
      // 401은 response interceptor가 처리
    }
  }

  function loginWithGoogle() {
    window.location.href = `${import.meta.env.VITE_BACKEND_URL}/oauth2/authorization/google`
  }

  return { token, refreshToken, user, isLoggedIn, isAdmin, setTokens, clearSession, logout, fetchUser, loginWithGoogle }
})
