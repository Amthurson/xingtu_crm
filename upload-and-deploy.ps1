# Upload images to server and deploy
# 上传镜像到服务器并部署

param(
    [Parameter(Mandatory=$true)]
    [string]$ServerIP,
    
    [Parameter(Mandatory=$false)]
    [string]$ServerUser = "root",
    
    [Parameter(Mandatory=$false)]
    [string]$RemotePath = "/tmp"
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Upload Images to Server" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if tar files exist
$tarFiles = Get-ChildItem -Filter "*.tar"
if ($tarFiles.Count -eq 0) {
    Write-Host "Error: No .tar files found. Please run export-images.ps1 first." -ForegroundColor Red
    exit 1
}

Write-Host "Found $($tarFiles.Count) image files:" -ForegroundColor Green
foreach ($file in $tarFiles) {
    $size = [math]::Round($file.Length / 1MB, 2)
    Write-Host "  - $($file.Name) ($size MB)" -ForegroundColor White
}

Write-Host ""
Write-Host "Uploading to server..." -ForegroundColor Yellow
Write-Host "Server: ${ServerUser}@${ServerIP}" -ForegroundColor Cyan
Write-Host ""

# Upload files
$totalSize = ($tarFiles | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host "Total size: $([math]::Round($totalSize, 2)) MB" -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Yellow
Write-Host ""

foreach ($file in $tarFiles) {
    Write-Host "Uploading $($file.Name)..." -ForegroundColor Cyan
    scp $file.FullName "${ServerUser}@${ServerIP}:${RemotePath}/"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Success" -ForegroundColor Green
    } else {
        Write-Host "  Failed" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Upload Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next, on the server, run:" -ForegroundColor Yellow
Write-Host ""
Write-Host "cd $RemotePath" -ForegroundColor White
Write-Host "docker load < postgres_15-alpine.tar" -ForegroundColor Cyan
Write-Host "docker load < python_3.11-slim.tar" -ForegroundColor Cyan
Write-Host "docker load < node_18-alpine.tar" -ForegroundColor Cyan
Write-Host "docker load < nginx_alpine.tar" -ForegroundColor Cyan
Write-Host ""
Write-Host "cd /opt/xingtu_crm  # or your project directory" -ForegroundColor White
Write-Host "docker-compose up -d" -ForegroundColor Cyan
Write-Host ""
Write-Host "Or use the import script:" -ForegroundColor Yellow
Write-Host "  chmod +x import-images-on-server.sh" -ForegroundColor White
Write-Host "  ./import-images-on-server.sh $RemotePath" -ForegroundColor White
