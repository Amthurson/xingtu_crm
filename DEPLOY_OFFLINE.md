# 离线部署方案（解决网络问题）

## 问题
服务器无法访问Docker Hub和镜像加速器，无法拉取镜像。

## 解决方案：在本地拉取镜像，然后上传到服务器

### 步骤1：在本地（Windows）拉取并导出镜像

#### 方式1：使用PowerShell脚本（推荐）

```powershell
# 在项目根目录执行
.\export-images.ps1
```

这个脚本会：
1. 自动拉取所有需要的镜像
2. 导出为tar文件
3. 显示文件大小

#### 方式2：手动操作

```powershell
# 1. 拉取镜像
docker pull python:3.11-slim
docker pull node:18-alpine
docker pull postgres:15-alpine
docker pull nginx:alpine

# 2. 导出镜像
docker save python:3.11-slim -o python_3.11-slim.tar
docker save node:18-alpine -o node_18-alpine.tar
docker save postgres:15-alpine -o postgres_15-alpine.tar
docker save nginx:alpine -o nginx_alpine.tar
```

### 步骤2：上传tar文件到服务器

#### 使用scp
```powershell
# 在本地执行
scp *.tar root@your-server-ip:/tmp/
```

#### 使用FTP工具
- FileZilla
- WinSCP
- XFTP

上传到服务器的 `/tmp/` 目录

### 步骤3：在服务器上导入镜像

#### 方式1：使用脚本
```bash
# 上传 import-images-on-server.sh 到服务器
chmod +x import-images-on-server.sh
./import-images-on-server.sh /tmp
```

#### 方式2：手动导入
```bash
cd /tmp
docker load < postgres_15-alpine.tar
docker load < python_3.11-slim.tar
docker load < node_18-alpine.tar
docker load < nginx_alpine.tar

# 验证
docker images
```

### 步骤4：启动服务

```bash
cd /opt/xingtu_crm  # 或你的项目目录
docker-compose up -d
```

## 文件大小参考

- python:3.11-slim: ~50-60 MB
- node:18-alpine: ~40-50 MB
- postgres:15-alpine: ~80-100 MB
- nginx:alpine: ~20-30 MB

**总计：约200-240 MB**

## 快速操作流程

```powershell
# 本地（Windows）
.\export-images.ps1
scp *.tar root@your-server-ip:/tmp/
```

```bash
# 服务器（Linux）
cd /tmp
docker load < postgres_15-alpine.tar
docker load < python_3.11-slim.tar
docker load < node_18-alpine.tar
docker load < nginx_alpine.tar
cd /opt/xingtu_crm
docker-compose up -d
```

## 优势

- ✅ 不依赖服务器网络
- ✅ 速度快（本地网络通常比服务器快）
- ✅ 可以重复使用
- ✅ 适合网络受限环境
