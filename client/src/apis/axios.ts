import { useAuthStore } from '@/stores/auth'
import axios from 'axios'
import { useRouter } from 'vue-router'

const currentEnv = import.meta.env.VITE_ENV || 'development'

const apiBaseURL = currentEnv === 'development' ? 'http://localhost:3000' : 'https://lt-agent.com'

// 1. 創建一個 Axios 實例
const axiosInstance = axios.create({
  baseURL: `${apiBaseURL}/api/v1`,
  withCredentials: true,
})

axiosInstance.interceptors.request.use(
  (config) => {
    const authStore = useAuthStore()

    if (authStore.accessToken) {
      config.headers.Authorization = `Bearer ${authStore.accessToken}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  },
)

axiosInstance.interceptors.response.use(
  (response) => {
    return response
  },
  async (error) => {
    const originalRequest = error.config

    if (error.response.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true

      try {
        const authStore = useAuthStore()

        const { data } = await axios.post(`${apiBaseURL}/api/v1/auth/refresh`, null, {
          withCredentials: true,
        })
        authStore.setAccessToken(data.access_token)

        return axiosInstance(originalRequest)
      } catch (refreshError) {
        console.error('Failed to refresh token:', refreshError)
        const authStore = useAuthStore()
        authStore.logout()

        const router = useRouter()
        router.push('/login')
        return Promise.reject(refreshError)
      }
    }

    return Promise.reject(error)
  },
)

export default axiosInstance
