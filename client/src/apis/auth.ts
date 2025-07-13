import axiosInstance from './axios'

export type UserInfo = {
  id: number
  name: string
  email: string
  avatar_url: string
  role: 'user' | 'admin'
}

type LoginResponse = {
  message: string
  user: UserInfo
  access_token: string
}

export const loginWithGoogleApi = async (code: string) => {
  const response = await axiosInstance<LoginResponse>('/auth/google', {
    method: 'POST',
    data: {
      code,
    },
  })

  return response.data
}
