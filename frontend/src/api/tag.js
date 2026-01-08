import axios from 'axios'

const api = axios.create({
  baseURL: '/api',
  timeout: 10000
})

// 标签管理API
export const tagApi = {
  // 获取标签列表（支持搜索）
  getList(params) {
    return api.get('/tags/', { params })
  },
  
  // 获取标签详情
  getDetail(id) {
    return api.get(`/tags/${id}`)
  },
  
  // 创建标签
  create(data) {
    return api.post('/tags/', data)
  },
  
  // 批量创建标签
  createBulk(tagNames) {
    return api.post('/tags/bulk', tagNames)
  },
  
  // 更新标签
  update(id, data) {
    return api.put(`/tags/${id}`, data)
  },
  
  // 删除标签
  delete(id) {
    return api.delete(`/tags/${id}`)
  }
}

