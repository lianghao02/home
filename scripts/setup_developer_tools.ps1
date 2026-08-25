[CmdletBinding()]
param(
    [switch]$CheckOnly,
    [switch]$Execute,
    [switch]$WithPlaywright,
    [switch]$WithRust,
    [switch]$SetupPythonEnvs
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$homeRepo = Split-Path -Parent $PSScriptRoot
$githubRoot = Split-Path -Parent $homeRepo

function Write-Header([string]$Title) {
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "=================================================================" -ForegroundColor Cyan
}

function Get-ToolInfo([string]$CommandName, [string]$VersionArg = '--version') {
    $cmd = Get-Command $CommandName -ErrorAction SilentlyContinue
    if (-not $cmd) {
        return [ordered]@{
            Installed = $false
            Path      = $null
            Version   = $null
        }
    }
    
    if ($CommandName -eq 'dotnet') {
        $sdkList = @(& dotnet --list-sdks 2>$null)
        $runtimeList = @(& dotnet --list-runtimes 2>$null)
        if ($sdkList.Count -gt 0) {
            $latestSdk = (($sdkList | Select-Object -Last 1) -split '\s+')[0]
            return [ordered]@{
                Installed = $true
                Path      = $cmd.Source
                Version   = (".NET SDK " + $latestSdk + " (含 Desktop Runtime)")
            }
        } elseif ($runtimeList.Count -gt 0) {
            $desktop = $runtimeList | Where-Object { $_ -match 'WindowsDesktop\.App\s+([\d\.]+)' } | Select-Object -First 1
            $ver = if ($desktop -and $desktop -match 'WindowsDesktop\.App\s+([\d\.]+)') { $matches[1] } else { '8.0' }
            return [ordered]@{
                Installed = $true
                Path      = $cmd.Source
                Version   = (".NET " + $ver + " Desktop Runtime (執行環境就緒)")
            }
        }
    }

    $verStr = $null
    try {
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = $cmd.Source
        $pinfo.Arguments = $VersionArg
        $pinfo.RedirectStandardOutput = $true
        $pinfo.RedirectStandardError = $true
        $pinfo.UseShellExecute = $false
        $pinfo.CreateNoWindow = $true
        $proc = [System.Diagnostics.Process]::Start($pinfo)
        $output = $proc.StandardOutput.ReadToEnd()
        $err = $proc.StandardError.ReadToEnd()
        $finished = $proc.WaitForExit(3000)
        if (-not $finished) {
            $proc.Kill()
        } else {
            $raw = ($output + "`n" + $err).Trim()
            $firstLine = ($raw -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1)
            $verStr = if ($firstLine) { $firstLine.Trim() } else { "已安裝 (版本未知)" }
        }
    } catch {
        $verStr = "已安裝 (無法取得版本)"
    }
    
    if ([string]::IsNullOrWhiteSpace($verStr)) {
        $verStr = "已安裝"
    }

    return [ordered]@{
        Installed = $true
        Path      = $cmd.Source
        Version   = $verStr
    }
}

function Install-WingetPackage([string]$Id, [string]$Name) {
    $winget = Get-Command 'winget' -ErrorAction SilentlyContinue
    if (-not $winget) {
        throw ("找不到 winget 套件管理員，無法自動安裝 " + $Name + "。請至 Microsoft Store 更新 Windows App Installer。")
    }
    Write-Host ("⏳ 正在透過 winget 安裝：" + $Name + " (" + $Id + ")...") -ForegroundColor Yellow
    & winget install --id $Id --exact --source winget --accept-package-agreements --accept-source-agreements --silent
    if ($LASTEXITCODE -ne 0) {
        Write-Host ("⚠️  winget 靜默安裝傳回代碼 " + $LASTEXITCODE + "，嘗試一般模式安裝...") -ForegroundColor Yellow
        & winget install --id $Id --exact --source winget --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0) {
            throw ("安裝失敗：" + $Name + " (" + $Id + ")")
        }
    }
    Write-Host ("✅ 安裝完成：" + $Name) -ForegroundColor Green
}

# 定義核心與選用語言環境清單
$toolDefinitions = @(
    [ordered]@{ Key = 'git';    Name = 'Git for Windows';  WingetId = 'Git.Git';              VerArg = '--version'; Essential = $true },
    [ordered]@{ Key = 'gh';     Name = 'GitHub CLI';       WingetId = 'GitHub.cli';          VerArg = '--version'; Essential = $true },
    [ordered]@{ Key = 'python'; Name = 'Python (3.13+)';   WingetId = 'Python.Python.3.13';   VerArg = '--version'; Essential = $true },
    [ordered]@{ Key = 'dotnet'; Name = '.NET 8.0 (SDK/RT)'; WingetId = 'Microsoft.DotNet.SDK.8'; VerArg = '--version'; Essential = $true },
    [ordered]@{ Key = 'node';   Name = 'Node.js LTS';      WingetId = 'OpenJS.NodeJS.LTS';    VerArg = '--version'; Essential = $true },
    [ordered]@{ Key = 'cargo';  Name = 'Rust and Cargo';   WingetId = 'Rustlang.Rustup';      VerArg = '--version'; Essential = $false }
)

Write-Header "🛠️  開發語言環境與工具鏈狀態診斷 (Developer Environment Manager)"
Write-Host ""

$missingEssentials = @()
$toolResults = @{}

Write-Host "【一、 系統級語言與核心工具鏈檢測】" -ForegroundColor Yellow
foreach ($def in $toolDefinitions) {
    $info = Get-ToolInfo -CommandName $def.Key -VersionArg $def.VerArg
    $toolResults[$def.Key] = $info
    
    $tag = if ($def.Essential) { "[核心]" } else { "[選用]" }
    if ($info.Installed) {
        Write-Host ("  ✅ {0,-6} {1,-18} : {2}" -f $tag, $def.Name, $info.Version) -ForegroundColor Green
        Write-Host ("     路徑: " + $info.Path) -ForegroundColor DarkGray
    } else {
        if ($def.Essential) {
            Write-Host ("  ❌ {0,-6} {1,-18} : 未安裝 (Winget ID: {2})" -f $tag, $def.Name, $def.WingetId) -ForegroundColor Red
            $missingEssentials += $def
        } else {
            Write-Host ("  ⚪ {0,-6} {1,-18} : 未安裝 (選配元件)" -f $tag, $def.Name) -ForegroundColor DarkGray
        }
    }
}

Write-Host ""
Write-Host "【二、 四大 Python 專案獨立可攜環境 (python_embed) 檢測】" -ForegroundColor Yellow
$pyProjects = @('01_AG-Monitor-Forensics', '07_auto-learning-bot', '09_PaperSwitch', '10_Smart-Photo-Organizer')
$missingPyEnvs = @()

foreach ($p in $pyProjects) {
    $embedPath = Join-Path $githubRoot "$p\python_embed\python.exe"
    if (Test-Path -LiteralPath $embedPath) {
        Write-Host ("  ✅ {0,-26} : python_embed 可攜環境就緒" -f $p) -ForegroundColor Green
    } else {
        Write-Host ("  ⚪ {0,-26} : 未建置可攜環境 (雙擊 4_建置所有Python專案環境.bat 可建立)" -f $p) -ForegroundColor Yellow
        $missingPyEnvs += $p
    }
}

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Cyan

# 判斷是否只做檢測
if ($CheckOnly) {
    if ($missingEssentials.Count -eq 0) {
        Write-Host "🎉 系統所有核心語言與工具鏈均已安裝就緒！" -ForegroundColor Green
    } else {
        Write-Host ("⚠️  發現 {0} 個核心工具尚未安裝。" -f $missingEssentials.Count) -ForegroundColor Yellow
    }
    return
}

# 執行安裝模式 (-Execute) 或未安裝提示
if ($Execute) {
    if ($missingEssentials.Count -gt 0) {
        Write-Host "🚀 正在自動安裝缺漏的核心語言環境..." -ForegroundColor Cyan
        foreach ($item in $missingEssentials) {
            Install-WingetPackage -Id $item.WingetId -Name $item.Name
        }
    } else {
        Write-Host "✨ 核心語言環境皆已安裝，無需補裝。" -ForegroundColor Green
    }

    # GitHub 登入授權確認
    $ghCmd = Get-Command 'gh' -ErrorAction SilentlyContinue
    if ($ghCmd) {
        & gh auth status 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "💡 提示：偵測到 GitHub CLI 尚未登入，即將開啟網頁授權..." -ForegroundColor Yellow
            & gh auth login --web --git-protocol https
        }
    }

    # 選用 Playwright 安裝
    if ($WithPlaywright) {
        Write-Host "⏳ 正在安裝選用套件 Playwright 與 Chromium..." -ForegroundColor Cyan
        $npmCmd = Get-Command 'npm' -ErrorAction SilentlyContinue
        if ($npmCmd) {
            & npm install --global playwright
            & npx playwright install chromium
            Write-Host "✅ Playwright 與 Chromium 安裝完成。" -ForegroundColor Green
        }
    }

    # 選用 Rust 安裝
    if ($WithRust -and -not $toolResults['cargo'].Installed) {
        Install-WingetPackage -Id 'Rustlang.Rustup' -Name 'Rust and Cargo'
    }

    # 一鍵建置 Python 專案可攜環境
    if ($SetupPythonEnvs -or ($missingPyEnvs.Count -gt 0 -and $Execute)) {
        $setupPyScript = Join-Path $homeRepo 'setup_all_envs.ps1'
        if (Test-Path -LiteralPath $setupPyScript) {
            Write-Host ""
            Write-Host "🚀 正在為 Python 專案建置獨立可攜環境..." -ForegroundColor Cyan
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $setupPyScript
        }
    }

    Write-Host ""
    Write-Host "=================================================================" -ForegroundColor Green
    Write-Host "🎉 開發語言與工具鏈設定作業完成！" -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Green
    return
}

# 預設模式（未帶 -Execute 時的互動選單）
if ($missingEssentials.Count -gt 0) {
    Write-Host "⚠️  檢測到缺漏的核心工具：" -ForegroundColor Yellow
    $missingNames = ($missingEssentials | ForEach-Object { $_.Name }) -join '、'
    Write-Host "   $missingNames" -ForegroundColor White
    Write-Host ""
    $ans = Read-Host "是否要立即透過 winget 自動安裝補齊上述工具？(Y/N)"
    if ($ans -match '^(?i)y$') {
        foreach ($item in $missingEssentials) {
            Install-WingetPackage -Id $item.WingetId -Name $item.Name
        }
        Write-Host ""
        Write-Host "✅ 核心工具安裝完成！請重新開啟終端機以載入最新 PATH 環境變數。" -ForegroundColor Green
    }
} else {
    Write-Host "🎉 系統核心語言與工具鏈完全健康！" -ForegroundColor Green
    Write-Host ""
    Write-Host "選用操作：" -ForegroundColor DarkCyan
    Write-Host "  [1] 重新建置四大 Python 專案可攜環境 (setup_all_envs.ps1)" -ForegroundColor White
    Write-Host "  [2] 安裝選用 Playwright 與 Chromium 瀏覽器" -ForegroundColor White
    Write-Host "  [3] 安裝選用 Rust & Cargo (用於 Tauri / 原生模組編譯)" -ForegroundColor White
    Write-Host "  [Q] 結束離開" -ForegroundColor DarkGray
    Write-Host ""
    $choice = Read-Host "請輸入選項 (1-3 或 Q)"
    switch ($choice) {
        '1' {
            $setupPyScript = Join-Path $homeRepo 'setup_all_envs.ps1'
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $setupPyScript
        }
        '2' {
            Write-Host "⏳ 正在安裝 Playwright..." -ForegroundColor Cyan
            & npm install --global playwright
            & npx playwright install chromium
            Write-Host "✅ Playwright 安裝完成。" -ForegroundColor Green
        }
        '3' {
            Install-WingetPackage -Id 'Rustlang.Rustup' -Name 'Rust and Cargo'
        }
        default {
            Write-Host "已結束檢測。" -ForegroundColor Gray
        }
    }
}
