#!/bin/bash

echo "=========================================="
echo "      达人老师CRM系统 - 一键启动脚本"
echo "=========================================="
echo ""

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: 未检测到Docker，请先安装Docker"
    exit 1
fi

# 检查Docker Compose是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "错误: 未检测到Docker Compose，请先安装Docker Compose"
    exit 1
fi

echo "✓ Docker环境检查通过"
echo ""

# 启动服务
echo "正在启动服务..."
docker-compose up -d

echo ""
echo "等待服务启动..."
sleep 5

# 检查服务状态
echo ""
echo "=========================================="
echo "          服务状态"
echo "=========================================="
docker-compose ps

echo ""
echo "=========================================="
echo "          访问地址"
echo "=========================================="
echo "前端界面: http://localhost:8080"
echo "后端API:  http://localhost:8000"
echo "API文档:  http://localhost:8000/docs"
echo ""
echo "查看日志: docker-compose logs -f"
echo "停止服务: docker-compose down"
echo "=========================================="


