#!/bin/bash
# 手动构建脚本 - 逐步执行，便于排查问题

echo "=========================================="
echo "    手动构建脚本"
echo "=========================================="
echo ""

# 1. 完全重启Docker
echo "步骤1: 重启Docker..."
systemctl stop docker
sleep 2
systemctl start docker
sleep 5
echo "✓ Docker已重启"

# 2. 验证镜像加速器
echo ""
echo "步骤2: 验证镜像加速器..."
docker info | grep -A 10 "Registry Mirrors"

# 3. 测试网络连接
echo ""
echo "步骤3: 测试镜像加速器连接..."
for mirror in "https://docker.mirrors.ustc.edu.cn" "https://hub-mirror.c.163.com" "https://mirror.baidubce.com"; do
    echo -n "测试 $mirror ... "
    if curl -I --connect-timeout 5 "$mirror/v2/" &>/dev/null; then
        echo "✓ 可访问"
    else
        echo "✗ 无法访问"
    fi
done

# 4. 尝试拉取测试镜像
echo ""
echo "步骤4: 测试拉取hello-world镜像..."
if timeout 30 docker pull hello-world 2>&1 | tail -3; then
    echo "✓ 镜像拉取成功，镜像加速器工作正常"
    docker rmi hello-world &>/dev/null || true
else
    echo "✗ 镜像拉取失败"
    echo ""
    echo "可能的原因："
    echo "1. 服务器网络无法访问镜像加速器"
    echo "2. 防火墙阻止了连接"
    echo "3. DNS解析问题"
    echo ""
    echo "建议："
    echo "1. 检查服务器防火墙设置"
    echo "2. 尝试使用其他网络环境"
    echo "3. 联系服务器提供商"
    exit 1
fi

# 5. 构建服务
echo ""
echo "步骤5: 构建服务..."
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

echo "开始构建后端..."
docker-compose build backend

echo ""
echo "开始构建前端..."
docker-compose build frontend

# 6. 启动服务
echo ""
echo "步骤6: 启动服务..."
docker-compose up -d

# 7. 查看状态
echo ""
echo "=========================================="
echo "          服务状态"
echo "=========================================="
docker-compose ps

echo ""
echo "构建完成！"
