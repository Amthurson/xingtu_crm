# 使用pnpm部署前端（服务器上）

## 方案1：在Docker中使用pnpm（推荐）

已更新 `frontend/Dockerfile`，现在使用：
- Node.js 24.3.0
- pnpm（比npm更节省内存）

### 在服务器上执行：

```bash
cd /opt/xingtu_crm

# 重新构建前端（使用新的Dockerfile）
export DOCKER_BUILDKIT=0
docker-compose build frontend

# 启动前端
docker-compose up -d frontend
```

## 方案2：在服务器上直接使用nvm+pnpm构建（如果Docker构建仍然内存不足）

### 步骤1：安装nvm和Node.js 24.3.0

```bash
# 安装nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# 加载nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 安装Node.js 24.3.0
nvm install 24.3.0
nvm use 24.3.0

# 验证
node --version
```

### 步骤2：安装pnpm

```bash
npm install -g pnpm
pnpm --version
```

### 步骤3：构建前端

```bash
cd /opt/xingtu_crm/frontend

# 安装依赖
pnpm install

# 构建
pnpm run build

# 使用简化Dockerfile（只复制dist）
cp Dockerfile.simple Dockerfile
cd ..
docker-compose build frontend
docker-compose up -d frontend
```

## 方案3：使用自动化脚本

```bash
# 上传 build-frontend-on-server.sh 到服务器
chmod +x build-frontend-on-server.sh
./build-frontend-on-server.sh
```

## pnpm的优势

- ✅ 更节省内存（适合服务器内存有限的情况）
- ✅ 更快的安装速度
- ✅ 更节省磁盘空间（使用硬链接）
- ✅ 更严格的依赖管理

## 当前Dockerfile配置

新的 `frontend/Dockerfile` 已配置：
- Node.js 24.3.0-alpine
- pnpm（最新版）
- 使用国内镜像源（registry.npmmirror.com）

## 快速部署

```bash
# 在服务器上
cd /opt/xingtu_crm
git pull  # 拉取最新的Dockerfile
export DOCKER_BUILDKIT=0
docker-compose build frontend
docker-compose up -d frontend
```
