# 部署指南

## Docker 一键部署

### 前置要求

- Docker 20.10+
- Docker Compose 2.0+

### 快速开始

1. **克隆项目**（如果从远程仓库）
```bash
git clone <repository-url>
cd xingtu_crm
```

2. **启动服务**
```bash
docker-compose up -d
```

3. **查看服务状态**
```bash
docker-compose ps
```

4. **查看日志**
```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f postgres
```

### 访问服务

- **前端界面**: http://localhost:8080
- **后端API**: http://localhost:8000
- **API文档**: http://localhost:8000/docs
- **健康检查**: http://localhost:8000/health

### 停止服务

```bash
docker-compose down
```

### 停止并删除数据卷

```bash
docker-compose down -v
```

### 重新构建

```bash
# 重新构建所有服务
docker-compose build

# 重新构建特定服务
docker-compose build backend

# 重新构建并启动
docker-compose up -d --build
```

## 环境变量配置

### 后端环境变量

在 `docker-compose.yml` 中配置或创建 `.env` 文件：

```env
DATABASE_URL=postgresql://postgres:postgres@postgres:5432/xingtu_crm
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=xingtu_crm
```

### 生产环境建议

1. **修改数据库密码**
```bash
# 在 docker-compose.yml 中修改
POSTGRES_PASSWORD=your_strong_password
```

2. **配置CORS白名单**
```python
# backend/app/main.py
allow_origins=["http://your-domain.com"]
```

3. **使用HTTPS**
- 使用Nginx反向代理
- 配置SSL证书

## 数据备份

### 备份数据库

```bash
docker-compose exec postgres pg_dump -U postgres xingtu_crm > backup.sql
```

### 恢复数据库

```bash
docker-compose exec -T postgres psql -U postgres xingtu_crm < backup.sql
```

## 常见问题

### 1. 端口被占用

修改 `docker-compose.yml` 中的端口映射：
```yaml
ports:
  - "8001:8000"  # 改为其他端口
```

### 2. 数据库连接失败

检查数据库服务是否启动：
```bash
docker-compose ps postgres
docker-compose logs postgres
```

### 3. 前端无法连接后端

检查Nginx配置和CORS设置。

### 4. Excel导入失败

检查文件格式和列名是否匹配模板。

## 开发模式

### 本地开发（不使用Docker）

#### 后端
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### 前端
```bash
cd frontend
npm install
npm run dev
```

### 使用Docker但需要热重载

后端已配置 `--reload` 参数，代码修改会自动重载。

## 监控和维护

### 查看资源使用

```bash
docker stats
```

### 清理未使用的资源

```bash
# 清理未使用的镜像
docker image prune

# 清理所有未使用的资源
docker system prune
```


