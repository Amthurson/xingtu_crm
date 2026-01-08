# Git仓库克隆问题解决方案

## 问题
```
Permission denied (publickey)
```

这是因为服务器没有配置SSH密钥，或者没有访问权限。

## 解决方案

### 方案1：使用HTTPS克隆（最简单，推荐）

```bash
# 使用HTTPS方式克隆（需要输入GitHub用户名和密码/访问令牌）
git clone https://github.com/Amthurson/xingtu_crm.git
```

如果仓库是私有的，需要：
1. 使用GitHub访问令牌（Personal Access Token）
2. 或者配置SSH密钥

### 方案2：配置SSH密钥（适合长期使用）

#### 步骤1：生成SSH密钥
```bash
# 生成SSH密钥对
ssh-keygen -t ed25519 -C "your_email@example.com"
# 按回车使用默认路径，可以设置密码或留空

# 查看公钥
cat ~/.ssh/id_ed25519.pub
```

#### 步骤2：添加SSH密钥到GitHub
1. 复制公钥内容（上面cat命令的输出）
2. 访问：https://github.com/settings/keys
3. 点击 "New SSH key"
4. 粘贴公钥内容
5. 保存

#### 步骤3：测试连接
```bash
ssh -T git@github.com
# 应该看到：Hi Amthurson! You've successfully authenticated...
```

#### 步骤4：克隆仓库
```bash
git clone git@github.com:Amthurson/xingtu_crm.git
```

### 方案3：使用GitHub访问令牌（适合私有仓库）

#### 步骤1：创建访问令牌
1. 访问：https://github.com/settings/tokens
2. 点击 "Generate new token" → "Generate new token (classic)"
3. 设置权限：至少勾选 `repo`
4. 生成并复制令牌

#### 步骤2：使用令牌克隆
```bash
# 方式1：在URL中包含令牌（不推荐，会暴露在历史记录中）
git clone https://YOUR_TOKEN@github.com/Amthurson/xingtu_crm.git

# 方式2：使用Git凭据助手（推荐）
git clone https://github.com/Amthurson/xingtu_crm.git
# 用户名：你的GitHub用户名
# 密码：输入访问令牌（不是GitHub密码）
```

### 方案4：直接上传文件（最快，适合一次性部署）

如果不想配置Git，可以直接上传文件：

#### 在本地压缩项目
```bash
# Windows PowerShell
Compress-Archive -Path .\xingtu_crm -DestinationPath xingtu_crm.zip
```

#### 上传到服务器
```bash
# 使用scp上传
scp xingtu_crm.zip root@your-server-ip:/opt/

# 在服务器上解压
ssh root@your-server-ip
cd /opt
unzip xingtu_crm.zip
cd xingtu_crm
```

---

## 推荐方案

**对于快速部署，推荐使用方案1（HTTPS）或方案4（直接上传）**

如果仓库是公开的，直接使用：
```bash
git clone https://github.com/Amthurson/xingtu_crm.git
```

如果仓库是私有的，使用方案3（访问令牌）或方案2（SSH密钥）。
