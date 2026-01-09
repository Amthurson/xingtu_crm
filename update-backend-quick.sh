#!/bin/bash
# 快速更新后端（不拉取代码，只重新构建）

echo "=========================================="
echo "    快速更新后端"
echo "=========================================="
echo ""

# 停止并重新构建
docker-compose stop backend
export DOCKER_BUILDKIT=0
docker-compose build backend
docker-compose up -d backend

echo ""
echo "等待服务启动..."
sleep 5

# 检查状态
docker-compose ps backend

echo ""
echo "更新完成！"
