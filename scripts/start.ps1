# PowerShell script to start the Gemini AI Hackathon App

# Ensure we are in the project root directory
$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
Set-Location $ProjectRoot

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Gemini AI Hackathon - Starting Application  " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# 1. Check/Setup Virtual Environment
$VenvDir = Join-Path $ProjectRoot ".venv"
$PythonExe = Join-Path $VenvDir "Scripts\python.exe"
$PipExe = Join-Path $VenvDir "Scripts\pip.exe"

if (-not (Test-Path $VenvDir)) {
    Write-Host "[*] Virtual environment (.venv) not found. Creating one..." -ForegroundColor Yellow
    
    # Check if uv is installed
    $hasUv = Get-Command uv -ErrorAction SilentlyContinue
    if ($hasUv) {
        Write-Host "[+] 'uv' detected, initializing virtual environment via uv..." -ForegroundColor Green
        uv venv .venv
        & $VenvDir\Scripts\activate.ps1
        uv pip install -r requirements.txt
    } else {
        Write-Host "[-] 'uv' not found. Initializing virtual environment via standard python..." -ForegroundColor Yellow
        python -m venv .venv
        & $VenvDir\Scripts\activate.ps1
        & $PipExe install -r requirements.txt
    }
} else {
    Write-Host "[+] Virtual environment (.venv) detected." -ForegroundColor Green
}

# 2. Check Environment Variables / .env
$EnvFile = Join-Path $ProjectRoot ".env"
if (Test-Path $EnvFile) {
    $EnvContent = Get-Content $EnvFile
    $HasPlaceholder = $false
    foreach ($line in $EnvContent) {
        if ($line -match "^GEMINI_API_KEY=(.*)") {
            $KeyVal = $Matches[1].Trim()
            if ($KeyVal -eq "YOUR_GEMINI_API_KEY_HERE" -or $KeyVal -eq "") {
                $HasPlaceholder = $true
            }
        }
    }
    
    if ($HasPlaceholder) {
        Write-Host "[!] Warning: GEMINI_API_KEY is not configured in .env!" -ForegroundColor Red
        Write-Host "    Please update the GEMINI_API_KEY in your .env file or make sure it's set in your environment." -ForegroundColor Yellow
    } else {
        Write-Host "[+] GEMINI_API_KEY detected in .env file." -ForegroundColor Green
    }
} else {
    Write-Host "[!] Warning: .env file not found! Copying from .env.example..." -ForegroundColor Yellow
    Copy-Item (Join-Path $ProjectRoot ".env.example") $EnvFile
    Write-Host "    Please update the GEMINI_API_KEY in the newly created .env file." -ForegroundColor Yellow
}

# 3. Start the application
Write-Host "[*] Starting Flask Application (app.py) on port 8080..." -ForegroundColor Cyan
& $PythonExe app.py
