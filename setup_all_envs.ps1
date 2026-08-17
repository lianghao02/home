[CmdletBinding()]
param(
    [string]$DevelopmentRoot = '',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if ([string]::IsNullOrWhiteSpace($DevelopmentRoot)) {
    $parent = Split-Path -Parent $PSScriptRoot
    if ($parent -and ((Split-Path -Leaf $parent) -match '(?i)^GitHub$')) {
        $DevelopmentRoot = $parent
    } elseif (Test-Path -LiteralPath 'D:\Development\GitHub') {
        $DevelopmentRoot = 'D:\Development\GitHub'
    } else {
        $DevelopmentRoot = 'C:\Development\GitHub'
    }
}

$root = [IO.Path]::GetFullPath($DevelopmentRoot)
$pyProjects = @(
    '01_AG-Monitor-Forensics',
    '06_System-Optimizer-Tool',
    '07_auto-learning-bot',
    '09_PaperSwitch',
    '10_Smart-Photo-Organizer'
)

Write-Host '=================================================================' -ForegroundColor Cyan
Write-Host '🛠️  【批次環境建置】正在為所有 Python 專案建置獨立自癒環境' -ForegroundColor Yellow
Write-Host "📁 【開發根目錄】$root"
Write-Host '=================================================================' -ForegroundColor Cyan
Write-Host ''

$index = 0
$total = $pyProjects.Count

foreach ($p in $pyProjects) {
    $index++
    $pdir = Join-Path $root $p
    $prefix = "[$index/$total] $p"

    if (-not (Test-Path -LiteralPath $pdir)) {
        Write-Host "$prefix : ⚠️  專案目錄不存在，已略過" -ForegroundColor Yellow
        continue
    }

    $setupScript = Join-Path $pdir 'setup_and_run.ps1'
    if (-not (Test-Path -LiteralPath $setupScript)) {
        Write-Host "$prefix : ⚠️  未找到 setup_and_run.ps1，已略過" -ForegroundColor Yellow
        continue
    }

    Write-Host "$prefix : ⏳ 正在檢查並建置獨立環境..." -ForegroundColor Green
    $oldEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$setupScript" -NoLaunch
    } finally {
        $ErrorActionPreference = $oldEap
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host "$prefix : ✅ 【就緒】環境已佈置完成" -ForegroundColor Cyan
    } else {
        Write-Host "$prefix : ❌ 【失敗】環境建置發生異常" -ForegroundColor Red
    }
    Write-Host '-----------------------------------------------------------------' -ForegroundColor Gray
}

Write-Host ''
Write-Host '=================================================================' -ForegroundColor Cyan
Write-Host '🎉 【完成】所有 5 個 Python 專案之環境建置程序已執行完畢！' -ForegroundColor Yellow
Write-Host '=================================================================' -ForegroundColor Cyan
