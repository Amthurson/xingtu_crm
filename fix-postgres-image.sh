#!/bin/bash
# 修复PostgreSQL镜像拉取问题

echo "=========================================="
echo "    修复PostgreSQL镜像拉取"
echo "=========================================="
echo ""

# 1. 完全重启Docker
echo "1. 重启Docker..."
systemctl stop docker.socket docker.service
sleep 2
systemctl start docker
sleep 5

# 2. 尝试从镜像加速器拉取postgres镜像
echo ""
echo "2. 尝试拉取postgres:15-alpine镜像..."
echo "   这可能需要几分钟，请耐心等待..."

# 设置较长的超时时间
timeout 300 docker pull postgres:15-alpine

if [ $? -eq 0 ]; then
    echo "✓ postgres镜像拉取成功"
else
    echo "✗ postgres镜像拉取失败"
    echo ""
    echo "尝试其他方法..."
    
    # 方法2：检查是否有缓存的镜像
    if docker images | grep -q "postgres.*15-alpine"; then
        echo "✓ 发现本地已有postgres镜像"
    else
        echo "✗ 本地没有postgres镜像"
        echo ""
        echo "建议："
        echo "1. 检查网络连接"
        echo "2. 尝试使用VPN或代理"
        echo "3. 或者手动从其他源获取镜像"
    fi
fi

# 3. 同样拉取其他需要的镜像
echo ""
echo "3. 拉取其他基础镜像..."
for image in "python:3.11-slim" "node:18-alpine" "nginx:alpine"; do
    echo -n "拉取 $image ... "
    timeout 180 docker pull $image 2>&1 | tail -1 || echo "失败（将在构建时重试）"
done

echo ""
echo "=========================================="
echo "如果postgres镜像拉取成功，现在可以运行："
echo "  docker-compose up -d"
echo "=========================================="
