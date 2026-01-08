# Pull Docker images from registry mirrors first
# 先从镜像加速器拉取基础镜像

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Pull Base Images First" -ForegroundColor Cyan
Write-Host "    先拉取基础镜像" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check Docker
try {
    docker info | Out-Null
} catch {
    Write-Host "Error: Docker Desktop is not running." -ForegroundColor Red
    exit 1
}

Write-Host "Pulling base images from registry mirrors..." -ForegroundColor Yellow
Write-Host ""

# Try to pull images with retry logic
$images = @(
    "python:3.11-slim",
    "node:18-alpine",
    "postgres:15-alpine",
    "nginx:alpine"
)

$successCount = 0
$failCount = 0

foreach ($image in $images) {
    Write-Host "Pulling $image..." -ForegroundColor Yellow
    $maxRetries = 3
    $retryCount = 0
    $pulled = $false
    
    while ($retryCount -lt $maxRetries -and -not $pulled) {
        try {
            docker pull $image 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  Success: $image" -ForegroundColor Green
                $pulled = $true
                $successCount++
            } else {
                $retryCount++
                if ($retryCount -lt $maxRetries) {
                    Write-Host "  Retry $retryCount/$maxRetries..." -ForegroundColor Yellow
                    Start-Sleep -Seconds 2
                }
            }
        } catch {
            $retryCount++
            if ($retryCount -lt $maxRetries) {
                Write-Host "  Retry $retryCount/$maxRetries..." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }
        }
    }
    
    if (-not $pulled) {
        Write-Host "  Failed: $image" -ForegroundColor Red
        $failCount++
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Success: $successCount" -ForegroundColor Green
Write-Host "  Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
Write-Host "==========================================" -ForegroundColor Cyan

if ($failCount -gt 0) {
    Write-Host ""
    Write-Host "Some images failed to pull." -ForegroundColor Yellow
    Write-Host "Please configure Docker mirror registry:" -ForegroundColor Yellow
    Write-Host "  1. Run: .\setup-docker-mirror.ps1" -ForegroundColor White
    Write-Host "  2. Or configure manually in Docker Desktop" -ForegroundColor White
    Write-Host "  3. Restart Docker Desktop" -ForegroundColor White
    exit 1
} else {
    Write-Host ""
    Write-Host "All images pulled successfully!" -ForegroundColor Green
    Write-Host "Now you can run: docker-compose up -d --build" -ForegroundColor Green
}

