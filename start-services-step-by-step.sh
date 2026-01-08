#!/bin/bash
# 分步启动服务

echo "=========================================="
echo "    分步启动服务"
echo "=========================================="
echo ""

# 1. 检查镜像
echo "1. 检查镜像..."
docker images | grep -E "xingtu_crm|postgres"
echo ""

# 2. 先启动postgres
echo "2. 启动PostgreSQL..."
docker-compose up -d postgres

# 等待postgres就绪
echo "等待PostgreSQL启动..."
sleep 10

# 检查postgres状态
docker-compose ps postgres
echo ""

# 3. 检查后端镜像是否存在
echo "3. 检查后端镜像..."
if docker images | grep -q "xingtu_crm-backend"; then
    echo "✓ 后端镜像存在"
else
    echo "✗ 后端镜像不存在，需要构建"
    echo "构建后端..."
    export DOCKER_BUILDKIT=0
    docker-compose build backend
fi
echo ""

# 4. 启动后端
echo "4. 启动后端..."
docker-compose up -d backend
sleep 5
docker-compose ps backend
echo ""

# 5. 检查前端镜像
echo "5. 检查前端镜像..."
if docker images | grep -q "xingtu_crm-frontend"; then
    echo "✓ 前端镜像存在"
else
    echo "✗ 前端镜像不存在，需要构建"
    echo "构建前端（这可能需要几分钟）..."
    export DOCKER_BUILDKIT=0
    docker-compose build frontend
fi
echo ""

# 6. 启动前端
echo "6. 启动前端..."
docker-compose up -d frontend
sleep 3

# 7. 查看所有服务状态
echo ""
echo "=========================================="
echo "    所有服务状态"
echo "=========================================="
docker-compose ps

echo ""
echo "如果所有服务都运行，访问："
echo "  前端: http://your-server-ip:8080"
echo "  后端: http://your-server-ip:8000"
