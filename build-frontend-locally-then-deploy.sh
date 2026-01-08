#!/bin/bash
# 在本地构建前端，然后部署

echo "=========================================="
echo "    本地构建前端方案"
echo "=========================================="
echo ""

# 检查是否在项目根目录
if [ ! -f "docker-compose.yml" ]; then
    echo "错误: 请在项目根目录运行此脚本"
    exit 1
fi

# 检查前端dist目录
if [ -d "frontend/dist" ]; then
    echo "✓ 发现前端构建产物"
    echo ""
    echo "现在可以修改docker-compose.yml，使用预构建的前端"
    echo "或者直接使用现有的前端镜像（如果已构建）"
else
    echo "前端dist目录不存在"
    echo ""
    echo "方案1: 在本地构建前端"
    echo "  1. 在本地运行: cd frontend && npm install && npm run build"
    echo "  2. 上传dist目录到服务器"
    echo "  3. 使用简化的Dockerfile（只复制dist）"
    echo ""
    echo "方案2: 增加服务器内存或swap"
    echo "  增加swap空间，然后重新构建"
fi
