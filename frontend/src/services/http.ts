import axios from 'axios'
import { useAuthStore } from '@/stores/useAuthStore'
import { useLoadingStore } from '@/stores/useLoadingStore'

const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 10000,
})

let isRefreshing = false
let pendingRequests: Array<(token: string) => void> = []

function processPending(token: string) {
  pendingRequests.forEach(cb => cb(token))
  pendingRequests = []
}

http.interceptors.request.use((config) => {
  const authStore = useAuthStore()
  const loadingStore = useLoadingStore()
  if (authStore.token) {
    config.headers.Authorization = `Bearer ${authStore.token}`
  }
  loadingStore.start()
  return config
})

http.interceptors.response.use(
  (response) => {
    useLoadingStore().done()
    return response
  },
  async (error) => {
    useLoadingStore().done()
    const originalRequest = error.config
    const authStore = useAuthStore()

    if (error.response?.status === 401 && !originalRequest._retry) {
      if (!authStore.refreshToken) {
        authStore.clearSession()
        return Promise.reject(error)
      }

      if (isRefreshing) {
        return new Promise((resolve) => {
          pendingRequests.push((token) => {
            originalRequest.headers.Authorization = `Bearer ${token}`
            resolve(http(originalRequest))
          })
        })
      }

      originalRequest._retry = true
      isRefreshing = true

      try {
        const res = await axios.post(
          `${import.meta.env.VITE_API_BASE_URL}/auth/refresh`,
          { refreshToken: authStore.refreshToken },
        )
        const { accessToken, refreshToken } = res.data.data
        authStore.setTokens(accessToken, refreshToken)
        processPending(accessToken)
        originalRequest.headers.Authorization = `Bearer ${accessToken}`
        return http(originalRequest)
      } catch {
        authStore.clearSession()
        return Promise.reject(error)
      } finally {
        isRefreshing = false
      }
    }

    return Promise.reject(error)
  },
)

export default http
