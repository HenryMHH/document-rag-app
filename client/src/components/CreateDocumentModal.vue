<script setup lang="ts">
import { toTypedSchema } from '@vee-validate/zod'
import { ref } from 'vue'
import * as z from 'zod'
import { createDocumentApi } from '@/apis/document'

import { Button } from '@/components/ui/button'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { toast } from 'vue-sonner'

// 修正：更簡單的驗證 schema
const formSchema = toTypedSchema(
  z.object({
    file: z
      .any()
      .refine((value) => {
        // 檢查是否為 FileList 或 File
        if (value instanceof FileList) {
          return value.length > 0
        }
        if (value instanceof File) {
          return true
        }
        return false
      }, '請選擇一個文件')
      .refine((value) => {
        const file = value instanceof FileList ? value[0] : value
        return file?.type === 'application/pdf'
      }, '請上傳 PDF 文件')
      .refine((value) => {
        const file = value instanceof FileList ? value[0] : value
        return file?.size <= 10 * 1024 * 1024
      }, '文件大小不能超過 10MB'),
  }),
)

const isUploading = ref(false)
const dialogOpen = ref(false)

// 定義事件
const emit = defineEmits<{
  documentCreated: [document: any]
}>()

// 修正：完整的上傳邏輯
async function onSubmit(values: any) {
  try {
    isUploading.value = true

    console.log('Form values:', values)

    // 提取文件
    const file = values.file instanceof FileList ? values.file[0] : values.file

    if (!file) {
      throw new Error('沒有選擇文件')
    }

    console.log('Uploading file:', file.name)

    // 調用 API
    const response = await createDocumentApi(file)

    console.log(response)

    toast({
      title: '上傳成功！',
      description: `文件 "${file.name}" 已成功上傳`,
    })

    // 發送事件給父組件
    emit('documentCreated', response)

    // 關閉對話框
    dialogOpen.value = false
  } catch (error: any) {
    console.error('Upload error:', error)
    toast({
      title: '上傳失敗',
      description: error.response?.data?.error || error.message || '文件上傳時發生錯誤',
    })
  } finally {
    isUploading.value = false
  }
}
</script>

<template>
  <Form v-slot="{ handleSubmit, resetForm }" :validation-schema="formSchema">
    <Dialog v-model:open="dialogOpen" @update:open="(open) => !open && resetForm()">
      <DialogTrigger as-child>
        <Button variant="outline">上傳文檔</Button>
      </DialogTrigger>
      <DialogContent class="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>上傳文檔</DialogTitle>
          <DialogDescription>
            請選擇要上傳的 PDF 文件。文件上傳後會自動進行處理和索引。
          </DialogDescription>
        </DialogHeader>

        <form @submit.prevent="handleSubmit(onSubmit)">
          <FormField v-slot="{ componentField }" name="file">
            <FormItem>
              <FormLabel>選擇文件</FormLabel>
              <FormControl>
                <!-- 修正：正確處理文件輸入 -->
                <Input
                  type="file"
                  accept="application/pdf,.pdf"
                  :disabled="isUploading"
                  @change="
                    (event: Event) => {
                      const target = event.target as HTMLInputElement
                      const files = target.files
                      if (files && files.length > 0) {
                        componentField.onInput(files[0])
                      }
                    }
                  "
                />
              </FormControl>
              <FormDescription> 支援 PDF 格式，文件大小不超過 10MB </FormDescription>
              <FormMessage />
            </FormItem>
          </FormField>

          <DialogFooter class="mt-4">
            <Button type="submit" :disabled="isUploading">
              <span v-if="isUploading">上傳中...</span>
              <span v-else>上傳文檔</span>
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  </Form>
</template>
