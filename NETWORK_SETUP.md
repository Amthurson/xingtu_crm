# 网络配置指南

## 问题说明

如果遇到以下错误：
```
failed to resolve source metadata for docker.io/library/python:3.11-slim
dial tcp: connectex: A connection attempt failed
```

这通常是因为无法连接到Docker Hub，需要配置镜像加速器。

## 解决方案

### 方案1：配置Docker镜像加速器（推荐）

#### Windows Docker Desktop

1. **使用自动配置脚本**（推荐）
   ```powershell
   .\setup-docker-mirror.ps1
   ```
   然后重启Docker Desktop

2. **手动配置**
   - 打开Docker Desktop
   - 点击设置图标（⚙️）
   - 进入 **Docker Engine**
   - 在JSON配置中添加：
   ```json
   {
     "registry-mirrors": [
       "https://docker.mirrors.ustc.edu.cn",
       "https://hub-mirror.c.163.com",
       "https://mirror.baidubce.com"
     ]
   }
   ```
   - 点击 **Apply & Restart**

3. **验证配置**
   ```powershell
   docker info | Select-String -Pattern "Registry Mirrors"
   ```

#### 国内常用镜像源

- 中科大：`https://docker.mirrors.ustc.edu.cn`
- 网易：`https://hub-mirror.c.163.com`
- 百度云：`https://mirror.baidubce.com`
- 阿里云（需要登录）：`https://your-id.mirror.aliyuncs.com`

### 方案2：使用代理

如果你有HTTP代理：

1. **在Docker Desktop中配置代理**
   - 打开Docker Desktop设置
   - 进入 **Resources** → **Proxies**
   - 配置HTTP/HTTPS代理

2. **在PowerShell中配置环境变量**
   ```powershell
   $env:HTTP_PROXY="http://proxy.example.com:8080"
   $env:HTTPS_PROXY="http://proxy.example.com:8080"
   docker-compose up -d
   ```

### 方案3：使用已修改的Dockerfile（已配置国内镜像源）

我已经修改了Dockerfile，使用国内镜像源：
- Python包：使用清华镜像源
- Node包：使用淘宝镜像源
- Debian包：使用阿里云镜像源

直接运行：
```powershell
docker-compose up -d
```

### 方案4：离线构建（如果网络完全无法访问）

1. **在其他机器上拉取镜像**
   ```bash
   docker pull python:3.11-slim
   docker pull node:18-alpine
   docker pull postgres:15-alpine
   docker pull nginx:alpine
   ```

2. **导出镜像**
   ```bash
   docker save python:3.11-slim > python.tar
   docker save node:18-alpine > node.tar
   docker save postgres:15-alpine > postgres.tar
   docker save nginx:alpine > nginx.tar
   ```

3. **在目标机器上导入**
   ```powershell
   docker load < python.tar
   docker load < node.tar
   docker load < postgres.tar
   docker load < nginx.tar
   ```

## 验证网络连接

### 测试Docker Hub连接
```powershell
# 测试连接
Test-NetConnection registry-1.docker.io -Port 443

# 或使用curl
curl -I https://registry-1.docker.io
```

### 测试镜像加速器
```powershell
# 拉取测试镜像
docker pull hello-world

# 如果成功，说明镜像加速器配置正确
```

## 常见问题

### Q: 配置镜像加速器后仍然无法连接
A: 
1. 确保已重启Docker Desktop
2. 尝试使用其他镜像源
3. 检查防火墙设置
4. 检查公司网络策略

### Q: 如何查看当前使用的镜像源？
A:
```powershell
docker info | Select-String -Pattern "Registry"
```

### Q: 如何清除Docker缓存？
A:
```powershell
docker system prune -a
```

## 推荐的镜像源组合

对于中国大陆用户，推荐使用：
```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
```

## 下一步

配置完成后，重新运行：
```powershell
docker-compose up -d --build
```

