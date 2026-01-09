# 使用宿主服务器Nginx部署指南

## 方案说明

直接在宿主服务器上使用Nginx部署前端，而不是使用Docker容器。这样可以：
- ✅ 更简单的部署
- ✅ 更好的性能
- ✅ 更容易管理
- ✅ 后端仍然使用Docker

## 部署步骤

### 方法1：使用自动化脚本（推荐）

#### 在本地执行：
```powershell
.\upload-and-deploy-nginx.ps1 -ServerIP "your-server-ip"
```

#### 在服务器上执行：
```bash
cd /opt/xingtu_crm
chmod +x deploy-nginx-host.sh
./deploy-nginx-host.sh
```

### 方法2：手动部署

#### 步骤1：上传文件到服务器
```powershell
# 压缩dist
Compress-Archive -Path frontend\dist -DestinationPath frontend-dist.zip

# 上传
scp frontend-dist.zip root@your-server-ip:/opt/xingtu_crm/frontend/
scp nginx-host.conf root@your-server-ip:/opt/xingtu_crm/
```

#### 步骤2：在服务器上部署
```bash
# 解压前端文件
cd /opt/xingtu_crm/frontend
unzip -o frontend-dist.zip

# 安装nginx（如果未安装）
yum install -y nginx  # CentOS/RHEL
# 或
apt-get install -y nginx  # Ubuntu/Debian

# 复制nginx配置
cp nginx-host.conf /etc/nginx/conf.d/xingtu_crm.conf

# 测试配置
nginx -t

# 重载nginx
systemctl reload nginx
```

## Nginx配置说明

配置文件：`nginx-host.conf`

### 主要配置：
- **前端静态文件**：`/opt/xingtu_crm/frontend/dist`
- **后端API代理**：`http://localhost:8000`
- **API文档**：`/docs` 和 `/openapi.json`

### 访问地址：
- 前端：`http://your-server-ip`
- API文档：`http://your-server-ip/docs`
- API：`http://your-server-ip/api/`

## 确保后端运行

```bash
# 检查后端状态
docker-compose ps backend

# 如果未运行，启动后端
docker-compose up -d backend postgres
```

## 防火墙配置

确保开放80端口：

```bash
# CentOS/RHEL
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

# Ubuntu/Debian
ufw allow 80/tcp
```

## 自定义域名

编辑 `/etc/nginx/conf.d/xingtu_crm.conf`：

```nginx
server_name your-domain.com www.your-domain.com;
```

然后配置SSL（可选）：

```bash
# 使用Let's Encrypt
certbot --nginx -d your-domain.com
```

## 文件结构

```
/opt/xingtu_crm/
├── frontend/
│   └── dist/          # 前端构建文件
├── backend/           # 后端代码（Docker）
├── nginx-host.conf    # Nginx配置
└── deploy-nginx-host.sh  # 部署脚本
```

## 优势

- ✅ 前端直接由Nginx服务，性能更好
- ✅ 后端使用Docker，便于管理
- ✅ 配置简单，易于维护
- ✅ 可以轻松配置SSL和域名

## 故障排查

### 检查Nginx状态
```bash
systemctl status nginx
nginx -t
```

### 查看日志
```bash
tail -f /var/log/nginx/xingtu_crm_error.log
tail -f /var/log/nginx/xingtu_crm_access.log
```

### 检查后端连接
```bash
curl http://localhost:8000/docs
```
