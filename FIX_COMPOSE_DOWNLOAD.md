# 解决Docker Compose下载慢的问题

## 问题
从GitHub下载Docker Compose很慢（需要8小时），因为GitHub在中国内地访问速度慢。

## 解决方案

### 方案1：取消当前下载，使用已安装的插件（最快）

**好消息！** 从你的安装日志可以看到，Docker已经安装了 `docker-compose-plugin-2.27.0-1.el8.x86_64`，所以**不需要再下载**！

#### 立即操作：

1. **按 Ctrl+C 取消当前下载**

2. **检查Docker Compose是否可用**
   ```bash
   docker compose version
   ```

3. **如果可用，创建兼容别名**
   ```bash
   cat > /usr/local/bin/docker-compose <<'EOF'
   #!/bin/bash
   docker compose "$@"
   EOF
   chmod +x /usr/local/bin/docker-compose
   ```

4. **继续部署**
   ```bash
   export DOCKER_BUILDKIT=0
   docker-compose build
   docker-compose up -d
   ```

### 方案2：使用国内镜像源下载（如果方案1不行）

如果确实需要下载，使用国内镜像：

```bash
# 取消当前下载（Ctrl+C）

# 使用国内镜像下载
DOCKER_COMPOSE_VERSION="2.20.0"
curl -L "https://ghproxy.com/https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 验证安装
docker-compose --version
```

### 方案3：使用yum安装（推荐）

```bash
# 取消当前下载（Ctrl+C）

# 使用yum安装Docker Compose插件（如果还没安装）
yum install -y docker-compose-plugin

# 创建兼容别名
cat > /usr/local/bin/docker-compose <<'EOF'
#!/bin/bash
docker compose "$@"
EOF
chmod +x /usr/local/bin/docker-compose

# 验证
docker compose version
```

---

## 推荐操作步骤

**立即执行：**

```bash
# 1. 按 Ctrl+C 取消下载

# 2. 检查Docker Compose插件
docker compose version

# 3. 如果显示版本号，说明已安装，创建别名
cat > /usr/local/bin/docker-compose <<'EOF'
#!/bin/bash
docker compose "$@"
EOF
chmod +x /usr/local/bin/docker-compose

# 4. 验证
docker-compose --version

# 5. 继续部署
export DOCKER_BUILDKIT=0
docker-compose build
docker-compose up -d
```

**预计时间：2分钟（而不是8小时！）**
