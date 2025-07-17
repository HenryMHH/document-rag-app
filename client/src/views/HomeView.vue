<script setup lang="ts">
import { ref, nextTick, onMounted } from 'vue'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Textarea } from '@/components/ui/textarea'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Separator } from '@/components/ui/separator'

interface Message {
  id: string
  content: string
  role: 'user' | 'assistant'
  timestamp: Date
}

const messages = ref<Message[]>([
  {
    id: '1',
    content: '您好！我是您的 AI 助手，有什麼可以幫助您的嗎？',
    role: 'assistant',
    timestamp: new Date(),
  },
])

const userInput = ref('')
const isLoading = ref(false)
const chatContainer = ref<HTMLElement>()

// 模擬 AI 回覆的函數（後續會替換成真實 API 調用）
const simulateAIResponse = (userMessage: string): string => {
  const responses = [
    `感謝您的問題："${userMessage}"。這是一個模擬回覆，後續會接入真實的 AI API。`,
    `我理解您想了解關於"${userMessage}"的信息。目前正在建置向量語意比對功能，敬請期待！`,
    `關於"${userMessage}"，我會在 function calling 功能完成後提供更準確的回答。`,
    `您提到的"${userMessage}"很有趣！一旦後端 RAG 系統完成，我就能給您更詳細的回覆。`,
  ]
  return responses[Math.floor(Math.random() * responses.length)]
}

const sendMessage = async () => {
  if (!userInput.value.trim() || isLoading.value) return

  const userMessage = userInput.value.trim()
  const messageId = Date.now().toString()

  // 添加用戶訊息
  messages.value.push({
    id: messageId,
    content: userMessage,
    role: 'user',
    timestamp: new Date(),
  })

  userInput.value = ''
  isLoading.value = true

  // 滾動到底部
  await nextTick()
  scrollToBottom()

  // 模擬 API 調用延遲
  await new Promise((resolve) => setTimeout(resolve, 1000 + Math.random() * 2000))

  // 添加 AI 回覆
  const aiResponse = simulateAIResponse(userMessage)
  messages.value.push({
    id: `${messageId}-response`,
    content: aiResponse,
    role: 'assistant',
    timestamp: new Date(),
  })

  isLoading.value = false
  await nextTick()
  scrollToBottom()
}

const scrollToBottom = () => {
  if (chatContainer.value) {
    chatContainer.value.scrollTop = chatContainer.value.scrollHeight
  }
}

const handleKeyPress = (event: KeyboardEvent) => {
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault()
    sendMessage()
  }
}

const formatTime = (date: Date) => {
  return date.toLocaleTimeString('zh-TW', {
    hour: '2-digit',
    minute: '2-digit',
  })
}

onMounted(() => {
  scrollToBottom()
})
</script>

<template>
  <div class="h-screen flex flex-col bg-gray-50 dark:bg-gray-900">
    <!-- Header -->
    <Card class="rounded-none border-x-0 border-t-0">
      <CardHeader class="py-4">
        <CardTitle class="text-center text-xl font-semibold"> AI 助手 </CardTitle>
      </CardHeader>
    </Card>

    <!-- Chat Messages Area -->
    <div ref="chatContainer" class="flex-1 overflow-y-auto p-4 space-y-4">
      <div
        v-for="message in messages"
        :key="message.id"
        class="flex gap-3"
        :class="message.role === 'user' ? 'justify-end' : 'justify-start'"
      >
        <!-- AI Avatar (left side) -->
        <Avatar v-if="message.role === 'assistant'" class="w-8 h-8 mt-1">
          <AvatarFallback class="bg-blue-500 text-white text-sm"> AI </AvatarFallback>
        </Avatar>

        <!-- Message Content -->
        <div class="max-w-[70%] group" :class="message.role === 'user' ? 'order-1' : 'order-2'">
          <Card
            class="shadow-sm"
            :class="
              message.role === 'user'
                ? 'bg-blue-500 text-white border-blue-500'
                : 'bg-white dark:bg-gray-800'
            "
          >
            <CardContent class="p-3">
              <p class="whitespace-pre-wrap break-words">
                {{ message.content }}
              </p>
              <div
                class="text-xs mt-2 opacity-70"
                :class="message.role === 'user' ? 'text-blue-100' : 'text-gray-500'"
              >
                {{ formatTime(message.timestamp) }}
              </div>
            </CardContent>
          </Card>
        </div>

        <!-- User Avatar (right side) -->
        <Avatar v-if="message.role === 'user'" class="w-8 h-8 mt-1 order-2">
          <AvatarFallback class="bg-green-500 text-white text-sm"> 我 </AvatarFallback>
        </Avatar>
      </div>

      <!-- Loading Indicator -->
      <div v-if="isLoading" class="flex gap-3 justify-start">
        <Avatar class="w-8 h-8 mt-1">
          <AvatarFallback class="bg-blue-500 text-white text-sm"> AI </AvatarFallback>
        </Avatar>
        <Card class="max-w-[70%] bg-white dark:bg-gray-800 shadow-sm">
          <CardContent class="p-3">
            <div class="flex items-center space-x-2">
              <div class="flex space-x-1">
                <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                <div
                  class="w-2 h-2 bg-gray-400 rounded-full animate-bounce"
                  style="animation-delay: 0.1s"
                ></div>
                <div
                  class="w-2 h-2 bg-gray-400 rounded-full animate-bounce"
                  style="animation-delay: 0.2s"
                ></div>
              </div>
              <span class="text-sm text-gray-500">AI 正在思考中...</span>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>

    <Separator />

    <!-- Input Area -->
    <Card class="rounded-none border-x-0 border-b-0">
      <CardContent class="p-4">
        <div class="flex gap-3 items-end">
          <div class="flex-1">
            <Textarea
              v-model="userInput"
              placeholder="輸入您的問題..."
              class="min-h-[60px] max-h-[120px] resize-none"
              :disabled="isLoading"
              @keypress="handleKeyPress"
            />
          </div>
          <Button
            @click="sendMessage"
            :disabled="!userInput.trim() || isLoading"
            class="px-6 py-3 h-auto"
          >
            <svg
              v-if="!isLoading"
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            >
              <path d="m22 2-7 20-4-9-9-4Z" />
              <path d="M22 2 11 13" />
            </svg>
            <div
              v-else
              class="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"
            ></div>
          </Button>
        </div>

        <!-- Help Text -->
        <div class="text-xs text-gray-500 mt-2 text-center">按 Enter 發送，Shift + Enter 換行</div>
      </CardContent>
    </Card>
  </div>
</template>
