# 快速启动指南

## 问题诊断

如果遇到网络连接问题，请按以下步骤操作：

### 步骤1：配置Docker镜像加速器

**方法1：使用自动配置脚本（推荐）**
```powershell
.\setup-docker-mirror.ps1
```
然后重启Docker Desktop

**方法2：手动配置**
1. 打开Docker Desktop
2. 设置 → Docker Engine
3. 添加以下配置：
```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
```
4. 点击 Apply & Restart

### 步骤2：重新启动服务

配置完成后，运行：
```powershell
docker-compose up -d --build
```

## 已优化的配置

我已经修改了Dockerfile，使用国内镜像源：
- ✅ Python包：自动使用清华镜像源
- ✅ Node包：自动使用淘宝镜像源  
- ✅ Debian包：自动使用阿里云镜像源

即使没有配置Docker镜像加速器，构建时也会使用国内镜像源加速。

## 验证网络连接

```powershell
# 测试连接
docker pull hello-world
```

如果成功，说明网络配置正确。

## 完整启动流程

```powershell
# 1. 配置镜像加速器（首次运行）
.\setup-docker-mirror.ps1

# 2. 重启Docker Desktop（如果配置了镜像加速器）

# 3. 启动服务
.\start.bat

# 或直接使用
docker-compose up -d --build
```

## 仍然无法连接？

如果仍然无法连接，请：
1. 检查防火墙设置
2. 检查公司网络策略
3. 尝试使用VPN或代理
4. 参考 NETWORK_SETUP.md 获取更多解决方案

