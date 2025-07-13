<script setup lang="ts">
import LoginForm from '@/components/LoginForm.vue'
import { GalleryVerticalEnd } from 'lucide-vue-next'
import { loginWithGoogleApi } from '@/apis/auth'
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'

type GoogleResponse = {
  code: string
  scope: string
}

const router = useRouter()

const handleLoginSuccess = async (googleResponse: GoogleResponse) => {
  try {
    const { code } = googleResponse
    console.log('code', code)
    const response = await loginWithGoogleApi(code)

    const { user, access_token } = response
    const authStore = useAuthStore()

    authStore.setUser(user)
    authStore.setAccessToken(access_token)

    if (user.role === 'admin') {
      router.push('/dashboard')
    } else {
      router.push('/')
    }
  } catch (error) {
    console.log('error', error)
  }
}
</script>

<template>
  <div class="flex min-h-svh flex-col items-center justify-center gap-6 bg-muted p-6 md:p-10">
    <div class="flex w-full max-w-sm flex-col gap-6">
      <a href="#" class="flex items-center gap-2 self-center font-medium">
        <div
          class="flex h-6 w-6 items-center justify-center rounded-md bg-primary text-primary-foreground"
        >
          <GalleryVerticalEnd class="size-4" />
        </div>
        Legal Template Agent
      </a>
      <LoginForm @on-login-success="handleLoginSuccess" />
    </div>
  </div>
</template>
