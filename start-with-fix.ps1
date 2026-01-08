# Start script with network fix
# 带网络修复的启动脚本

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Xingtu CRM - Start with Fix" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Pull base images
Write-Host "Step 1: Pulling base images..." -ForegroundColor Yellow
.\pull-images-first.ps1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to pull base images. Please check your network." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 2: Building services (without BuildKit)..." -ForegroundColor Yellow

# Step 2: Build with DOCKER_BUILDKIT=0
$env:DOCKER_BUILDKIT = "0"
docker-compose build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 3: Starting services..." -ForegroundColor Yellow

# Step 3: Start services
docker-compose up -d

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Services Status" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Access URLs" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Frontend: http://localhost:8080" -ForegroundColor Green
Write-Host "Backend:  http://localhost:8000" -ForegroundColor Green
Write-Host "API Docs: http://localhost:8000/docs" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan

