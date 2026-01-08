# 达人老师CRM系统 (Xingtu CRM)

一个轻量级的达人老师（influencer）CRM管理系统，支持Excel导入、基础资料管理和平台数据爬取。

## 功能特性

### 第一阶段（已完成）
- ✅ Excel表格导入达人老师基础资料
- ✅ 达人老师基础资料增删改查
- ✅ 数据列表展示和筛选

### 第二阶段（架构已设计，待实现）
- 🏗️ 抖音平台数据爬取（架构已设计，需要实现具体爬虫逻辑）
- 🏗️ 小红书平台数据爬取（架构已设计，需要实现具体爬虫逻辑）
- 🏗️ 自动更新达人数据（定时任务框架已准备）

## 技术栈

- **后端**: Python 3.11 + FastAPI + SQLAlchemy + PostgreSQL
- **前端**: Vue 3 + Element Plus + Axios
- **部署**: Docker + Docker Compose

## 快速开始

### 使用Docker一键部署

#### Windows系统
```bash
start.bat
```

#### Linux/Mac系统
```bash
chmod +x start.sh
./start.sh
```

#### 或直接使用Docker Compose
```bash
docker-compose up -d
```

访问：
- 前端: http://localhost:8080
- 后端API: http://localhost:8000
- API文档: http://localhost:8000/docs

### 本地开发

#### 后端开发
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### 前端开发
```bash
cd frontend
npm install
npm run dev
```

## 项目结构

```
xingtu_crm/
├── backend/              # 后端服务
│   ├── app/
│   │   ├── api/          # API路由
│   │   ├── models/       # 数据模型
│   │   ├── services/     # 业务逻辑
│   │   └── main.py       # 应用入口
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/             # 前端应用
│   ├── src/
│   │   ├── views/        # 页面组件
│   │   ├── components/    # 通用组件
│   │   └── api/          # API调用
│   ├── package.json
│   └── Dockerfile
├── docker-compose.yml    # Docker编排
└── README.md
```

## 数据库设计

### 达人老师基础资料表 (influencers)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| name | String | 姓名/昵称 |
| gender | String | 性别 |
| city | String | 所在城市 |
| platform_tags | String | 平台标签（抖音精选、繁星企划等） |
| influencer_type | String | 达人类型 |
| content_theme | String | 内容主题 |
| connected_users | Integer | 连接用户数 |
| follower_count | Integer | 粉丝数 |
| expected_cpm | Float | 预期CPM |
| quote_21_60s | Float | 21-60s报价 |
| representative_videos | JSON | 代表视频（JSON数组） |
| created_at | DateTime | 创建时间 |
| updated_at | DateTime | 更新时间 |

## 开发计划

- [x] 项目架构设计
- [x] 第一阶段：Excel导入和CRUD
- [ ] 第二阶段：平台数据爬取
- [ ] 数据分析和报表功能

## License

MIT

