# 中国内地部署指南

## 推荐部署方案（按优先级）

### 方案1：阿里云轻量应用服务器 + Docker（最推荐）

#### 优势
- ✅ 价格便宜（约24-100元/月）
- ✅ 配置简单，开箱即用
- ✅ 国内访问速度快
- ✅ 已预装Docker
- ✅ 带宽充足（3-6Mbps）

#### 部署步骤

1. **购买轻量应用服务器**
   - 访问：https://www.aliyun.com/product/swas
   - 选择配置：2核2G或4核4G（根据数据量）
   - 系统：Ubuntu 22.04 或 CentOS 7.9
   - 地域：选择离用户最近的地域

2. **连接服务器**
   ```bash
   ssh root@your-server-ip
   ```

3. **上传项目文件**
   ```bash
   # 方式1：使用git
   git clone your-repo-url
   cd xingtu_crm
   
   # 方式2：使用scp上传
   scp -r ./xingtu_crm root@your-server-ip:/opt/
   ```

4. **配置防火墙**
   - 在阿里云控制台开放端口：8000, 8080, 5432（如需要）
   - 或使用安全组配置

5. **一键部署**
   ```bash
   cd /opt/xingtu_crm
   
   # 先拉取基础镜像（使用国内镜像源）
   ./pull-images-first.sh  # 需要先创建Linux版本
   
   # 禁用BuildKit并构建
   export DOCKER_BUILDKIT=0
   docker-compose build
   
   # 启动服务
   docker-compose up -d
   ```

6. **配置域名（可选）**
   - 在阿里云购买域名
   - 配置DNS解析到服务器IP
   - 使用Nginx反向代理（见下方配置）

#### 成本估算
- 轻量服务器：24-100元/月
- 域名：55元/年
- **总计：约30-110元/月**

---

### 方案2：腾讯云轻量应用服务器

#### 优势
- ✅ 价格与阿里云相当
- ✅ 国内访问速度快
- ✅ 配置简单

#### 部署步骤
与阿里云类似，参考方案1

---

### 方案3：阿里云容器服务 ACK（适合企业）

#### 优势
- ✅ 完全托管，无需管理服务器
- ✅ 自动扩缩容
- ✅ 高可用
- ✅ 适合生产环境

#### 劣势
- ❌ 价格较高（约200-500元/月）
- ❌ 配置相对复杂

---

### 方案4：华为云/天翼云

#### 优势
- ✅ 价格便宜
- ✅ 国内访问速度快

---

## 快速部署脚本（Linux）

创建一键部署脚本：

```bash
#!/bin/bash
# deploy.sh - 一键部署脚本

echo "=========================================="
echo "    星图CRM系统 - 一键部署"
echo "=========================================="

# 检查Docker
if ! command -v docker &> /dev/null; then
    echo "安装Docker..."
    curl -fsSL https://get.docker.com | bash
    systemctl start docker
    systemctl enable docker
fi

# 检查Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "安装Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# 拉取基础镜像
echo "拉取基础镜像..."
docker pull python:3.11-slim
docker pull node:18-alpine
docker pull postgres:15-alpine
docker pull nginx:alpine

# 构建并启动
echo "构建并启动服务..."
export DOCKER_BUILDKIT=0
docker-compose build
docker-compose up -d

echo ""
echo "部署完成！"
echo "前端: http://your-server-ip:8080"
echo "后端: http://your-server-ip:8000"
```

---

## Nginx反向代理配置（生产环境）

### 安装Nginx
```bash
# Ubuntu/Debian
apt-get update && apt-get install -y nginx

# CentOS
yum install -y nginx
```

### 配置Nginx
创建配置文件：`/etc/nginx/sites-available/xingtu_crm`

```nginx
server {
    listen 80;
    server_name your-domain.com;  # 替换为你的域名

    # 前端
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # 后端API
    location /api {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

启用配置：
```bash
ln -s /etc/nginx/sites-available/xingtu_crm /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

---

## SSL证书配置（HTTPS）

### 使用Let's Encrypt（免费）

```bash
# 安装Certbot
apt-get install -y certbot python3-certbot-nginx

# 申请证书
certbot --nginx -d your-domain.com

# 自动续期
certbot renew --dry-run
```

### 使用阿里云SSL证书（推荐国内）

1. 在阿里云购买或申请免费SSL证书
2. 下载证书文件
3. 配置Nginx使用证书

---

## 数据备份

### 自动备份脚本

创建 `backup.sh`：

```bash
#!/bin/bash
BACKUP_DIR="/opt/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# 备份数据库
docker-compose exec -T postgres pg_dump -U postgres xingtu_crm > $BACKUP_DIR/db_$DATE.sql

# 保留最近7天的备份
find $BACKUP_DIR -name "db_*.sql" -mtime +7 -delete

echo "备份完成: $BACKUP_DIR/db_$DATE.sql"
```

添加到定时任务：
```bash
crontab -e
# 每天凌晨2点备份
0 2 * * * /opt/xingtu_crm/backup.sh
```

---

## 监控和维护

### 查看日志
```bash
# 所有服务日志
docker-compose logs -f

# 特定服务日志
docker-compose logs -f backend
docker-compose logs -f frontend
```

### 重启服务
```bash
docker-compose restart
```

### 更新应用
```bash
cd /opt/xingtu_crm
git pull  # 如果使用git
docker-compose build
docker-compose up -d
```

---

## 性能优化建议

### 1. 数据库优化
- 定期清理旧数据
- 添加索引
- 配置连接池

### 2. 前端优化
- 启用Gzip压缩（Nginx已配置）
- 使用CDN加速静态资源（可选）

### 3. 服务器优化
- 定期更新系统
- 配置防火墙
- 监控资源使用

---

## 成本对比

| 方案 | 月成本 | 适用场景 |
|------|--------|----------|
| 阿里云轻量服务器 | 24-100元 | 小型应用，个人/小团队 |
| 腾讯云轻量服务器 | 24-100元 | 小型应用，个人/小团队 |
| 阿里云ECS | 100-500元 | 中型应用，企业 |
| 阿里云ACK | 200-500元 | 大型应用，企业 |
| 自建服务器 | 200-1000元 | 有运维能力 |

---

## 推荐配置

### 小型应用（<1000用户）
- **服务器**：2核2G，3Mbps带宽
- **成本**：约30元/月
- **方案**：阿里云轻量应用服务器

### 中型应用（1000-10000用户）
- **服务器**：4核4G，5Mbps带宽
- **成本**：约80元/月
- **方案**：阿里云轻量应用服务器或ECS

### 大型应用（>10000用户）
- **服务器**：8核16G，10Mbps带宽
- **成本**：约300-500元/月
- **方案**：阿里云ECS或ACK

---

## 快速开始（推荐）

1. **购买阿里云轻量应用服务器**（2核2G，约30元/月）
2. **上传项目文件**
3. **运行部署脚本**
4. **配置域名和SSL**（可选）
5. **完成！**

**预计部署时间：30分钟**
