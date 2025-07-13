import type { UserInfo } from './auth'
import axiosInstance from './axios'

export const getUserInfoApi = async (): Promise<UserInfo> => {
  const { data } = await axiosInstance.get('/user/info')
  return data
}
