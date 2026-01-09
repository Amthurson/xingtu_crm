# Upload frontend dist and deploy to host nginx

param(
    [Parameter(Mandatory=$true)]
    [string]$ServerIP,
    
    [Parameter(Mandatory=$false)]
    [string]$ServerUser = "root",
    
    [Parameter(Mandatory=$false)]
    [string]$RemotePath = "/opt/xingtu_crm"
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Upload and Deploy to Host Nginx" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if dist exists
if (-not (Test-Path "frontend\dist")) {
    Write-Host "Error: frontend\dist not found. Please run build-frontend-local.ps1 first." -ForegroundColor Red
    exit 1
}

# Check dist size
$distSize = (Get-ChildItem -Path frontend\dist -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host "Dist size: $([math]::Round($distSize, 2)) MB" -ForegroundColor Green
Write-Host ""

# Compress dist
Write-Host "Compressing dist directory..." -ForegroundColor Yellow
$zipFile = "frontend-dist.zip"
if (Test-Path $zipFile) {
    Remove-Item $zipFile
}
Compress-Archive -Path frontend\dist -DestinationPath $zipFile -Force

$zipSize = (Get-Item $zipFile).Length / 1MB
Write-Host "Compressed to: $zipFile ($([math]::Round($zipSize, 2)) MB)" -ForegroundColor Green
Write-Host ""

# Upload files
Write-Host "Uploading files to server..." -ForegroundColor Yellow
Write-Host "Server: ${ServerUser}@${ServerIP}" -ForegroundColor Cyan
Write-Host "Remote path: ${RemotePath}" -ForegroundColor Cyan
Write-Host ""

# Upload dist
scp $zipFile "${ServerUser}@${ServerIP}:${RemotePath}/frontend/"

# Upload nginx config and deploy script
scp nginx-host.conf "${ServerUser}@${ServerIP}:${RemotePath}/"
scp deploy-nginx-host.sh "${ServerUser}@${ServerIP}:${RemotePath}/"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Upload successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps on server:" -ForegroundColor Yellow
    Write-Host "  ssh ${ServerUser}@${ServerIP}" -ForegroundColor White
    Write-Host "  cd ${RemotePath}/frontend" -ForegroundColor White
    Write-Host "  unzip -o frontend-dist.zip" -ForegroundColor White
    Write-Host "  cd .." -ForegroundColor White
    Write-Host "  chmod +x deploy-nginx-host.sh" -ForegroundColor White
    Write-Host "  ./deploy-nginx-host.sh" -ForegroundColor White
    Write-Host ""
    Write-Host "Or run automatically:" -ForegroundColor Yellow
    Write-Host "  ssh ${ServerUser}@${ServerIP} 'cd ${RemotePath}/frontend && unzip -o frontend-dist.zip && cd .. && chmod +x deploy-nginx-host.sh && ./deploy-nginx-host.sh'" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "Upload failed!" -ForegroundColor Red
}

# Clean up
Remove-Item $zipFile -ErrorAction SilentlyContinue
