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
    const errorData = error.response.data
    const errorCode = errorData?.code

    if (
      error.response?.status === 401 &&
      errorCode === 'ACCESS_TOKEN_EXPIRED' &&
      !originalRequest._retry
    ) {
      originalRequest._retry = true

      try {
        const { data } = await axios.post(`${apiBaseURL}/api/v1/auth/refresh`, null, {
          withCredentials: true,
        })

        const authStore = useAuthStore()
        authStore.setAccessToken(data.access_token)
        originalRequest.headers.Authorization = `Bearer ${data.access_token}`
        return axiosInstance(originalRequest)
      } catch (refreshError: any) {
        handleLogout()
        return Promise.reject(refreshError)
      }
    }

    console.log('error=', error)

    return Promise.reject(error)
  },
)

// Helper function to handle logout
function handleLogout() {
  const authStore = useAuthStore()
  authStore.logout()

  // Only redirect if we're not already on the login page
  if (window.location.pathname !== '/') {
    const router = useRouter()
    router.push('/')
  }
}

export default axiosInstance
