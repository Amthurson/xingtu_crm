# 快速部署指南（中国内地）

## 最简单的方式：直接上传文件

### 步骤1：在本地压缩项目

#### Windows PowerShell
```powershell
# 在项目根目录执行
.\upload-to-server.ps1 -ServerIP "your-server-ip"
```

或者手动压缩：
```powershell
# 排除不需要的文件
Compress-Archive -Path * -DestinationPath xingtu_crm.zip -Exclude "node_modules","__pycache__",".git",".venv","dist"
```

#### Linux/Mac
```bash
# 排除不需要的文件
zip -r xingtu_crm.zip . -x "node_modules/*" "__pycache__/*" ".git/*" ".venv/*" "dist/*"
```

### 步骤2：上传到服务器

#### 使用scp
```bash
scp xingtu_crm.zip root@your-server-ip:/opt/
```

#### 使用FTP工具
- FileZilla
- WinSCP
- XFTP

### 步骤3：在服务器上解压和部署

```bash
# SSH连接到服务器
ssh root@your-server-ip

# 解压文件
cd /opt
unzip xingtu_crm.zip -d xingtu_crm
cd xingtu_crm

# 设置执行权限
chmod +x deploy.sh backup.sh

# 一键部署
./deploy.sh
```

---

## 使用Git克隆（如果配置了SSH密钥）

### 公开仓库
```bash
git clone https://github.com/Amthurson/xingtu_crm.git
cd xingtu_crm
chmod +x deploy.sh backup.sh
./deploy.sh
```

### 私有仓库 - 使用HTTPS + 访问令牌

1. **创建GitHub访问令牌**
   - 访问：https://github.com/settings/tokens
   - 生成新令牌，勾选 `repo` 权限

2. **克隆仓库**
   ```bash
   git clone https://YOUR_TOKEN@github.com/Amthurson/xingtu_crm.git
   cd xingtu_crm
   chmod +x deploy.sh backup.sh
   ./deploy.sh
   ```

### 私有仓库 - 配置SSH密钥

```bash
# 1. 生成SSH密钥
ssh-keygen -t ed25519 -C "your_email@example.com"

# 2. 查看公钥
cat ~/.ssh/id_ed25519.pub

# 3. 复制公钥到GitHub
# 访问：https://github.com/settings/keys
# 添加新的SSH密钥

# 4. 测试连接
ssh -T git@github.com

# 5. 克隆仓库
git clone git@github.com:Amthurson/xingtu_crm.git
cd xingtu_crm
chmod +x deploy.sh backup.sh
./deploy.sh
```

---

## 推荐流程（最快）

1. **在本地压缩项目**
   ```powershell
   .\upload-to-server.ps1 -ServerIP "your-server-ip"
   ```

2. **或者手动上传**
   - 压缩项目文件
   - 使用FTP工具上传到服务器

3. **在服务器上部署**
   ```bash
   cd /opt/xingtu_crm
   ./deploy.sh
   ```

**预计时间：10-15分钟**
