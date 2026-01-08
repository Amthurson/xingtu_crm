# 分步构建脚本 - 用于解决Docker Compose构建问题

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      达人老师CRM系统 - 分步构建脚本" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 检查Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "错误: 未检测到Docker" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Docker环境检查通过" -ForegroundColor Green
Write-Host ""

# 1. 构建后端镜像
Write-Host "正在构建后端镜像..." -ForegroundColor Yellow
Set-Location backend
docker build -t xingtu_crm-backend .
if ($LASTEXITCODE -ne 0) {
    Write-Host "后端构建失败！" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✓ 后端构建成功" -ForegroundColor Green
Set-Location ..

# 2. 构建前端镜像
Write-Host ""
Write-Host "正在构建前端镜像..." -ForegroundColor Yellow
Set-Location frontend
docker build -t xingtu_crm-frontend .
if ($LASTEXITCODE -ne 0) {
    Write-Host "前端构建失败！" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✓ 前端构建成功" -ForegroundColor Green
Set-Location ..

# 3. 启动服务
Write-Host ""
Write-Host "正在启动服务..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "服务启动失败！" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "等待服务启动..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# 显示状态
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "          服务状态" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "          访问地址" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "前端界面: http://localhost:8080" -ForegroundColor Green
Write-Host "后端API:  http://localhost:8000" -ForegroundColor Green
Write-Host "API文档:  http://localhost:8000/docs" -ForegroundColor Green
Write-Host ""
Write-Host "查看日志: docker-compose logs -f" -ForegroundColor Yellow
Write-Host "停止服务: docker-compose down" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan

