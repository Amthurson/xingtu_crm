# Quick build frontend with local build
# 快速构建前端（本地构建）

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Quick Frontend Build" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location frontend

# Build locally first
Write-Host "Step 1: Building frontend locally..." -ForegroundColor Yellow
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm config set registry https://registry.npmmirror.com
    npm install
}

npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Local build failed!" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Set-Location ..

Write-Host ""
Write-Host "Step 2: Building Docker image..." -ForegroundColor Yellow

# Build Docker image using local build Dockerfile
$env:DOCKER_BUILDKIT = "0"
docker build -f frontend/Dockerfile.local -t xingtu_crm-frontend ./frontend

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Frontend Docker image built successfully!" -ForegroundColor Green
    Write-Host "You can now start services with: docker-compose up -d" -ForegroundColor Yellow
} else {
    Write-Host "Docker build failed!" -ForegroundColor Red
}

