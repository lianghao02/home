# PowerShell UTF-8 Compatibility
[CmdletBinding()]
param(
    [string]$DevelopmentRoot = '',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8


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
    '07_auto-learning-bot',
    '10_Smart-Photo-Organizer'
)

Write-Host '=================================================================' -ForegroundColor Cyan
Write-Host '🚀 【批次環境建置】正在為所有 Python 專案建置獨立環境' -ForegroundColor Yellow
Write-Host "📂 【開發根目錄】$root"
if ($Force) {
    Write-Host '⚡ 【模式】強制重建所有環境 (-Force)' -ForegroundColor Magenta
}
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
        $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $setupScript, '-NoLaunch')
        if ($Force) {
            $argList += '-Force'
        }
        & powershell.exe $argList
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
Write-Host '📋 【環境完整性健檢報告】' -ForegroundColor Yellow
Write-Host '=================================================================' -ForegroundColor Cyan

foreach ($p in $pyProjects) {
    $pdir = Join-Path $root $p
    $py = Join-Path $pdir 'python_embed\python.exe'
    if (Test-Path -LiteralPath $py) {
        $oldEap = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        $diag = & $py -c "import sys, sqlite3; print('Python ' + sys.version.split()[0] + ' | sqlite3:OK')" 2>&1
        $ErrorActionPreference = $oldEap
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ $p -> $diag" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $p -> $diag" -ForegroundColor Red
        }
    } else {
        Write-Host "  ⚠️  $p -> 未安裝 python_embed" -ForegroundColor Yellow
    }
}

Write-Host '=================================================================' -ForegroundColor Cyan
Write-Host '🎉 所有 Python 專案之環境建置程序已執行完畢！' -ForegroundColor Yellow
Write-Host '=================================================================' -ForegroundColor Cyan
