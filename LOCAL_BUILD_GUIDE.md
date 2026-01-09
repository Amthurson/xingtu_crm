# 本地构建前端指南

## 环境准备

### 1. 安装nvm-windows
- 下载：https://github.com/coreybutler/nvm-windows/releases
- 安装 `nvm-setup.exe`
- 重启PowerShell

### 2. 运行准备脚本
```powershell
.\prepare-local.ps1
```

这会自动：
- 安装Node.js 24.3.0
- 安装pnpm
- 配置pnpm镜像源（使用国内镜像）
- 安装前端依赖

## 构建前端

### 方法1：使用构建脚本（推荐）
```powershell
.\build-frontend-local.ps1
```

### 方法2：手动构建
```powershell
cd frontend
pnpm build
```

构建产物在 `frontend/dist` 目录

## 部署到服务器

### 方法1：使用上传脚本
```powershell
.\upload-dist-to-server.ps1 -ServerIP "your-server-ip"
```

### 方法2：手动上传
```powershell
# 压缩dist目录
Compress-Archive -Path frontend\dist -DestinationPath frontend-dist.zip

# 上传
scp frontend-dist.zip root@your-server-ip:/opt/xingtu_crm/frontend/
```

在服务器上：
```bash
cd /opt/xingtu_crm/frontend
unzip -o frontend-dist.zip
cp Dockerfile.simple Dockerfile
cd ..
docker-compose build frontend
docker-compose up -d frontend
```

## 开发模式

```powershell
cd frontend
pnpm dev
```

访问：http://localhost:5173

## 预览构建结果

```powershell
cd frontend
pnpm preview
```

访问：http://localhost:4173

## 当前状态

✅ Node.js 24.3.0 已安装
✅ pnpm 10.24.0 已安装
✅ 依赖已安装
✅ 前端已构建（dist目录已生成）

## 优势

- ✅ 本地构建，不依赖服务器内存
- ✅ 使用pnpm，更快的安装速度
- ✅ 使用Node.js 24.3.0，最新特性
- ✅ 避免服务器内存不足问题
