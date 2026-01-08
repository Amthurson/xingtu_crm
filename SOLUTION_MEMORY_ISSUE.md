# 解决前端构建内存不足问题（SIGKILL）

## 问题
前端构建时被 `SIGKILL` 杀死，错误信息：
```
npm error signal SIGKILL
```

这通常是因为服务器内存不足，系统OOM killer杀死了构建进程。

## 解决方案

### 方案1：在本地构建前端，然后部署（最快，推荐）

#### 步骤1：在本地构建前端
```powershell
# 在本地（Windows）
cd frontend
npm install
npm run build
```

#### 步骤2：上传dist目录到服务器
```powershell
# 压缩dist目录
Compress-Archive -Path frontend\dist -DestinationPath frontend-dist.zip

# 上传到服务器
scp frontend-dist.zip root@your-server-ip:/opt/xingtu_crm/frontend/
```

#### 步骤3：在服务器上解压并使用简化Dockerfile
```bash
# 解压
cd /opt/xingtu_crm/frontend
unzip frontend-dist.zip

# 使用简化版Dockerfile
cp Dockerfile.simple Dockerfile

# 重新构建前端（这次很快，不需要npm build）
cd ..
docker-compose build frontend
docker-compose up -d frontend
```

### 方案2：增加服务器swap空间

```bash
# 1. 创建2GB swap文件
dd if=/dev/zero of=/swapfile bs=1M count=2048

# 2. 设置权限
chmod 600 /swapfile

# 3. 格式化为swap
mkswap /swapfile

# 4. 启用swap
swapon /swapfile

# 5. 永久启用（添加到/etc/fstab）
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# 6. 验证
free -h

# 7. 重新构建前端
export DOCKER_BUILDKIT=0
docker-compose build frontend
```

### 方案3：优化Dockerfile减少内存使用

使用优化版Dockerfile（已创建 `frontend/Dockerfile.optimized`）：

```bash
# 在服务器上
cd /opt/xingtu_crm/frontend
cp Dockerfile.optimized Dockerfile

# 重新构建
cd ..
export DOCKER_BUILDKIT=0
docker-compose build frontend
```

### 方案4：增加Docker内存限制

如果使用Docker Desktop或可以配置Docker资源：

```bash
# 检查当前内存限制
docker info | grep -i memory

# 如果可能，增加Docker可用内存
# （这需要在Docker Desktop设置中配置，或使用docker run时指定）
```

## 推荐方案

**最快最可靠：方案1（本地构建）**

1. 在本地构建前端（内存充足）
2. 上传dist目录
3. 使用简化Dockerfile部署

这样：
- ✅ 不依赖服务器内存
- ✅ 构建速度快
- ✅ 避免内存问题

## 当前状态

好消息：**后端和数据库已经运行！**

你可以：
1. 先访问后端API：http://your-server-ip:8000/docs
2. 前端可以稍后部署（使用本地构建方案）

## 快速操作（推荐）

```powershell
# 本地：构建前端
cd frontend
npm run build
Compress-Archive -Path dist -DestinationPath ../frontend-dist.zip
scp ../frontend-dist.zip root@your-server-ip:/opt/xingtu_crm/frontend/
```

```bash
# 服务器：解压并使用简化Dockerfile
cd /opt/xingtu_crm/frontend
unzip -o frontend-dist.zip
cp Dockerfile.simple Dockerfile
cd ..
docker-compose build frontend
docker-compose up -d frontend
```
