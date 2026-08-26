# UTF-8 Compatibility
[CmdletBinding()]
param(
    [string]$DevelopmentRoot = '',
    [switch]$Execute,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

if ([string]::IsNullOrWhiteSpace($DevelopmentRoot)) {
    $DevelopmentRoot = Split-Path -Parent $PSScriptRoot
}

$root = [IO.Path]::GetFullPath($DevelopmentRoot)
if (-not (Test-Path -LiteralPath $root)) {
    throw "找不到開發根目錄：$root"
}

# 統一提供目前使用者安裝的完整 .NET SDK，讓各專案既有腳本不受 PATH 僅含 Runtime 影響。
$localDotnetRoot = Join-Path $env:LOCALAPPDATA 'Microsoft\dotnet'
$localDotnetExe = Join-Path $localDotnetRoot 'dotnet.exe'
$dotnetCommand = 'dotnet'
if (Test-Path -LiteralPath $localDotnetExe) {
    $dotnetCommand = $localDotnetExe
    $env:DOTNET_ROOT = $localDotnetRoot
    if (($env:PATH -split ';') -notcontains $localDotnetRoot) {
        $env:PATH = "$localDotnetRoot;$env:PATH"
    }
}

# 注入 Rust Cargo 與 MinGW 工具鏈 (若存在)
$cargoBin = Join-Path $env:USERPROFILE '.cargo\bin'
$mingwBin = Join-Path $env:USERPROFILE 'scoop\apps\mingw\current\bin'
if (Test-Path -LiteralPath $cargoBin) { $env:PATH = "$cargoBin;$env:PATH" }
if (Test-Path -LiteralPath $mingwBin) { $env:PATH = "$mingwBin;$env:PATH" }

$projects = @(
    [PSCustomObject]@{
        Name = '03_Police-Image-Toolkit'
        BuildScript = Join-Path $root '03_Police-Image-Toolkit\scripts\build.ps1'
        BuildArguments = @()
        SourceExe = Join-Path $root '03_Police-Image-Toolkit\dist\PoliceImageToolkit.exe'
    },
    [PSCustomObject]@{
        Name = '06_System-Optimizer-Tool'
        BuildScript = Join-Path $root '06_System-Optimizer-Tool\dotnet-src\build_release.ps1'
        BuildArguments = @()
        SourceExe = Join-Path $root '06_System-Optimizer-Tool\dotnet-src\publish\SystemOptimizer.App.exe'
    },
    [PSCustomObject]@{
        Name = '09_PaperSwitch'
        BuildScript = Join-Path $root '09_PaperSwitch\dotnet-src\scripts\build.ps1'
        BuildArguments = @()
        SourceExe = Join-Path $root '09_PaperSwitch\dist\publish\PaperSwitch.exe'
    },
    [PSCustomObject]@{
        Name = '04_Photo-Report-Generator'
        BuildScript = Join-Path $root '04_Photo-Report-Generator\scripts\build-portable.ps1'
        BuildArguments = @()
        SourceExe = Join-Path $root '04_Photo-Report-Generator\src-tauri\target\x86_64-pc-windows-gnu\release\photo-report-generator.exe'
    }
)

Write-Host '=================================================================' -ForegroundColor Cyan
Write-Host '🖥️ 【Windows 桌面應用程式集中建置】' -ForegroundColor Yellow
Write-Host "📂 開發根目錄：$root" -ForegroundColor Gray
Write-Host '📌 發行模式：  四個專案各自輸出桌面免安裝應用程式' -ForegroundColor Gray
if (Test-Path -LiteralPath $localDotnetExe) {
    Write-Host "🔧 .NET SDK：     $localDotnetExe" -ForegroundColor Gray
} else {
    Write-Host '⚠️  .NET SDK：未在使用者本機目錄找到，使用系統預設 dotnet。' -ForegroundColor Yellow
}
Write-Host '=================================================================' -ForegroundColor Cyan

foreach ($project in $projects) {
    $status = if (Test-Path -LiteralPath $project.BuildScript) { '就緒' } else { '缺少發布腳本' }
    Write-Host "  - $($project.Name)：$status"
}

if (-not $Execute) {
    Write-Host ''
    Write-Host '💡 目前為預覽模式，未建置任何專案。' -ForegroundColor Yellow
    Write-Host '實際建置請執行：' -ForegroundColor Yellow
    Write-Host '  .\build_all_desktop_apps.ps1 -Execute  （執行時選擇專案）' -ForegroundColor White
    return
}

$selectedProjects = @()
if ($Force) {
    $selectedProjects = $projects
    Write-Host '已使用 -Force，將直接建置全部專案。' -ForegroundColor Yellow
} else {
    Write-Host ''
    Write-Host '請選擇要建置的專案：' -ForegroundColor Cyan
    for ($index = 0; $index -lt $projects.Count; $index++) {
        Write-Host "  $($index + 1). $($projects[$index].Name)"
    }
    Write-Host '  A. 全部專案'
    Write-Host '  0. 取消'

    $selection = (Read-Host '請輸入選項').Trim()
    if ($selection -eq '0') {
        Write-Host '已取消，未開始建置。' -ForegroundColor Yellow
        return
    }
    if ($selection -match '^(?i)a(ll)?$') {
        $selectedProjects = $projects
    } elseif ($selection -match '^[1-9]\d*$' -and [int]$selection -le $projects.Count) {
        $selectedProjects = @($projects[[int]$selection - 1])
    } else {
        Write-Host '選項無效，未開始建置。' -ForegroundColor Red
        return
    }

    Write-Host "已選擇：$($selectedProjects.Name -join '、')" -ForegroundColor Green
}

$missingScripts = @($selectedProjects | Where-Object { -not (Test-Path -LiteralPath $_.BuildScript) })
if ($missingScripts.Count -gt 0) {
    $names = $missingScripts.Name -join '、'
    throw "缺少發布腳本，已取消：$names"
}

$results = [System.Collections.Generic.List[object]]::new()

foreach ($project in $selectedProjects) {
    Write-Host ''
    Write-Host "=================================================================" -ForegroundColor Gray
    Write-Host "🚀 正在建置：$($project.Name)" -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Gray

    try {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $project.BuildScript @($project.BuildArguments)
        $exitCode = $LASTEXITCODE
        if ($null -eq $exitCode) { $exitCode = 0 }
        if ($exitCode -ne 0) {
            throw "建置腳本結束代碼為 $exitCode"
        }
        
        # 尋找輸出成品
        $exePath = $project.SourceExe
        if (-not (Test-Path -LiteralPath $exePath)) {
            # 容錯尋找該專案 dist 底下的任何 exe
            $pRoot = Split-Path (Split-Path $project.BuildScript)
            $foundExe = Get-ChildItem -Path $pRoot -Filter "*.exe" -Recurse -File | Where-Object { $_.FullName -notmatch '\\(obj|bin)\\' } | Select-Object -First 1
            if ($foundExe) {
                $exePath = $foundExe.FullName
            } else {
                throw "建置後找不到預期 EXE：$($project.SourceExe)"
            }
        }

        $sizeMb = [math]::Round((Get-Item -LiteralPath $exePath).Length / 1MB, 2)
        $results.Add([PSCustomObject]@{ Project = $project.Name; Result = '成功'; Detail = "$exePath ($sizeMb MB)" })
        Write-Host "✅ 建置完成：$exePath ($sizeMb MB)" -ForegroundColor Green
    } catch {
        $results.Add([PSCustomObject]@{ Project = $project.Name; Result = '失敗'; Detail = $_.Exception.Message })
        Write-Host "❌ $($project.Name) 建置失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ''
Write-Host '=================================================================' -ForegroundColor Cyan
Write-Host '📋 桌面應用程式集中建置結果' -ForegroundColor Yellow
Write-Host '=================================================================' -ForegroundColor Cyan
$results | Format-Table -AutoSize

$failed = @($results | Where-Object { $_.Result -eq '失敗' })
if ($failed.Count -gt 0) {
    Write-Host "❌ 完成但有 $($failed.Count) 個專案建置失敗。" -ForegroundColor Red
    exit 1
} else {
    Write-Host "🎉 已選桌面專案全數建置成功！" -ForegroundColor Green
}
