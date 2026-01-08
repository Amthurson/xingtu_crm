# 上传项目到服务器的PowerShell脚本

param(
    [Parameter(Mandatory=$true)]
    [string]$ServerIP,
    
    [Parameter(Mandatory=$false)]
    [string]$ServerUser = "root",
    
    [Parameter(Mandatory=$false)]
    [string]$RemotePath = "/opt/xingtu_crm"
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    上传项目到服务器" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 检查scp是否可用
if (-not (Get-Command scp -ErrorAction SilentlyContinue)) {
    Write-Host "错误: 未找到scp命令" -ForegroundColor Red
    Write-Host "请安装OpenSSH客户端或使用其他上传方式" -ForegroundColor Yellow
    exit 1
}

# 创建临时压缩文件
$tempZip = "xingtu_crm_upload.zip"
Write-Host "正在压缩项目文件..." -ForegroundColor Yellow

# 排除不需要上传的文件
$excludeItems = @(
    "node_modules",
    "__pycache__",
    "*.pyc",
    ".git",
    ".venv",
    "venv",
    "dist",
    ".env",
    "*.log"
)

# 使用PowerShell压缩（需要排除的文件）
$items = Get-ChildItem -Path . -Exclude $excludeItems
Compress-Archive -Path $items -DestinationPath $tempZip -Force

if ($LASTEXITCODE -ne 0) {
    Write-Host "压缩失败！" -ForegroundColor Red
    exit 1
}

Write-Host "✓ 压缩完成: $tempZip" -ForegroundColor Green
Write-Host ""

# 上传文件
Write-Host "正在上传到服务器..." -ForegroundColor Yellow
Write-Host "服务器: ${ServerUser}@${ServerIP}" -ForegroundColor Cyan
Write-Host "目标路径: ${RemotePath}" -ForegroundColor Cyan
Write-Host ""

# 先创建远程目录
ssh "${ServerUser}@${ServerIP}" "mkdir -p ${RemotePath}"

# 上传压缩文件
scp $tempZip "${ServerUser}@${ServerIP}:${RemotePath}/xingtu_crm.zip"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 上传成功！" -ForegroundColor Green
    Write-Host ""
    
    # 在服务器上解压
    Write-Host "正在解压文件..." -ForegroundColor Yellow
    ssh "${ServerUser}@${ServerIP}" "cd ${RemotePath} && unzip -o xingtu_crm.zip && rm xingtu_crm.zip && chmod +x deploy.sh backup.sh"
    
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "    上传完成！" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "现在可以在服务器上运行部署脚本：" -ForegroundColor Yellow
    Write-Host "  ssh ${ServerUser}@${ServerIP}" -ForegroundColor White
    Write-Host "  cd ${RemotePath}" -ForegroundColor White
    Write-Host "  ./deploy.sh" -ForegroundColor White
} else {
    Write-Host "上传失败！" -ForegroundColor Red
}

# 清理临时文件
Remove-Item $tempZip -ErrorAction SilentlyContinue
