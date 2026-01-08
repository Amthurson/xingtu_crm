#!/bin/bash
# 一键部署脚本 - 适用于中国内地服务器

set -e

echo "=========================================="
echo "    星图CRM系统 - 一键部署脚本"
echo "=========================================="
echo ""

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then 
    echo "请使用root用户运行此脚本"
    exit 1
fi

# 检查并安装Docker
if ! command -v docker &> /dev/null; then
    echo "正在安装Docker..."
    curl -fsSL https://get.docker.com | bash
    systemctl start docker
    systemctl enable docker
    echo "✓ Docker安装完成"
else
    echo "✓ Docker已安装"
fi

# 检查并安装Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "正在安装Docker Compose..."
    DOCKER_COMPOSE_VERSION="2.20.0"
    curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo "✓ Docker Compose安装完成"
else
    echo "✓ Docker Compose已安装"
fi

# 配置Docker镜像加速器（使用阿里云）
echo ""
echo "配置Docker镜像加速器..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
EOF
systemctl restart docker
echo "✓ 镜像加速器配置完成"

# 拉取基础镜像
echo ""
echo "拉取基础镜像..."
docker pull python:3.11-slim || true
docker pull node:18-alpine || true
docker pull postgres:15-alpine || true
docker pull nginx:alpine || true
echo "✓ 基础镜像拉取完成"

# 检查项目目录
if [ ! -f "docker-compose.yml" ]; then
    echo "错误: 未找到docker-compose.yml，请确保在项目根目录运行此脚本"
    exit 1
fi

# 构建并启动服务
echo ""
echo "构建服务..."
export DOCKER_BUILDKIT=0
docker-compose build

echo ""
echo "启动服务..."
docker-compose up -d

# 等待服务启动
echo ""
echo "等待服务启动..."
sleep 5

# 检查服务状态
echo ""
echo "=========================================="
echo "          服务状态"
echo "=========================================="
docker-compose ps

# 获取服务器IP
SERVER_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip || echo "your-server-ip")

echo ""
echo "=========================================="
echo "          部署完成！"
echo "=========================================="
echo "前端界面: http://${SERVER_IP}:8080"
echo "后端API:  http://${SERVER_IP}:8000"
echo "API文档:  http://${SERVER_IP}:8000/docs"
echo ""
echo "查看日志: docker-compose logs -f"
echo "停止服务: docker-compose down"
echo "=========================================="
