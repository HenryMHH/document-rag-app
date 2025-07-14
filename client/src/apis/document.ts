import axiosInstance from './axios'

export interface Document {
  id: number // 修正：改為 number
  title: string
  original_filename: string
  file_type: string
  total_pages: number
  created_at?: string // 新增：創建時間
  updated_at?: string // 新增：更新時間
}

export const getDocumentsApi = async (): Promise<Document[]> => {
  try {
    const { data } = await axiosInstance.get('/document/all')

    // 如果 API 返回的是包裝在 documents 屬性中的數據
    const documents = Array.isArray(data) ? data : data.documents || []

    return documents as Document[]
  } catch (error) {
    console.error('Error fetching documents:', error)
    return []
  }
}

export const createDocumentApi = async (file: File) => {
  const formData = new FormData()
  formData.append('file', file)

  const { data } = await axiosInstance.post('/document/create', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  })

  return data
}
