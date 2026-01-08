# 网络连接问题解决方案

## 问题描述

无法从Docker Hub拉取镜像，错误信息：
```
failed to resolve source metadata for docker.io/library/python:3.11-slim
dial tcp: connectex: A connection attempt failed
```

## 解决方案（按优先级）

### 方案1：配置Docker镜像加速器（最推荐）

#### 步骤1：运行配置脚本
```powershell
.\setup-docker-mirror.ps1
```

#### 步骤2：手动配置（如果脚本无法自动配置）

1. 打开Docker Desktop
2. 点击设置图标（⚙️）
3. 进入 **Docker Engine**
4. 在JSON配置中添加：
```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
```
5. 点击 **Apply & Restart**
6. 等待Docker Desktop完全重启

#### 步骤3：验证配置
```powershell
docker info | Select-String -Pattern "Registry Mirrors"
```

应该看到镜像源列表，如果为空，说明配置未生效。

#### 步骤4：先拉取基础镜像
```powershell
.\pull-images-first.ps1
```

这个脚本会尝试从镜像加速器拉取所需的基础镜像。

#### 步骤5：构建服务
```powershell
docker-compose up -d --build
```

### 方案2：使用代理（如果有HTTP代理）

如果你有HTTP代理可用：

1. **在Docker Desktop中配置代理**
   - 打开Docker Desktop设置
   - 进入 **Resources** → **Proxies**
   - 配置HTTP/HTTPS代理

2. **或在PowerShell中设置环境变量**
   ```powershell
   $env:HTTP_PROXY="http://proxy.example.com:8080"
   $env:HTTPS_PROXY="http://proxy.example.com:8080"
   docker-compose up -d --build
   ```

### 方案3：手动拉取镜像（如果方案1失败）

如果镜像加速器配置后仍然无法拉取，可以尝试：

1. **使用其他镜像源拉取**
   ```powershell
   # 尝试从阿里云拉取
   docker pull registry.cn-hangzhou.aliyuncs.com/acs/python:3.11-slim
   docker pull registry.cn-hangzhou.aliyuncs.com/acs/node:18-alpine
   docker pull registry.cn-hangzhou.aliyuncs.com/acs/postgres:15-alpine
   docker pull registry.cn-hangzhou.aliyuncs.com/acs/nginx:alpine
   ```

2. **重命名镜像**
   ```powershell
   docker tag registry.cn-hangzhou.aliyuncs.com/acs/python:3.11-slim python:3.11-slim
   docker tag registry.cn-hangzhou.aliyuncs.com/acs/node:18-alpine node:18-alpine
   docker tag registry.cn-hangzhou.aliyuncs.com/acs/postgres:15-alpine postgres:15-alpine
   docker tag registry.cn-hangzhou.aliyuncs.com/acs/nginx:alpine nginx:alpine
   ```

3. **然后构建**
   ```powershell
   docker-compose up -d --build
   ```

### 方案4：使用VPN或更换网络

如果以上方案都失败：
1. 使用VPN连接到可以访问Docker Hub的网络
2. 或更换网络环境（如使用手机热点）

## 验证Docker镜像加速器配置

运行以下命令检查：
```powershell
docker info | Select-String -Pattern "Registry Mirrors"
```

如果输出为空，说明镜像加速器未配置或未生效。

## 测试镜像拉取

配置镜像加速器后，测试是否生效：
```powershell
docker pull hello-world
```

如果成功，说明配置正确。

## 常见问题

### Q: 配置镜像加速器后仍然失败？
A: 
1. 确保已重启Docker Desktop
2. 检查镜像源是否可用（尝试访问镜像源URL）
3. 尝试使用其他镜像源
4. 检查防火墙设置

### Q: 如何查看当前使用的镜像源？
A:
```powershell
docker info | Select-String -Pattern "Registry"
```

### Q: 可以同时使用多个镜像源吗？
A: 可以，Docker会按顺序尝试。

## 推荐的镜像源（按优先级）

1. **中科大镜像**：`https://docker.mirrors.ustc.edu.cn`（推荐）
2. **网易镜像**：`https://hub-mirror.c.163.com`
3. **百度云镜像**：`https://mirror.baidubce.com`
4. **阿里云镜像**：需要登录获取个人地址

## 快速操作流程

```powershell
# 1. 配置镜像加速器
.\setup-docker-mirror.ps1

# 2. 重启Docker Desktop（手动）

# 3. 先拉取基础镜像
.\pull-images-first.ps1

# 4. 构建并启动服务
docker-compose up -d --build
```

