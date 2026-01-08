#!/bin/bash
# 调试构建问题

echo "=========================================="
echo "    调试构建问题"
echo "=========================================="
echo ""

# 1. 检查镜像是否构建成功
echo "1. 检查已构建的镜像:"
docker images | grep xingtu_crm
echo ""

# 2. 检查是否有构建中的容器
echo "2. 检查所有容器:"
docker ps -a
echo ""

# 3. 尝试单独构建每个服务
echo "3. 尝试单独构建后端..."
export DOCKER_BUILDKIT=0
docker-compose build backend 2>&1 | tail -10

echo ""
echo "4. 尝试单独构建前端..."
docker-compose build frontend 2>&1 | tail -10

echo ""
echo "5. 检查docker-compose配置:"
docker-compose config 2>&1 | head -30

echo ""
echo "6. 尝试不使用缓存重新构建:"
docker-compose build --no-cache 2>&1 | tail -20
