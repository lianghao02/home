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

$projects = @(
    [PSCustomObject]@{
        Name = '04_Photo-Report-Generator'
        BuildScript = Join-Path $root '04_Photo-Report-Generator\scripts\build-portable.ps1'
        BuildArguments = @()
        RestoreProject = ''
        SourceExe = Join-Path $root '04_Photo-Report-Generator\src-tauri\target\x86_64-pc-windows-gnu\release\photo-report-generator.exe'
    },
    [PSCustomObject]@{
        Name = '03_Police-Image-Toolkit'
        BuildScript = Join-Path $root '03_Police-Image-Toolkit\scripts\build.ps1'
        BuildArguments = @()
        RestoreProject = ''
        SourceExe = Join-Path $root '03_Police-Image-Toolkit\dist\PoliceImageToolkit.exe'
    },
    [PSCustomObject]@{
        Name = '06_System-Optimizer-Tool'
        BuildScript = Join-Path $root '06_System-Optimizer-Tool\dotnet-src\build_release.ps1'
        BuildArguments = @('-Target', 'standalone')
        RestoreProject = ''
        SourceExe = Join-Path $root '06_System-Optimizer-Tool\dotnet-src\publish\standalone\SystemOptimizer.App.exe'
    },
    [PSCustomObject]@{
        Name = '09_PaperSwitch'
        BuildScript = Join-Path $root '09_PaperSwitch\dotnet-src\scripts\build.ps1'
        BuildArguments = @('-SelfContained')
        RestoreProject = Join-Path $root '09_PaperSwitch\dotnet-src\src\PaperSwitch\PaperSwitch.csproj'
        SourceExe = Join-Path $root '09_PaperSwitch\dist\publish\PaperSwitch.exe'
    }
)

Write-Host '=================================================================' -ForegroundColor Cyan
Write-Host '🖥️ 【桌面應用程式集中發布】' -ForegroundColor Yellow
Write-Host "📂 開發根目錄：$root"
Write-Host '📌 發行模式：  四個專案各自輸出桌面應用程式' -ForegroundColor DarkCyan
if (Test-Path -LiteralPath $localDotnetExe) {
    Write-Host "🔧 .NET SDK：     $localDotnetExe" -ForegroundColor DarkCyan
} else {
    Write-Host '⚠️  .NET SDK：未在使用者本機位置找到，將使用 PATH 內的 dotnet。' -ForegroundColor Yellow
}
Write-Host '=================================================================' -ForegroundColor Cyan

foreach ($project in $projects) {
    $status = if (Test-Path -LiteralPath $project.BuildScript) { '就緒' } else { '缺少發布腳本' }
    Write-Host "  - $($project.Name)：$status"
}

if (-not $Execute) {
    Write-Host ''
    Write-Host '這是預覽模式，未修改任何檔案。' -ForegroundColor Yellow
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

if (-not $Force) {
    Write-Host ''
    Write-Host '注意：個別專案的既有發布腳本會清理並覆寫已選專案的舊發行目錄。' -ForegroundColor Yellow
    $answer = Read-Host '輸入 Y 後開始建置，其餘輸入取消'
    if ($answer -notmatch '^(?i)y(es)?$') {
        Write-Host '已取消，未開始建置。' -ForegroundColor Yellow
        return
    }
}

$results = [System.Collections.Generic.List[object]]::new()

foreach ($project in $selectedProjects) {
    Write-Host ''
    Write-Host "=================================================================" -ForegroundColor Gray
    Write-Host "🚀 正在發布：$($project.Name)" -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Gray

    try {
        if (-not [string]::IsNullOrWhiteSpace($project.RestoreProject)) {
            Write-Host '正在還原 NuGet 套件...' -ForegroundColor DarkCyan
            & $dotnetCommand restore $project.RestoreProject -r win-x64
            $restoreExitCode = $LASTEXITCODE
            if ($null -eq $restoreExitCode) { $restoreExitCode = 0 }
            if ($restoreExitCode -ne 0) {
                throw "NuGet 還原結束代碼為 $restoreExitCode"
            }
        }
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $project.BuildScript @($project.BuildArguments)
        $exitCode = $LASTEXITCODE
        if ($null -eq $exitCode) { $exitCode = 0 }
        if ($exitCode -ne 0) {
            throw "發布腳本結束代碼為 $exitCode"
        }
        if (-not (Test-Path -LiteralPath $project.SourceExe)) {
            throw "發布後找不到預期 EXE：$($project.SourceExe)"
        }

        $sizeMb = [math]::Round((Get-Item -LiteralPath $project.SourceExe).Length / 1MB, 2)
        $results.Add([PSCustomObject]@{ Project = $project.Name; Result = '成功'; Detail = "$($project.SourceExe) ($sizeMb MB)" })
        Write-Host "✅ 發布完成：$($project.SourceExe) ($sizeMb MB)" -ForegroundColor Green
    } catch {
        $results.Add([PSCustomObject]@{ Project = $project.Name; Result = '失敗'; Detail = $_.Exception.Message })
        Write-Host "❌ $($project.Name) 發布失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ''
Write-Host '=================================================================' -ForegroundColor Cyan
Write-Host '📋 集中發布結果' -ForegroundColor Yellow
Write-Host '=================================================================' -ForegroundColor Cyan
$results | Format-Table -AutoSize

$failed = @($results | Where-Object { $_.Result -eq '失敗' })
if ($failed.Count -gt 0) {
    Write-Host "❌ 完成但有 $($failed.Count) 個專案失敗；請依上方訊息排除。" -ForegroundColor Red
    exit 1
}

Write-Host '🎉 全部完成，請由各專案的既有發布目錄取得 EXE。' -ForegroundColor Green


