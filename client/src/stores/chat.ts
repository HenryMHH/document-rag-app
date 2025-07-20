import { getChatApi, postChatApi } from '@/apis/chat'
import { defineStore } from 'pinia'

export type Chat = {
  id: string
  title: string
  messages: Message[]
}

export type Message = {
  id: string
  content: string
  role: 'user' | 'assistant'
}

type ChatStoreState = {
  chat: Chat
}

export const useChatStore = defineStore('chat', {
  state: (): ChatStoreState => ({
    chat: {
      id: '',
      title: '',
      messages: [],
    },
  }),
  actions: {
    async getChatHistory(chatID: string) {
      const response = await getChatApi(chatID)
      this.chat = response
    },

    async postChat({ message, chatID }: { message: string; chatID?: string }) {
      this.chat = {
        ...this.chat,
        messages: [
          ...this.chat.messages,
          {
            id: crypto.randomUUID(),
            content: message,
            role: 'user',
          },
        ],
      }

      const response = await postChatApi({
        message,
        chat_id: chatID,
      })

      this.chat = {
        id: response.chat_id,
        title: response.title,
        messages: [
          ...this.chat.messages,
          {
            id: response.chat_id,
            content: response.message,
            role: 'assistant',
          },
        ],
      }
    },
  },
})
