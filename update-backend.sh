#!/bin/bash
# 更新后端服务

echo "=========================================="
echo "    更新后端服务"
echo "=========================================="
echo ""

# 检查是否在项目目录
if [ ! -f "docker-compose.yml" ]; then
    echo "错误: 请在项目根目录运行此脚本"
    exit 1
fi

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then 
    echo "警告: 建议使用root用户运行此脚本"
fi

# 1. 拉取最新代码
echo "步骤1: 拉取最新代码..."
if [ -d ".git" ]; then
    git pull
    if [ $? -ne 0 ]; then
        echo "警告: git pull 失败，继续使用当前代码"
    fi
else
    echo "警告: 未找到.git目录，跳过代码更新"
fi

# 2. 停止后端服务
echo ""
echo "步骤2: 停止后端服务..."
docker-compose stop backend

# 3. 重新构建后端镜像
echo ""
echo "步骤3: 重新构建后端镜像..."
export DOCKER_BUILDKIT=0
docker-compose build backend

if [ $? -ne 0 ]; then
    echo "✗ 构建失败"
    echo "尝试启动旧版本..."
    docker-compose start backend
    exit 1
fi

# 4. 启动后端服务
echo ""
echo "步骤4: 启动后端服务..."
docker-compose up -d backend

# 5. 等待服务启动
echo ""
echo "步骤5: 等待服务启动..."
sleep 5

# 6. 检查服务状态
echo ""
echo "步骤6: 检查服务状态..."
docker-compose ps backend

# 7. 检查健康状态
echo ""
echo "步骤7: 检查后端健康状态..."
sleep 3
if curl -s http://localhost:8000/docs > /dev/null; then
    echo "✓ 后端服务运行正常"
else
    echo "⚠ 后端服务可能未完全启动，请检查日志:"
    echo "  docker-compose logs backend"
fi

echo ""
echo "=========================================="
echo "          更新完成！"
echo "=========================================="
echo ""
echo "查看日志: docker-compose logs -f backend"
echo "重启服务: docker-compose restart backend"
echo "=========================================="
