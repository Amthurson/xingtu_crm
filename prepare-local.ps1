# Local environment setup script - using nvm and pnpm

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Local Environment Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check nvm
Write-Host "Step 1: Checking nvm..." -ForegroundColor Yellow
if (-not (Get-Command nvm -ErrorAction SilentlyContinue)) {
    Write-Host "nvm is not installed. Please install nvm-windows:" -ForegroundColor Red
    Write-Host "1. Download: https://github.com/coreybutler/nvm-windows/releases" -ForegroundColor White
    Write-Host "2. Install nvm-setup.exe" -ForegroundColor White
    Write-Host "3. Restart PowerShell and run this script again" -ForegroundColor White
    exit 1
}

$nvmVersion = nvm version
Write-Host "nvm installed: $nvmVersion" -ForegroundColor Green

# Install Node.js 24.3.0
Write-Host ""
Write-Host "Step 2: Installing Node.js 24.3.0..." -ForegroundColor Yellow
$nodeList = nvm list
$nodeInstalled = $nodeList | Select-String "24.3.0"
if ($nodeInstalled) {
    Write-Host "Node.js 24.3.0 is already installed" -ForegroundColor Green
} else {
    Write-Host "Installing Node.js 24.3.0..." -ForegroundColor Cyan
    nvm install 24.3.0
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Installation failed, trying Node.js 24.x..." -ForegroundColor Yellow
        nvm install 24
    }
}

# Switch to Node.js 24.3.0
Write-Host ""
Write-Host "Step 3: Switching to Node.js 24.3.0..." -ForegroundColor Yellow
nvm use 24.3.0
if ($LASTEXITCODE -ne 0) {
    Write-Host "Switch failed, trying Node.js 24.x..." -ForegroundColor Yellow
    nvm use 24
}

$nodeVersion = node --version
Write-Host "Current Node.js version: $nodeVersion" -ForegroundColor Green

# Install pnpm
Write-Host ""
Write-Host "Step 4: Installing pnpm..." -ForegroundColor Yellow
if (Get-Command pnpm -ErrorAction SilentlyContinue) {
    $pnpmVersion = pnpm --version
    Write-Host "pnpm is already installed: $pnpmVersion" -ForegroundColor Green
} else {
    Write-Host "Installing pnpm..." -ForegroundColor Cyan
    npm install -g pnpm
    if ($LASTEXITCODE -eq 0) {
        $pnpmVersion = pnpm --version
        Write-Host "pnpm installed successfully: $pnpmVersion" -ForegroundColor Green
    } else {
        Write-Host "pnpm installation failed" -ForegroundColor Red
        exit 1
    }
}

# Configure pnpm registry
Write-Host ""
Write-Host "Step 5: Configuring pnpm registry (using Chinese mirror)..." -ForegroundColor Yellow
pnpm config set registry https://registry.npmmirror.com
Write-Host "pnpm registry configured" -ForegroundColor Green

# Install frontend dependencies
Write-Host ""
Write-Host "Step 6: Installing frontend dependencies..." -ForegroundColor Yellow
if (Test-Path "frontend") {
    Push-Location frontend
    
    Write-Host "Installing dependencies with pnpm..." -ForegroundColor Cyan
    pnpm install
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Dependencies installed successfully" -ForegroundColor Green
    } else {
        Write-Host "Dependency installation failed" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    
    Pop-Location
} else {
    Write-Host "Warning: frontend directory not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Environment Setup Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Now you can:" -ForegroundColor Yellow
Write-Host "1. Development mode: cd frontend; pnpm dev" -ForegroundColor White
Write-Host "2. Build production: cd frontend; pnpm build" -ForegroundColor White
Write-Host "3. Preview build: cd frontend; pnpm preview" -ForegroundColor White
Write-Host ""
