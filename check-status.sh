#!/bin/bash
# 检查服务状态

echo "=========================================="
echo "    检查服务状态"
echo "=========================================="
echo ""

# 检查容器状态
echo "1. 容器状态:"
docker-compose ps
echo ""

# 检查镜像
echo "2. 已构建的镜像:"
docker images | grep -E "xingtu_crm|python|node|postgres|nginx" | head -10
echo ""

# 检查最近的日志
echo "3. 最近的构建日志:"
docker-compose logs --tail=20 2>&1 | tail -20
echo ""

# 检查是否有构建中的容器
echo "4. 所有容器（包括停止的）:"
docker ps -a | grep -E "xingtu_crm|postgres|backend|frontend"
echo ""

# 如果容器存在但未运行，尝试启动
if [ $(docker-compose ps -q | wc -l) -eq 0 ]; then
    echo "5. 没有运行中的容器，尝试启动..."
    docker-compose up -d
    sleep 3
    docker-compose ps
fi
