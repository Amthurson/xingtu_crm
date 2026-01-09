# 后端更新指南

## 更新方法

### 方法1：使用更新脚本（推荐）

#### 完整更新（拉取代码 + 重新构建）
```bash
cd /usr/local/apps/xingtu_crm
chmod +x update-backend.sh
./update-backend.sh
```

#### 快速更新（只重新构建，不拉取代码）
```bash
cd /usr/local/apps/xingtu_crm
chmod +x update-backend-quick.sh
./update-backend-quick.sh
```

### 方法2：手动更新

```bash
# 1. 进入项目目录
cd /usr/local/apps/xingtu_crm

# 2. 拉取最新代码（如果使用git）
git pull

# 3. 停止后端
docker-compose stop backend

# 4. 重新构建后端
export DOCKER_BUILDKIT=0
docker-compose build backend

# 5. 启动后端
docker-compose up -d backend

# 6. 查看状态
docker-compose ps backend

# 7. 查看日志（如果需要）
docker-compose logs -f backend
```

## 更新步骤说明

### 1. 拉取代码
如果使用git管理代码：
```bash
git pull origin master
# 或
git pull origin main
```

### 2. 重新构建
后端代码更新后，需要重新构建Docker镜像：
```bash
docker-compose build backend
```

### 3. 重启服务
构建完成后，重启后端容器：
```bash
docker-compose up -d backend
```

## 零停机更新（高级）

如果需要零停机更新，可以使用滚动更新：

```bash
# 1. 构建新镜像（使用不同标签）
docker-compose build backend
docker tag xingtu_crm-backend:latest xingtu_crm-backend:new

# 2. 启动新容器（使用不同端口）
docker run -d --name xingtu_crm_backend_new \
  -p 8001:8000 \
  --network xingtu_crm_xingtu_network \
  -e DATABASE_URL=postgresql://postgres:postgres@postgres:5432/xingtu_crm \
  xingtu_crm-backend:new

# 3. 测试新版本
curl http://localhost:8001/docs

# 4. 如果正常，切换nginx配置到新端口
# 编辑nginx配置，将8000改为8001

# 5. 重载nginx
nginx -s reload

# 6. 停止旧容器
docker-compose stop backend
docker-compose rm -f backend

# 7. 重命名新容器
docker rename xingtu_crm_backend_new xingtu_crm_backend
```

## 回滚

如果更新后出现问题，可以回滚到之前的版本：

```bash
# 1. 停止当前后端
docker-compose stop backend

# 2. 使用之前的镜像（如果有）
docker-compose up -d backend

# 3. 或者回滚代码
git reset --hard HEAD~1
docker-compose build backend
docker-compose up -d backend
```

## 检查更新是否成功

```bash
# 1. 检查容器状态
docker-compose ps backend

# 2. 检查日志
docker-compose logs --tail=50 backend

# 3. 测试API
curl http://localhost:8000/docs

# 4. 检查前端是否能正常访问API
# 访问网站，测试功能是否正常
```

## 常见问题

### 问题1：构建失败
```bash
# 查看详细错误
docker-compose build --no-cache backend

# 检查代码是否有语法错误
cd backend
python -m py_compile app/main.py
```

### 问题2：服务启动失败
```bash
# 查看日志
docker-compose logs backend

# 检查数据库连接
docker-compose ps postgres
docker-compose logs postgres
```

### 问题3：端口被占用
```bash
# 检查端口占用
netstat -tlnp | grep 8000

# 停止占用端口的进程
docker-compose stop backend
```

## 自动化更新（可选）

可以设置定时任务自动更新：

```bash
# 编辑crontab
crontab -e

# 添加定时任务（每天凌晨2点更新）
0 2 * * * cd /usr/local/apps/xingtu_crm && ./update-backend.sh >> /var/log/xingtu_crm_update.log 2>&1
```

## 更新检查清单

- [ ] 备份数据库（重要更新前）
- [ ] 拉取最新代码
- [ ] 检查代码变更
- [ ] 重新构建镜像
- [ ] 重启服务
- [ ] 检查服务状态
- [ ] 测试API功能
- [ ] 检查前端是否正常

## 推荐流程

1. **开发环境测试** → 2. **提交代码** → 3. **服务器拉取** → 4. **重新构建** → 5. **重启服务** → 6. **验证功能**
