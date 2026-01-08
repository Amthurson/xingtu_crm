#!/bin/bash
# 快速修复脚本 - 解决镜像拉取和权限问题

echo "=========================================="
echo "    快速修复脚本"
echo "=========================================="
echo ""

# 1. 修复docker-compose权限
echo "1. 修复docker-compose权限..."
if docker compose version &> /dev/null; then
    cat > /usr/local/bin/docker-compose <<'EOF'
#!/bin/bash
docker compose "$@"
EOF
    chmod +x /usr/local/bin/docker-compose
    echo "✓ docker-compose权限已修复"
else
    echo "✗ Docker Compose插件不可用"
    exit 1
fi

# 2. 验证Docker镜像加速器
echo ""
echo "2. 验证Docker镜像加速器..."
systemctl restart docker
sleep 3
docker info | grep -A 5 "Registry Mirrors" || echo "警告: 镜像加速器可能未生效"

# 3. 测试拉取镜像（使用超时）
echo ""
echo "3. 测试拉取镜像..."
timeout 30 docker pull hello-world 2>&1 | tail -3

# 4. 如果镜像加速器不工作，尝试直接构建
echo ""
echo "4. 准备构建服务..."
export DOCKER_BUILDKIT=0

# 检查docker-compose是否可用
if docker-compose --version &> /dev/null; then
    echo "✓ docker-compose命令可用"
    echo ""
    echo "现在可以运行："
    echo "  docker-compose build"
    echo "  docker-compose up -d"
else
    echo "✗ docker-compose命令不可用，请检查"
fi
