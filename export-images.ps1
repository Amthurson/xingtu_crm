# Export Docker images for offline deployment
# 导出Docker镜像用于离线部署

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Export Docker Images" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

Write-Host "Step 1: Pulling base images..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Yellow
Write-Host ""

$images = @(
    "python:3.11-slim",
    "node:18-alpine",
    "postgres:15-alpine",
    "nginx:alpine"
)

$successCount = 0
$failCount = 0

foreach ($image in $images) {
    Write-Host "Pulling $image ..." -ForegroundColor Cyan
    docker pull $image
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Success" -ForegroundColor Green
        $successCount++
    } else {
        Write-Host "  Failed" -ForegroundColor Red
        $failCount++
    }
}

Write-Host ""
Write-Host "Pulling complete: Success $successCount, Failed $failCount" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Yellow" })

if ($successCount -eq 0) {
    Write-Host ""
    Write-Host "All images failed to pull. Please check network connection." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 2: Exporting images..." -ForegroundColor Yellow

foreach ($image in $images) {
    $tarFile = $image.Replace(":", "_").Replace("/", "_") + ".tar"
    Write-Host "Exporting $image -> $tarFile ..." -ForegroundColor Cyan
    
    docker save $image -o $tarFile
    
    if ($LASTEXITCODE -eq 0) {
        $size = (Get-Item $tarFile).Length / 1MB
        $sizeStr = [math]::Round($size, 2).ToString() + " MB"
        Write-Host "  Success ($sizeStr)" -ForegroundColor Green
    } else {
        Write-Host "  Failed" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Export Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Upload these .tar files to server:" -ForegroundColor White
Write-Host "   scp *.tar root@your-server-ip:/tmp/" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. On server, import images:" -ForegroundColor White
Write-Host "   docker load < postgres_15-alpine.tar" -ForegroundColor Cyan
Write-Host "   docker load < python_3.11-slim.tar" -ForegroundColor Cyan
Write-Host "   docker load < node_18-alpine.tar" -ForegroundColor Cyan
Write-Host "   docker load < nginx_alpine.tar" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Then run: docker-compose up -d" -ForegroundColor White
