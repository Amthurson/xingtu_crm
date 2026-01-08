# 解决镜像加速器不生效的问题

## 问题
镜像加速器已配置，但Docker仍然尝试从 `registry-1.docker.io` 拉取镜像，导致超时。

## 原因
1. Docker配置后需要完全重启
2. 某些情况下，Docker BuildKit可能绕过镜像加速器
3. 网络问题导致无法连接到镜像加速器

## 解决方案

### 方案1：完全重启Docker并验证（推荐）

```bash
# 1. 停止所有容器
docker stop $(docker ps -aq) 2>/dev/null || true

# 2. 重启Docker
systemctl stop docker
systemctl start docker
sleep 5

# 3. 验证镜像加速器
docker info | grep -A 10 "Registry Mirrors"

# 4. 测试拉取
docker pull hello-world

# 5. 如果成功，使用传统构建模式（禁用BuildKit）
export DOCKER_BUILDKIT=0
docker-compose build
```

### 方案2：使用pull: false，让构建时自动拉取

修改 `docker-compose.yml`，确保 `pull: false`：

```yaml
backend:
  build:
    context: ./backend
    pull: false  # 不强制拉取，使用本地镜像
```

然后：
```bash
export DOCKER_BUILDKIT=0
docker-compose build
```

### 方案3：手动从镜像加速器拉取镜像

```bash
# 重启Docker
systemctl restart docker
sleep 5

# 尝试拉取（会使用镜像加速器）
docker pull python:3.11-slim
docker pull node:18-alpine
docker pull postgres:15-alpine
docker pull nginx:alpine

# 如果成功，继续构建
export DOCKER_BUILDKIT=0
docker-compose build
```

### 方案4：使用代理（如果有）

如果有HTTP代理：

```bash
# 创建Docker代理配置
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:8080"
Environment="HTTPS_PROXY=http://proxy.example.com:8080"
EOF

systemctl daemon-reload
systemctl restart docker
```

### 方案5：检查镜像加速器是否真的可用

```bash
# 测试镜像加速器连接
curl -I https://docker.mirrors.ustc.edu.cn/v2/
curl -I https://hub-mirror.c.163.com/v2/
curl -I https://mirror.baidubce.com/v2/
```

如果都超时，可能是网络问题。

## 快速修复命令

```bash
# 1. 完全重启Docker
systemctl stop docker
systemctl start docker
sleep 5

# 2. 验证配置
docker info | grep -A 10 "Registry Mirrors"

# 3. 禁用BuildKit并构建
export DOCKER_BUILDKIT=0
docker-compose build --pull=false

# 4. 如果构建时拉取镜像失败，尝试手动拉取
docker pull python:3.11-slim || echo "拉取失败，将在构建时重试"
```

## 如果所有方法都失败

可以考虑：
1. 使用VPN或代理
2. 更换网络环境
3. 使用其他镜像加速器（如阿里云个人镜像地址）
4. 联系服务器提供商检查网络配置
