# Docker Mirror Configuration Script

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Docker Mirror Configuration" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

try {
    docker info | Out-Null
} catch {
    Write-Host "Error: Docker Desktop is not running." -ForegroundColor Red
    Write-Host "Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}

Write-Host "Configuring Docker mirror registry..." -ForegroundColor Yellow
Write-Host ""

$dockerConfigPath = "$env:APPDATA\Docker\settings.json"

if (-not (Test-Path $dockerConfigPath)) {
    Write-Host "Docker config file not found." -ForegroundColor Yellow
    Write-Host "Please configure manually through Docker Desktop:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Open Docker Desktop" -ForegroundColor White
    Write-Host "2. Click Settings icon" -ForegroundColor White
    Write-Host "3. Go to Docker Engine" -ForegroundColor White
    Write-Host "4. Add the following JSON:" -ForegroundColor White
    Write-Host ""
    Write-Host '{' -ForegroundColor Green
    Write-Host '  "registry-mirrors": [' -ForegroundColor Green
    Write-Host '    "https://docker.mirrors.ustc.edu.cn",' -ForegroundColor Green
    Write-Host '    "https://hub-mirror.c.163.com",' -ForegroundColor Green
    Write-Host '    "https://mirror.baidubce.com"' -ForegroundColor Green
    Write-Host '  ]' -ForegroundColor Green
    Write-Host '}' -ForegroundColor Green
    Write-Host ""
    Write-Host '5. Click Apply and Restart' -ForegroundColor White
    exit 0
}

try {
    $config = Get-Content $dockerConfigPath -Raw | ConvertFrom-Json
} catch {
    Write-Host "Error: Failed to read Docker config file." -ForegroundColor Red
    exit 1
}

if (-not $config.'registry-mirrors') {
    $config | Add-Member -MemberType NoteProperty -Name 'registry-mirrors' -Value @()
}

$mirrors = @(
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
)

foreach ($mirror in $mirrors) {
    if ($config.'registry-mirrors' -notcontains $mirror) {
        $config.'registry-mirrors' += $mirror
    }
}

try {
    $config | ConvertTo-Json -Depth 10 | Set-Content $dockerConfigPath
    Write-Host "Mirror registry configured successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Please restart Docker Desktop for changes to take effect." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Configured mirror registries:" -ForegroundColor Cyan
    foreach ($mirror in $mirrors) {
        Write-Host ('  - ' + $mirror) -ForegroundColor White
    }
} catch {
    Write-Host "Error: Failed to save configuration." -ForegroundColor Red
    exit 1
}
