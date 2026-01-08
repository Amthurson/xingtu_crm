import axios from 'axios'

const api = axios.create({
  baseURL: '/api',
  timeout: 10000
})

// 达人管理API
export const influencerApi = {
  // 获取达人列表
  getList(params) {
    return api.get('/influencers/', { params })
  },
  
  // 获取达人详情
  getDetail(id) {
    return api.get(`/influencers/${id}`)
  },
  
  // 创建达人
  create(data) {
    return api.post('/influencers/', data)
  },
  
  // 更新达人
  update(id, data) {
    return api.put(`/influencers/${id}`, data)
  },
  
  // 删除达人
  delete(id) {
    return api.delete(`/influencers/${id}`)
  },
  
  // 导入Excel
  importExcel(file) {
    const formData = new FormData()
    formData.append('file', file)
    return api.post('/import/excel', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
  },
  
  // 下载模板
  downloadTemplate() {
    return api.get('/import/template', {
      responseType: 'blob'
    })
  }
}


