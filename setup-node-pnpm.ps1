# 设置Node.js和pnpm环境

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    设置Node.js和pnpm环境" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 检查nvm是否安装
if (-not (Get-Command nvm -ErrorAction SilentlyContinue)) {
    Write-Host "nvm未安装，请先安装nvm-windows:" -ForegroundColor Yellow
    Write-Host "1. 下载: https://github.com/coreybutler/nvm-windows/releases" -ForegroundColor White
    Write-Host "2. 安装nvm-setup.exe" -ForegroundColor White
    Write-Host "3. 重新打开PowerShell后运行此脚本" -ForegroundColor White
    exit 1
}

Write-Host "步骤1: 安装Node.js 24.3.0..." -ForegroundColor Yellow
nvm install 24.3.0
if ($LASTEXITCODE -ne 0) {
    Write-Host "安装失败，尝试使用最新版本..." -ForegroundColor Yellow
    nvm install latest
}

Write-Host ""
Write-Host "步骤2: 切换到Node.js 24.3.0..." -ForegroundColor Yellow
nvm use 24.3.0
if ($LASTEXITCODE -ne 0) {
    Write-Host "切换失败，尝试使用最新版本..." -ForegroundColor Yellow
    nvm use latest
}

Write-Host ""
Write-Host "步骤3: 验证Node.js版本..." -ForegroundColor Yellow
$nodeVersion = node --version
Write-Host "Node.js版本: $nodeVersion" -ForegroundColor Green

Write-Host ""
Write-Host "步骤4: 安装pnpm..." -ForegroundColor Yellow
if (Get-Command pnpm -ErrorAction SilentlyContinue) {
    Write-Host "pnpm已安装" -ForegroundColor Green
    pnpm --version
} else {
    Write-Host "正在安装pnpm..." -ForegroundColor Cyan
    npm install -g pnpm
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ pnpm安装成功" -ForegroundColor Green
        pnpm --version
    } else {
        Write-Host "✗ pnpm安装失败" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    环境设置完成！" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "现在可以运行:" -ForegroundColor Yellow
Write-Host "  cd frontend" -ForegroundColor White
Write-Host "  pnpm install" -ForegroundColor White
Write-Host "  pnpm run build" -ForegroundColor White
