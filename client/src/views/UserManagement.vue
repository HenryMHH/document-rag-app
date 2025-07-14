<script setup lang="ts">
import { onMounted, ref } from 'vue'
import UserTable from '@/components/UserTable.vue'
import { getUsersApi } from '@/apis/user'
import type { UserInfo } from '@/apis/auth'

const users = ref<UserInfo[]>([])
const isLoading = ref(false)
const error = ref<string | null>(null)

const loadUsers = async () => {
  try {
    isLoading.value = true
    error.value = null
    console.log('Loading users...')

    const usersData = await getUsersApi()
    console.log('Users loaded:', usersData)

    users.value = usersData
  } catch (err: any) {
    console.error('Error loading users:', err)
    error.value = err.message || 'Failed to load users'
  } finally {
    isLoading.value = false
  }
}

onMounted(() => {
  loadUsers()
})
</script>

<template>
  <div class="space-y-4">
    <h1 class="text-2xl font-bold">User Management</h1>

    <!-- 調試信息 -->
    <div class="text-sm text-gray-500">
      Users count: {{ users.length }} | Loading: {{ isLoading }}
    </div>

    <!-- 錯誤顯示 -->
    <div v-if="error" class="text-red-500 p-4 border border-red-200 rounded">
      Error: {{ error }}
      <button @click="loadUsers" class="ml-2 underline">Retry</button>
    </div>

    <!-- 加載狀態 -->
    <div v-if="isLoading" class="text-center py-8">Loading users...</div>

    <!-- 用戶表格 -->
    <UserTable v-else :users="users" />
  </div>
</template>
