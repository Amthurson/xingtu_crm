# 网络问题临时解决方案

## 当前问题
服务器无法访问Docker Hub和镜像加速器，导致无法拉取镜像。

## 临时解决方案

### 方案1：使用本地已有的镜像（如果之前拉取过）

```bash
# 检查本地是否有镜像
docker images | grep -E "python|node|postgres|nginx"

# 如果有，直接启动
docker-compose up -d
```

### 方案2：从其他机器导出镜像并导入

如果你在其他机器（如本地开发机）上已经有这些镜像：

#### 在本地机器上：
```bash
# 导出镜像
docker save python:3.11-slim > python.tar
docker save node:18-alpine > node.tar
docker save postgres:15-alpine > postgres.tar
docker save nginx:alpine > nginx.tar
```

#### 上传到服务器：
```bash
# 使用scp上传
scp *.tar root@your-server-ip:/tmp/
```

#### 在服务器上：
```bash
# 导入镜像
docker load < /tmp/python.tar
docker load < /tmp/node.tar
docker load < /tmp/postgres.tar
docker load < /tmp/nginx.tar

# 启动服务
docker-compose up -d
```

### 方案3：修改docker-compose.yml使用本地构建（不依赖外部镜像）

创建一个不依赖外部镜像的版本（但这需要修改Dockerfile）。

### 方案4：检查并修复网络

```bash
# 1. 检查DNS
cat /etc/resolv.conf

# 2. 测试网络连接
ping -c 3 8.8.8.8
ping -c 3 docker.mirrors.ustc.edu.cn

# 3. 检查防火墙
systemctl status firewalld
# 如果需要，临时关闭防火墙测试
systemctl stop firewalld
# 测试后记得开启
systemctl start firewalld

# 4. 检查路由
ip route
```

### 方案5：使用代理（如果有）

如果有HTTP代理可用：

```bash
# 配置Docker使用代理
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://proxy-ip:port"
Environment="HTTPS_PROXY=http://proxy-ip:port"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF

systemctl daemon-reload
systemctl restart docker
```

## 推荐操作

1. **先检查本地是否有镜像**
   ```bash
   docker images
   ```

2. **如果有镜像，直接启动**
   ```bash
   docker-compose up -d
   ```

3. **如果没有镜像，尝试从本地导出导入**（方案2）

4. **或者联系服务器提供商检查网络配置**
