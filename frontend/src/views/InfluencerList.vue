<template>
  <div class="influencer-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span class="page-title">达人信息</span>
          <div>
            <el-button type="primary" @click="handleDownloadTemplate">
              <el-icon><Download /></el-icon>
              下载模板
            </el-button>
            <el-button type="success" @click="handleImport">
              <el-icon><Upload /></el-icon>
              导入Excel
            </el-button>
            <el-button type="primary" @click="handleAdd">
              <el-icon><Plus /></el-icon>
              新增达人
            </el-button>
          </div>
        </div>
      </template>

      <!-- 搜索栏 -->
      <div class="search-bar">
        <el-input
          v-model="searchText"
          placeholder="搜索达人姓名、城市、类型..."
          style="width: 300px"
          clearable
          @clear="handleSearch"
          @keyup.enter="handleSearch"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </div>

      <!-- 数据表格 -->
      <el-table
        v-loading="loading"
        :data="tableData"
        stripe
        class="influencer-table"
        style="width: 100%; margin-top: 20px"
        @sort-change="handleSortChange"
      >
        <el-table-column prop="name" label="达人信息" min-width="280">
          <template #default="{ row }">
            <div class="influencer-info">
              <div class="info-main">
                <el-avatar 
                  :size="48" 
                  :src="row.avatar_url"
                  class="avatar"
                >
                  <span class="avatar-text">{{ getInitials(row.name) }}</span>
                </el-avatar>
                <div class="info-content">
                  <div class="name-row">
                    <span class="name">{{ row.name }}</span>
                    <span v-if="row.gender === '男'" class="gender-icon male">
                      <el-icon><Male /></el-icon>
                    </span>
                    <span v-else-if="row.gender === '女'" class="gender-icon female">
                      <el-icon><Female /></el-icon>
                    </span>
                    <span v-if="row.city" class="location-icon">
                      <el-icon><Location /></el-icon>
                      <span class="city">{{ row.city }}</span>
                    </span>
                  </div>
                  <div v-if="row.platform_tags" class="platform-tags">
                    <el-tag 
                      v-for="(tag, index) in getPlatformTags(row.platform_tags)" 
                      :key="index"
                      size="small" 
                      class="platform-tag"
                    >
                      {{ tag }}
                    </el-tag>
                  </div>
                  <div v-if="row.ranking_info" class="ranking-badge">
                    {{ row.ranking_info }}
                  </div>
                  <div v-if="row.tags && row.tags.length > 0" class="influencer-tags">
                    <el-tag 
                      v-for="tag in row.tags" 
                      :key="tag.id"
                      size="small" 
                      class="influencer-tag"
                      :style="tag.color ? { color: tag.color } : {}"
                    >
                      {{ tag.name }}
                    </el-tag>
                  </div>
                </div>
              </div>
            </div>
          </template>
        </el-table-column>

        <el-table-column label="代表视频" min-width="160">
          <template #default="{ row }">
            <div class="video-thumbnails">
              <div class="video-thumb" v-for="i in 2" :key="i">
                <el-image
                  :src="row.video_thumbnails && row.video_thumbnails[i-1]"
                  fit="cover"
                  class="thumbnail"
                >
                  <template #error>
                    <div class="thumbnail-placeholder">
                      <el-icon><VideoPlay /></el-icon>
                    </div>
                  </template>
                </el-image>
              </div>
            </div>
          </template>
        </el-table-column>

        <el-table-column label="达人类型" min-width="180">
          <template #default="{ row }">
            <div class="type-tags">
              <el-tag 
                v-for="(type, index) in getTypeTags(row.influencer_type)" 
                :key="index"
                size="small" 
                class="type-tag"
              >
                {{ type }}
              </el-tag>
            </div>
          </template>
        </el-table-column>

        <el-table-column label="内容主题" min-width="200">
          <template #default="{ row }">
            <div class="theme-tags">
              <el-tag 
                v-for="(theme, index) in getThemeTags(row.content_theme)" 
                :key="index"
                size="small" 
                class="theme-tag"
              >
                {{ theme }}
              </el-tag>
              <span v-if="row.age_rating" class="age-rating">{{ row.age_rating }}+ ></span>
            </div>
          </template>
        </el-table-column>

        <el-table-column 
          prop="connected_users" 
          label="连接用户数" 
          min-width="140" 
          align="center"
          sortable="custom"
          :sort-orders="['ascending', 'descending', null]"
        >
          <template #default="{ row }">
            <span class="number-large">{{ formatNumberWithCommas(row.connected_users) }}</span>
          </template>
        </el-table-column>

        <el-table-column 
          prop="follower_count" 
          label="粉丝数" 
          min-width="140" 
          align="center"
          sortable="custom"
          :sort-orders="['ascending', 'descending', null]"
        >
          <template #default="{ row }">
            <span class="number-large">{{ formatNumberWithCommas(row.follower_count) }}</span>
          </template>
        </el-table-column>

        <el-table-column 
          prop="expected_cpm" 
          label="预期CPM" 
          min-width="120" 
          align="center"
          sortable="custom"
          :sort-orders="['ascending', 'descending', null]"
        >
          <template #default="{ row }">
            <span v-if="row.expected_cpm">{{ row.expected_cpm }}</span>
            <span v-else>-</span>
          </template>
        </el-table-column>

        <el-table-column 
          prop="quote_21_60s" 
          label="21-60s报价" 
          min-width="180" 
          align="center"
          sortable="custom"
          :sort-orders="['ascending', 'descending', null]"
        >
          <template #default="{ row }">
            <div class="quote-content">
              <span v-if="row.quote_21_60s" class="quote-price">¥{{ formatNumberWithCommas(row.quote_21_60s) }}</span>
              <span v-else>-</span>
              <div v-if="row.quote_note" class="quote-note">{{ row.quote_note }}</div>
            </div>
          </template>
        </el-table-column>

        <el-table-column label="操作" min-width="200" fixed="right">
          <template #default="{ row }">
            <div class="operation-buttons">
              <el-button 
                circle 
                size="small" 
                class="action-btn"
                @click="handleEdit(row)"
                title="编辑"
              >
                <el-icon><Edit /></el-icon>
              </el-button>
              <el-button 
                circle 
                size="small" 
                class="action-btn"
                @click="handleView(row)"
                title="查看详情"
              >
                <el-icon><Document /></el-icon>
              </el-button>
              <el-button 
                circle 
                size="small" 
                class="action-btn delete-btn"
                @click="handleDelete(row)"
                title="删除"
              >
                <el-icon><Delete /></el-icon>
              </el-button>
              <el-button 
                circle 
                size="small" 
                class="action-btn"
                @click="handleMore(row)"
                title="更多操作"
              >
                <el-icon><MoreFilled /></el-icon>
              </el-button>
            </div>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.size"
          :page-sizes="[10, 20, 50, 100]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="800px"
      @close="handleDialogClose"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="120px"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="姓名/昵称" prop="name">
              <el-input v-model="formData.name" placeholder="请输入姓名或昵称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="性别" prop="gender">
              <el-select v-model="formData.gender" placeholder="请选择性别" style="width: 100%">
                <el-option label="男" value="男" />
                <el-option label="女" value="女" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="所在城市" prop="city">
              <el-input v-model="formData.city" placeholder="请输入城市" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="平台标签" prop="platform_tags">
              <el-input v-model="formData.platform_tags" placeholder="如：抖音精选、繁星企划" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="达人类型" prop="influencer_type">
              <el-input v-model="formData.influencer_type" placeholder="如：美食、美妆" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="内容主题" prop="content_theme">
              <el-input v-model="formData.content_theme" placeholder="如：美食探店" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="连接用户数" prop="connected_users">
              <el-input-number
                v-model="formData.connected_users"
                :min="0"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="粉丝数" prop="follower_count">
              <el-input-number
                v-model="formData.follower_count"
                :min="0"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="预期CPM" prop="expected_cpm">
              <el-input-number
                v-model="formData.expected_cpm"
                :min="0"
                :precision="2"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="21-60s报价" prop="quote_21_60s">
              <el-input-number
                v-model="formData.quote_21_60s"
                :min="0"
                :precision="2"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="抖音ID" prop="douyin_id">
              <el-input v-model="formData.douyin_id" placeholder="请输入抖音ID" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="小红书ID" prop="xiaohongshu_id">
              <el-input v-model="formData.xiaohongshu_id" placeholder="请输入小红书ID" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="标签" prop="tags">
          <el-select
            v-model="selectedTagValues"
            multiple
            filterable
            allow-create
            default-first-option
            :reserve-keyword="false"
            placeholder="选择或输入标签"
            style="width: 100%"
            @change="handleTagChange"
          >
            <el-option
              v-for="tag in availableTags"
              :key="tag.id"
              :label="tag.name"
              :value="tag.name"
            >
              {{ tag.name }}
            </el-option>
          </el-select>
          <div class="tag-hint">
            <span>支持搜索历史标签，或手动输入新建标签</span>
          </div>
        </el-form-item>

        <el-form-item label="报价备注" prop="quote_note">
          <el-input
            v-model="formData.quote_note"
            type="textarea"
            :rows="3"
            placeholder="请输入报价备注"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">
          确定
        </el-button>
      </template>
    </el-dialog>

    <!-- 导入对话框 -->
    <el-dialog v-model="importDialogVisible" title="导入Excel" width="500px">
      <el-upload
        ref="uploadRef"
        :auto-upload="false"
        :on-change="handleFileChange"
        :limit="1"
        accept=".xlsx,.xls"
        drag
      >
        <el-icon class="el-icon--upload"><upload-filled /></el-icon>
        <div class="el-upload__text">
          将文件拖到此处，或<em>点击上传</em>
        </div>
        <template #tip>
          <div class="el-upload__tip">
            只能上传 xlsx/xls 文件
          </div>
        </template>
      </el-upload>
      <template #footer>
        <el-button @click="importDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleUpload" :loading="uploading">
          导入
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  Search, Plus, Upload, Download, UploadFilled, 
  Male, Female, Location, VideoPlay, MoreFilled, 
  Document, Edit, Delete
} from '@element-plus/icons-vue'
import { influencerApi } from '@/api/influencer'
import { tagApi } from '@/api/tag'

const loading = ref(false)
const tableData = ref([])
const searchText = ref('')
const dialogVisible = ref(false)
const dialogTitle = ref('新增达人')
const submitting = ref(false)
const importDialogVisible = ref(false)
const uploading = ref(false)
const uploadRef = ref(null)
const currentFile = ref(null)
const formRef = ref(null)
const editingId = ref(null)

const pagination = reactive({
  page: 1,
  size: 20,
  total: 0
})

const formData = reactive({
  name: '',
  gender: '',
  city: '',
  platform_tags: '',
  ranking_info: '',
  influencer_type: '',
  content_theme: '',
  age_rating: '',
  connected_users: 0,
  follower_count: 0,
  expected_cpm: null,
  quote_21_60s: null,
  quote_note: '',
  douyin_id: '',
  xiaohongshu_id: ''
})

// 标签相关
const availableTags = ref([])
const selectedTagValues = ref([])  // 存储选中的标签名称（用于el-select）

// 排序相关
const sortParams = ref({
  prop: null,
  order: null
})

const formRules = {
  name: [{ required: true, message: '请输入姓名或昵称', trigger: 'blur' }]
}

// 格式化数字（万为单位，带千分位）
const formatNumberWithCommas = (num) => {
  if (!num) return '-'
  if (num >= 10000) {
    const wan = num / 10000
    const parts = wan.toFixed(1).split('.')
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',')
    return parts.join('.') + 'w'
  }
  return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

// 格式化数字（万为单位，兼容旧代码）
const formatNumber = (num) => {
  if (!num) return '-'
  if (num >= 10000) {
    return (num / 10000).toFixed(1) + 'w'
  }
  return num.toString()
}

// 获取名字首字母
const getInitials = (name) => {
  if (!name) return ''
  return name.substring(0, 1).toUpperCase()
}

// 解析平台标签
const getPlatformTags = (tags) => {
  if (!tags) return []
  return tags.split(/[，,、]/).filter(t => t.trim())
}

// 解析类型标签
const getTypeTags = (type) => {
  if (!type) return []
  return type.split(/[，,、]/).filter(t => t.trim())
}

// 解析主题标签
const getThemeTags = (theme) => {
  if (!theme) return []
  return theme.split(/[，,、]/).filter(t => t.trim())
}

// 更多操作
const handleMore = (row) => {
  // TODO: 实现更多操作菜单
  console.log('More actions for:', row.name)
}

// 查看详情
const handleView = (row) => {
  // TODO: 实现查看详情
  console.log('View details for:', row.name)
}


// 排序变化处理
const handleSortChange = ({ prop, order }) => {
  sortParams.value = { prop, order }
  // 重置到第一页
  pagination.page = 1
  fetchData()
}

// 获取列表数据
const fetchData = async () => {
  loading.value = true
  try {
    const params = {
      skip: (pagination.page - 1) * pagination.size,
      limit: pagination.size
    }
    if (searchText.value) {
      params.search = searchText.value
    }
    // 添加排序参数
    if (sortParams.value.prop && sortParams.value.order) {
      params.sort_by = sortParams.value.prop
      // 将排序方向转换为后端需要的格式
      if (sortParams.value.order === 'ascending') {
        params.sort_order = 'asc'
      } else if (sortParams.value.order === 'descending') {
        params.sort_order = 'desc'
      }
    }
    const response = await influencerApi.getList(params)
    if (response.data && response.data.items) {
      tableData.value = response.data.items
      pagination.total = response.data.total || 0
    } else {
      // 兼容旧格式
      tableData.value = response.data || []
    }
  } catch (error) {
    ElMessage.error('获取数据失败：' + (error.response?.data?.detail || error.message))
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  pagination.page = 1
  // 重置排序
  sortParams.value = { prop: null, order: null }
  fetchData()
}

// 分页
const handleSizeChange = () => {
  fetchData()
}

const handlePageChange = () => {
  fetchData()
}

// 新增
const handleAdd = () => {
  dialogTitle.value = '新增达人'
  editingId.value = null
  resetForm()
  // 刷新标签列表，确保最新数据
  fetchTags()
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row) => {
  dialogTitle.value = '编辑达人'
  editingId.value = row.id
  Object.assign(formData, {
    name: row.name || '',
    gender: row.gender || '',
    city: row.city || '',
    platform_tags: row.platform_tags || '',
    ranking_info: row.ranking_info || '',
    influencer_type: row.influencer_type || '',
    content_theme: row.content_theme || '',
    age_rating: row.age_rating || '',
    connected_users: row.connected_users || 0,
    follower_count: row.follower_count || 0,
    expected_cpm: row.expected_cpm || null,
    quote_21_60s: row.quote_21_60s || null,
    quote_note: row.quote_note || '',
    douyin_id: row.douyin_id || '',
    xiaohongshu_id: row.xiaohongshu_id || ''
  })
  // 设置选中的标签
  if (row.tags && row.tags.length > 0) {
    selectedTagValues.value = row.tags.map(tag => tag.name)
  } else {
    selectedTagValues.value = []
  }
  // 刷新标签列表，确保最新数据
  fetchTags()
  dialogVisible.value = true
}

// 删除
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除该达人吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await influencerApi.delete(row.id)
    ElMessage.success('删除成功')
    fetchData()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败：' + (error.response?.data?.detail || error.message))
    }
  }
}

// 标签变化处理
const handleTagChange = (value) => {
  // value是标签名称数组
  selectedTagValues.value = value
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitting.value = true
      try {
        // 分离已存在的标签和新标签
        const tagIds = []
        const tagNames = []
        const tagNameToIdMap = new Map(availableTags.value.map(tag => [tag.name, tag.id]))
        
        selectedTagValues.value.forEach(tagName => {
          const tagId = tagNameToIdMap.get(tagName)
          if (tagId) {
            // 已存在的标签
            tagIds.push(tagId)
          } else {
            // 新标签
            tagNames.push(tagName)
          }
        })
        
        const submitData = {
          ...formData,
          tag_ids: tagIds.length > 0 ? tagIds : null,
          tag_names: tagNames.length > 0 ? tagNames : null
        }
        
        if (editingId.value) {
          await influencerApi.update(editingId.value, submitData)
          ElMessage.success('更新成功')
        } else {
          await influencerApi.create(submitData)
          ElMessage.success('创建成功')
        }
        dialogVisible.value = false
        fetchData()
        // 刷新标签列表，确保新创建的标签显示在下拉列表中
        fetchTags()
      } catch (error) {
        ElMessage.error('操作失败：' + (error.response?.data?.detail || error.message))
      } finally {
        submitting.value = false
      }
    }
  })
}

// 重置表单
const resetForm = () => {
  Object.assign(formData, {
    name: '',
    gender: '',
    city: '',
    platform_tags: '',
    ranking_info: '',
    influencer_type: '',
    content_theme: '',
    age_rating: '',
    connected_users: 0,
    follower_count: 0,
    expected_cpm: null,
    quote_21_60s: null,
    quote_note: '',
    douyin_id: '',
    xiaohongshu_id: ''
  })
  selectedTagValues.value = []
  if (formRef.value) {
    formRef.value.clearValidate()
  }
}

// 加载标签列表
const fetchTags = async () => {
  try {
    const response = await tagApi.getList()
    if (response.data) {
      availableTags.value = response.data || []
    } else {
      availableTags.value = []
    }
  } catch (error) {
    console.error('加载标签失败:', error)
    ElMessage.warning('加载标签列表失败，请刷新页面重试')
    availableTags.value = []
  }
}

// 对话框关闭
const handleDialogClose = () => {
  resetForm()
  editingId.value = null
}

// 导入Excel
const handleImport = () => {
  importDialogVisible.value = true
}

// 文件变化
const handleFileChange = (file) => {
  currentFile.value = file.raw
}

// 上传文件
const handleUpload = async () => {
  if (!currentFile.value) {
    ElMessage.warning('请选择文件')
    return
  }
  uploading.value = true
  try {
    const response = await influencerApi.importExcel(currentFile.value)
    ElMessage.success(
      `导入完成！共${response.data.total}条，新增${response.data.created}条，更新${response.data.updated}条`
    )
    if (response.data.errors && response.data.errors.length > 0) {
      console.warn('导入错误：', response.data.errors)
    }
    importDialogVisible.value = false
    currentFile.value = null
    if (uploadRef.value) {
      uploadRef.value.clearFiles()
    }
    fetchData()
  } catch (error) {
    ElMessage.error('导入失败：' + (error.response?.data?.detail || error.message))
  } finally {
    uploading.value = false
  }
}

// 下载模板
const handleDownloadTemplate = async () => {
  try {
    const response = await influencerApi.downloadTemplate()
    const blob = new Blob([response.data])
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = '达人导入模板.xlsx'
    link.click()
    window.URL.revokeObjectURL(url)
    ElMessage.success('模板下载成功')
  } catch (error) {
    ElMessage.error('下载失败：' + (error.response?.data?.detail || error.message))
  }
}

// 监听对话框打开，自动刷新标签列表
watch(dialogVisible, (newVal) => {
  if (newVal) {
    // 对话框打开时刷新标签列表
    fetchTags()
  }
})

onMounted(() => {
  fetchData()
  fetchTags()
})
</script>

<style scoped>

.influencer-list {
  width: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
}

.search-bar {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

/* 表格样式 */
.influencer-table {
  width: 100%;
}

.influencer-table :deep(.el-table__row) {
  width: 100%;
}

/* 达人信息列 */
.influencer-info {
  padding: 8px 0;
}

.info-main {
  display: flex;
  align-items: flex-start;
  gap: 12px;
}

.avatar {
  flex-shrink: 0;
}

.avatar-text {
  font-size: 16px;
  font-weight: 600;
}

.info-content {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.name-row {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.name {
  font-weight: 600;
  font-size: 14px;
  color: #303133;
}

.gender-icon {
  display: inline-flex;
  align-items: center;
  font-size: 14px;
}

.gender-icon.male {
  color: #409EFF;
}

.gender-icon.female {
  color: #F56C6C;
}

.location-icon {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: #909399;
}

.city {
  font-size: 12px;
}

.platform-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.platform-tag {
  background-color: #F0F9FF;
  color: #409EFF;
  border-color: #B3D8FF;
}

.ranking-badge {
  display: inline-block;
  padding: 2px 8px;
  background-color: #FFF7E6;
  color: #E6A23C;
  border: 1px solid #FBD39E;
  border-radius: 4px;
  font-size: 12px;
  line-height: 1.5;
}

.influencer-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 6px;
}

.influencer-tag {
  background-color: #F5F7FA;
  color: #606266;
  border-color: #E4E7ED;
}

.tag-hint {
  margin-top: 4px;
  font-size: 12px;
  color: #909399;
}

/* 代表视频列 */
.video-thumbnails {
  display: flex;
  gap: 8px;
}

.video-thumb {
  width: 72px;
  height: 72px;
  border-radius: 4px;
  overflow: hidden;
  background-color: #F5F7FA;
}

.thumbnail {
  width: 100%;
  height: 100%;
}

.thumbnail-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #F5F7FA;
  color: #C0C4CC;
}

/* 类型和主题标签 */
.type-tags,
.theme-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  align-items: center;
}

.type-tag,
.theme-tag {
  background-color: #F5F7FA;
  color: #606266;
  border-color: #E4E7ED;
}

.age-rating {
  font-size: 12px;
  color: #909399;
  margin-left: 4px;
}

/* 数字显示 */
.number-large {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
}

/* 报价列 */
.quote-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.quote-price {
  font-size: 16px;
  font-weight: 600;
  color: #FC376F;
}

.quote-note {
  font-size: 12px;
  color: #909399;
  line-height: 1.4;
  text-align: center;
}

/* 操作列 */
.operation-buttons {
  display: flex;
  align-items: center;
  gap: 8px;
  justify-content: center;
}

.action-btn {
  background-color: #F5F7FA;
  border-color: #E4E7ED;
  color: #606266;
}

.action-btn:hover {
  background-color: #EBEDF0;
  border-color: #DCDFE6;
}

.delete-btn {
  color: #F56C6C;
}

.delete-btn:hover {
  background-color: #FEF0F0;
  border-color: #FBC4C4;
  color: #F56C6C;
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

/* 主题色应用到按钮 */
:deep(.el-button--primary) {
  background-color: #FC376F;
  border-color: #FC376F;
}

:deep(.el-button--primary:hover) {
  background-color: #E63260;
  border-color: #E63260;
}

/* 确保表格行满宽度 */
:deep(.el-table__body-wrapper) {
  width: 100%;
}

:deep(.el-table__body) {
  width: 100%;
}

:deep(.el-table__row) {
  width: 100%;
}

:deep(.el-table__cell) {
  padding: 12px 0;
}
</style>


