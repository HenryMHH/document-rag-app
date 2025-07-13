import type { UserInfo } from '@/apis/auth'
import { defineStore } from 'pinia'

type AuthStoreState = {
  user: UserInfo | null
  accessToken: string | null
}

export const useAuthStore = defineStore('auth', {
  state: (): AuthStoreState => ({
    accessToken: null,
    user: null,
  }),
  actions: {
    setAccessToken(accessToken: string) {
      this.accessToken = accessToken
    },
    setUser(user: UserInfo) {
      this.user = user
    },
    logout() {
      this.accessToken = null
      this.user = null
    },
  },
})
