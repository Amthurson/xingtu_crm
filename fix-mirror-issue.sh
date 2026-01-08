#!/bin/bash
# 修复镜像加速器问题

echo "=========================================="
echo "    修复Docker镜像加速器问题"
echo "=========================================="
echo ""

# 1. 检查当前配置
echo "1. 检查Docker配置..."
cat /etc/docker/daemon.json

# 2. 确保配置正确
echo ""
echo "2. 更新Docker配置..."
cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ],
  "max-concurrent-downloads": 10,
  "max-concurrent-uploads": 5
}
EOF

# 3. 重启Docker
echo ""
echo "3. 重启Docker服务..."
systemctl daemon-reload
systemctl restart docker
sleep 5

# 4. 验证配置
echo ""
echo "4. 验证镜像加速器..."
docker info | grep -A 10 "Registry Mirrors"

# 5. 测试拉取
echo ""
echo "5. 测试拉取hello-world镜像..."
timeout 30 docker pull hello-world 2>&1 | tail -5

echo ""
echo "=========================================="
echo "如果测试拉取成功，说明镜像加速器已生效"
echo "如果仍然失败，可能需要使用其他方法"
echo "=========================================="
