<script setup lang="ts">
import { ref, onMounted } from 'vue'
import CreateDocumentModal from '@/components/CreateDocumentModal.vue'
import { getDocumentsApi, type Document } from '@/apis/document'
import DocumentTable from '@/components/DocumentTable.vue'

const documents = ref<Document[]>([])
const isLoading = ref(false)
const error = ref<string | null>(null)

const loadDocuments = async () => {
  try {
    isLoading.value = true
    error.value = null
    console.log('Loading documents...')

    const result = await getDocumentsApi()
    console.log('Documents loaded:', result)

    documents.value = result
  } catch (err: any) {
    console.error('Error loading documents:', err)
    error.value = err.message || 'Failed to load documents'
  } finally {
    isLoading.value = false
  }
}

onMounted(() => {
  loadDocuments()
})

// 處理文檔創建成功後重新載入列表
const handleDocumentCreated = () => {
  loadDocuments()
}
</script>

<template>
  <div class="space-y-4">
    <div class="flex justify-between items-center">
      <h1 class="text-2xl font-bold">Documentation</h1>
      <CreateDocumentModal @document-created="handleDocumentCreated" />
    </div>

    <!-- 調試信息 -->
    <div class="text-sm text-gray-500">
      Documents count: {{ documents.length }} | Loading: {{ isLoading }}
    </div>

    <!-- 錯誤顯示 -->
    <div v-if="error" class="text-red-500 p-4 border border-red-200 rounded">
      Error: {{ error }}
      <button @click="loadDocuments" class="ml-2 underline">Retry</button>
    </div>

    <!-- 加載狀態 -->
    <div v-if="isLoading" class="text-center py-8">Loading documents...</div>

    <!-- 文檔表格 -->
    <DocumentTable v-else :documents="documents" />
  </div>
</template>
