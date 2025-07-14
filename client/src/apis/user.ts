import type { UserInfo } from './auth'
import axiosInstance from './axios'

export const getUserInfoApi = async (): Promise<UserInfo> => {
  const { data } = await axiosInstance.get('/user/info')
  return data
}

export const getUsersApi = async (): Promise<UserInfo[]> => {
  console.log('test')
  const { data } = await axiosInstance.get('/user/all')
  return data
}
