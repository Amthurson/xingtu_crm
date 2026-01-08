#!/bin/bash
# 修复版部署脚本 - 解决镜像加速器问题

set -e

echo "=========================================="
echo "    星图CRM系统 - 修复版部署脚本"
echo "=========================================="
echo ""

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then 
    echo "请使用root用户运行此脚本"
    exit 1
fi

# 检查Docker
if ! command -v docker &> /dev/null; then
    echo "错误: Docker未安装，请先安装Docker"
    exit 1
fi

# 检查Docker Compose
if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
    echo "错误: Docker Compose未安装"
    exit 1
fi

# 创建docker-compose别名
if [ ! -x /usr/local/bin/docker-compose ]; then
    cat > /usr/local/bin/docker-compose <<'EOF'
#!/bin/bash
docker compose "$@"
EOF
    chmod +x /usr/local/bin/docker-compose
fi

# 配置镜像加速器并完全重启
echo "配置Docker镜像加速器..."
mkdir -p /etc/docker
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

# 完全重启Docker
echo "重启Docker服务..."
systemctl daemon-reload
systemctl stop docker
sleep 2
systemctl start docker
sleep 5

# 验证镜像加速器
echo "验证镜像加速器配置..."
docker info | grep -A 10 "Registry Mirrors" || echo "警告: 无法验证镜像加速器"

# 测试镜像加速器是否工作
echo ""
echo "测试镜像加速器..."
if timeout 30 docker pull hello-world &>/dev/null; then
    echo "✓ 镜像加速器工作正常"
    docker rmi hello-world &>/dev/null || true
else
    echo "⚠ 镜像加速器可能无法访问，将尝试其他方法"
fi

# 检查项目目录
if [ ! -f "docker-compose.yml" ]; then
    echo "错误: 未找到docker-compose.yml"
    exit 1
fi

# 构建服务（使用传统模式，禁用BuildKit）
echo ""
echo "构建服务（使用传统构建模式）..."
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

# 尝试构建，如果失败则提供替代方案
if docker-compose build 2>&1 | tee /tmp/build.log; then
    echo "✓ 构建成功"
else
    echo ""
    echo "构建失败，可能原因："
    echo "1. 网络无法访问镜像加速器"
    echo "2. 镜像加速器配置未生效"
    echo ""
    echo "建议："
    echo "1. 检查网络连接: curl -I https://docker.mirrors.ustc.edu.cn/v2/"
    echo "2. 尝试使用VPN或代理"
    echo "3. 联系服务器提供商检查网络配置"
    exit 1
fi

# 启动服务
echo ""
echo "启动服务..."
docker-compose up -d

# 等待服务启动
sleep 5

# 检查服务状态
echo ""
echo "=========================================="
echo "          服务状态"
echo "=========================================="
docker-compose ps

# 获取服务器IP
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || hostname -I | awk '{print $1}')

echo ""
echo "=========================================="
echo "          部署完成！"
echo "=========================================="
echo "前端界面: http://${SERVER_IP}:8080"
echo "后端API:  http://${SERVER_IP}:8000"
echo "API文档:  http://${SERVER_IP}:8000/docs"
echo ""
echo "查看日志: docker-compose logs -f"
echo "停止服务: docker-compose down"
echo "=========================================="
