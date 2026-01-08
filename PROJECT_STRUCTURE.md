# 项目结构说明

## 目录结构

```
xingtu_crm/
├── backend/                    # 后端服务
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py             # FastAPI应用入口
│   │   ├── database.py         # 数据库配置
│   │   ├── api/                # API路由
│   │   │   ├── __init__.py
│   │   │   ├── influencers.py  # 达人管理API
│   │   │   ├── import_excel.py # Excel导入API
│   │   │   └── crawler.py      # 爬虫API（第二阶段）
│   │   ├── models/             # 数据模型
│   │   │   ├── __init__.py
│   │   │   └── influencer.py   # 达人模型
│   │   ├── schemas/            # Pydantic模式
│   │   │   ├── __init__.py
│   │   │   └── influencer.py   # 达人模式
│   │   └── services/           # 业务逻辑
│   │       ├── __init__.py
│   │       └── crawler.py      # 爬虫服务（第二阶段）
│   ├── requirements.txt        # Python依赖
│   ├── Dockerfile             # Docker镜像配置
│   └── .dockerignore
│
├── frontend/                   # 前端应用
│   ├── src/
│   │   ├── main.js            # Vue应用入口
│   │   ├── App.vue            # 根组件
│   │   ├── router/            # 路由配置
│   │   │   └── index.js
│   │   ├── views/             # 页面组件
│   │   │   └── InfluencerList.vue  # 达人列表页
│   │   └── api/               # API调用
│   │       └── influencer.js
│   ├── package.json           # Node依赖
│   ├── vite.config.js         # Vite配置
│   ├── index.html             # HTML入口
│   ├── nginx.conf             # Nginx配置
│   ├── Dockerfile             # Docker镜像配置
│   └── .dockerignore
│
├── docker-compose.yml          # Docker编排配置
├── .gitignore                 # Git忽略文件
├── README.md                  # 项目说明
├── DEPLOYMENT.md              # 部署指南
├── PROJECT_STRUCTURE.md       # 本文件
├── start.sh                   # Linux/Mac启动脚本
└── start.bat                  # Windows启动脚本
```

## 技术架构

### 后端技术栈

- **框架**: FastAPI (Python 3.11)
- **ORM**: SQLAlchemy 2.0
- **数据库**: PostgreSQL 15
- **数据处理**: Pandas, OpenPyXL
- **爬虫**: Requests, BeautifulSoup4 (第二阶段)

### 前端技术栈

- **框架**: Vue 3
- **UI库**: Element Plus
- **构建工具**: Vite
- **HTTP客户端**: Axios
- **路由**: Vue Router

### 部署技术

- **容器化**: Docker
- **编排**: Docker Compose
- **Web服务器**: Nginx (前端)

## 数据流

### 第一阶段：基础数据管理

```
用户操作 → 前端Vue组件 → Axios请求 → FastAPI后端 → SQLAlchemy ORM → PostgreSQL数据库
```

### Excel导入流程

```
用户上传Excel → 前端上传文件 → 后端接收文件 → Pandas解析Excel → 
数据验证 → SQLAlchemy插入/更新 → 返回结果 → 前端显示
```

### 第二阶段：爬虫数据获取

```
定时任务/手动触发 → 爬虫服务 → 平台API/爬虫 → 数据解析 → 
数据库更新 → 前端展示
```

## API接口

### 达人管理 (`/api/influencers`)

- `GET /` - 获取达人列表（支持分页、搜索）
- `GET /{id}` - 获取达人详情
- `POST /` - 创建达人
- `PUT /{id}` - 更新达人
- `DELETE /{id}` - 删除达人

### Excel导入 (`/api/import`)

- `POST /excel` - 导入Excel文件
- `GET /template` - 下载Excel模板

### 爬虫服务 (`/api/crawler`) - 第二阶段

- `POST /douyin/{influencer_id}` - 爬取单个达人抖音数据
- `POST /xiaohongshu/{influencer_id}` - 爬取单个达人小红书数据
- `POST /batch/{platform}` - 批量爬取数据

## 数据库设计

### influencers 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| name | String(200) | 姓名/昵称（必填，索引） |
| gender | String(10) | 性别 |
| city | String(100) | 所在城市 |
| platform_tags | String(500) | 平台标签 |
| ranking_info | String(500) | 排名信息 |
| influencer_type | String(200) | 达人类型 |
| content_theme | String(500) | 内容主题 |
| age_rating | String(50) | 年龄评级 |
| connected_users | Integer | 连接用户数 |
| follower_count | Integer | 粉丝数 |
| expected_cpm | Float | 预期CPM |
| quote_21_60s | Float | 21-60s报价 |
| quote_note | Text | 报价备注 |
| representative_videos | JSON | 代表视频 |
| douyin_id | String(100) | 抖音ID |
| xiaohongshu_id | String(100) | 小红书ID |
| created_at | DateTime | 创建时间 |
| updated_at | DateTime | 更新时间 |

## 开发规范

### 代码风格

- **Python**: 遵循PEP 8
- **JavaScript**: 使用ES6+语法
- **命名**: 
  - Python: snake_case
  - JavaScript: camelCase

### 文件组织

- 按功能模块划分
- 每个模块包含：models、schemas、api、services
- 保持单一职责原则

### 错误处理

- 使用FastAPI的HTTPException
- 前端使用Element Plus的Message组件
- 记录详细的错误日志

## 扩展计划

### 第二阶段功能

1. **爬虫服务完善**
   - 实现抖音数据爬取
   - 实现小红书数据爬取
   - 添加定时任务
   - 数据更新通知

2. **数据分析**
   - 数据统计报表
   - 趋势分析
   - 导出功能增强

3. **权限管理**
   - 用户认证
   - 角色权限
   - 操作日志

4. **性能优化**
   - 数据库索引优化
   - 缓存机制
   - 异步任务队列


