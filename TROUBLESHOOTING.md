# 故障排除指南

## Docker Compose 500错误

如果遇到以下错误：
```
request returned 500 Internal Server Error for API route and version
```

### 解决方案

#### 1. 重启Docker Desktop
- 完全退出Docker Desktop
- 重新启动Docker Desktop
- 等待Docker完全启动（状态栏显示"Running"）

#### 2. 检查Docker服务状态
```powershell
# 检查Docker是否正常运行
docker ps

# 如果失败，尝试重启Docker服务
Restart-Service docker
```

#### 3. 清理Docker缓存
```powershell
# 清理未使用的镜像和容器
docker system prune -a

# 清理构建缓存
docker builder prune
```

#### 4. 使用Docker Buildx（如果支持）
```powershell
# 设置环境变量
$env:COMPOSE_BAKE="true"
docker-compose build
```

#### 5. 分步构建
如果整体构建失败，可以分步构建：

```powershell
# 1. 先构建后端
cd backend
docker build -t xingtu_crm-backend .
cd ..

# 2. 再构建前端
cd frontend
docker build -t xingtu_crm-frontend .
cd ..

# 3. 最后启动所有服务
docker-compose up -d
```

#### 6. 检查Docker Desktop版本
确保使用最新版本的Docker Desktop：
- 访问：https://www.docker.com/products/docker-desktop
- 下载并安装最新版本

## 常见问题

### 端口被占用

如果8000或8080端口被占用：

1. 查找占用端口的进程
```powershell
netstat -ano | findstr :8000
netstat -ano | findstr :8080
```

2. 修改docker-compose.yml中的端口映射
```yaml
ports:
  - "8001:8000"  # 改为其他端口
```

### 数据库连接失败

1. 检查PostgreSQL容器是否运行
```powershell
docker-compose ps postgres
```

2. 查看PostgreSQL日志
```powershell
docker-compose logs postgres
```

3. 等待数据库完全启动
PostgreSQL需要几秒钟才能完全启动，确保健康检查通过。

### 前端无法连接后端

1. 检查nginx配置
确保nginx.conf中的代理地址正确：
```nginx
proxy_pass http://backend:8000;
```

2. 检查网络连接
```powershell
docker network ls
docker network inspect xingtu_crm_xingtu_network
```

### Excel导入失败

1. 检查文件格式
确保上传的是.xlsx或.xls文件

2. 检查列名
确保Excel列名与模板一致

3. 查看后端日志
```powershell
docker-compose logs backend
```

## 重新部署

如果所有方法都失败，可以完全重新部署：

```powershell
# 1. 停止所有服务
docker-compose down -v

# 2. 清理所有相关镜像
docker rmi xingtu_crm-backend xingtu_crm-frontend

# 3. 重新构建和启动
docker-compose up -d --build
```

## 获取帮助

如果问题仍然存在：

1. 查看完整日志
```powershell
docker-compose logs --tail=100
```

2. 检查系统资源
确保有足够的内存和磁盘空间

3. 查看Docker Desktop日志
- Windows: `%LOCALAPPDATA%\Docker\log.txt`

