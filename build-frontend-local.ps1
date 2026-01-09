# Build frontend locally with pnpm

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Building Frontend Locally" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if in project root
if (-not (Test-Path "frontend")) {
    Write-Host "Error: frontend directory not found. Please run from project root." -ForegroundColor Red
    exit 1
}

# Check Node.js version
Write-Host "Checking Node.js version..." -ForegroundColor Yellow
$nodeVersion = node --version
Write-Host "Node.js: $nodeVersion" -ForegroundColor Green

# Check pnpm
Write-Host "Checking pnpm..." -ForegroundColor Yellow
if (-not (Get-Command pnpm -ErrorAction SilentlyContinue)) {
    Write-Host "Error: pnpm not found. Please run prepare-local.ps1 first." -ForegroundColor Red
    exit 1
}
$pnpmVersion = pnpm --version
Write-Host "pnpm: $pnpmVersion" -ForegroundColor Green

# Build frontend
Write-Host ""
Write-Host "Building frontend..." -ForegroundColor Yellow
Push-Location frontend

# Check if dist exists and clean
if (Test-Path "dist") {
    Write-Host "Found existing dist directory, cleaning..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force dist
    Write-Host "Cleaned dist directory" -ForegroundColor Green
}

# Build
Write-Host "Running pnpm build..." -ForegroundColor Cyan
pnpm run build

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Build successful!" -ForegroundColor Green
    
    # Check dist size
    if (Test-Path "dist") {
        $distSize = (Get-ChildItem -Path dist -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Host "Dist size: $([math]::Round($distSize, 2)) MB" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Test locally: pnpm preview" -ForegroundColor White
    Write-Host "2. Deploy to server: Upload dist folder or use Dockerfile.simple" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "Build failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Build Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
