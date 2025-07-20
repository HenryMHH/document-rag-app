import type { Chat } from '@/stores/chat'
import axiosInstance from './axios'

export const getChatApi = async (chatID: string): Promise<Chat> => {
  const response = await axiosInstance.get(`/chat?chat_id=${chatID}`)
  return response.data
}

type PostChatApiPayload = {
  chat_id?: string
  message: string
}

type PostChatApiResponse = {
  chat_id: string
  title: string
  message: string
}

export const postChatApi = async (params: PostChatApiPayload): Promise<PostChatApiResponse> => {
  const response = await axiosInstance.post('/chat', params)
  return response.data
}
