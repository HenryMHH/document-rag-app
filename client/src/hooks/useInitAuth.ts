import { getUserInfoApi } from '@/apis/user'
import { useAuthStore } from '@/stores/auth'
import { onMounted, ref } from 'vue'

export const useInitAuth = () => {
  const isInitialized = ref(false)

  try {
    onMounted(async () => {
      const authStore = useAuthStore()
      const isLoggedIn = !!authStore.accessToken

      if (!isLoggedIn) {
        const user = await getUserInfoApi()
        authStore.setUser(user)
      }
    })
  } catch (error) {
    console.log(error)
  } finally {
    isInitialized.value = true
  }

  return {
    isInitialized,
  }
}
