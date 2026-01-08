# Build frontend locally then copy to Docker
# 本地构建前端，然后复制到Docker

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Build Frontend Locally" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location frontend

# Check if node_modules exists
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing npm dependencies..." -ForegroundColor Yellow
    npm config set registry https://registry.npmmirror.com
    npm install
}

Write-Host ""
Write-Host "Building frontend..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Write-Host ""
Write-Host "Frontend built successfully!" -ForegroundColor Green
Write-Host "Now you can build Docker image without npm install step" -ForegroundColor Yellow
Set-Location ..

