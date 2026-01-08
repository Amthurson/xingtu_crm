#!/bin/bash
# 在服务器上使用nvm和pnpm构建前端

echo "=========================================="
echo "    在服务器上构建前端（使用nvm+pnpm）"
echo "=========================================="
echo ""

# 检查是否在项目根目录
if [ ! -f "docker-compose.yml" ]; then
    echo "错误: 请在项目根目录运行此脚本"
    exit 1
fi

# 检查nvm是否安装
if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
    echo "安装nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# 加载nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 安装Node.js 24.3.0
echo "安装Node.js 24.3.0..."
nvm install 24.3.0
nvm use 24.3.0

# 验证Node.js版本
echo "Node.js版本:"
node --version

# 安装pnpm
echo ""
echo "安装pnpm..."
npm install -g pnpm

# 验证pnpm版本
echo "pnpm版本:"
pnpm --version

# 进入前端目录
cd frontend

# 安装依赖
echo ""
echo "安装前端依赖..."
pnpm install

# 构建前端
echo ""
echo "构建前端..."
pnpm run build

# 检查构建结果
if [ -d "dist" ]; then
    echo ""
    echo "✓ 前端构建成功！"
    echo "dist目录大小:"
    du -sh dist
    echo ""
    echo "现在可以使用简化Dockerfile部署："
    echo "  cp Dockerfile.simple Dockerfile"
    echo "  cd .."
    echo "  docker-compose build frontend"
    echo "  docker-compose up -d frontend"
else
    echo ""
    echo "✗ 前端构建失败"
    exit 1
fi
