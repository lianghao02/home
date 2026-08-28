# UTF-8 Compatibility
[CmdletBinding()]
param(
    [string]$DevelopmentRoot = '',
    [string]$Action = 'Menu' # Menu, Auto, Pull, Push, SyncAI, Scan
)

$ErrorActionPreference = 'Continue'
Set-StrictMode -Off

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$homeRepo = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($DevelopmentRoot)) {
    $DevelopmentRoot = Split-Path -Parent $homeRepo
}
$devRoot = [IO.Path]::GetFullPath($DevelopmentRoot)
$manifestPath = Join-Path $homeRepo 'development-repositories.json'

if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw "找不到專案清單檔案：$manifestPath"
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$repoNames = @($manifest.repositories.folder)

# 敏感資訊正則檢測防護
$sensitivePatterns = @(
    'ghp_[a-zA-Z0-9]{36}',
    'github_pat_[a-zA-Z0-9_]{82}',
    'AIza[0-9A-Za-z\-_]{35}',
    'sk-[a-zA-Z0-9]{32,}'
)

function Scan-Projects() {
    Write-Host '=================================================================' -ForegroundColor Cyan
    Write-Host '🔍 【專案狀態掃描中...】正在比對 13 個專案之本機與雲端狀態' -ForegroundColor Yellow
    Write-Host "📁 【工作目錄】$devRoot" -ForegroundColor Gray
    Write-Host '=================================================================' -ForegroundColor Cyan

    $stats = [System.Collections.Generic.List[object]]::new()
    $idx = 0

    foreach ($name in $repoNames) {
        $idx++
        $pPath = Join-Path $devRoot $name
        if (-not (Test-Path -LiteralPath $pPath)) {
            Write-Host "[$idx/$($repoNames.Count)] $name : ⚠️ 目錄不存在" -ForegroundColor DarkYellow
            continue
        }

        # 設定 safe.directory 防護
        $safePath = $pPath.Replace('\', '/')
        & git config --global --add safe.directory "$safePath" 2>$null

        Push-Location $pPath
        try {
            # 靜默 fetch 遠端
            & git fetch origin main --quiet 2>$null
            
            $statusOut = (& git status --porcelain 2>$null)
            $hasUncommitted = ($null -ne $statusOut -and $statusOut.Count -gt 0)
            
            $aheadCount = 0
            $behindCount = 0
            $revCount = (& git rev-list --left-right --count HEAD...origin/main 2>$null)
            if ($null -ne $revCount -and $revCount -match '(\d+)\s+(\d+)') {
                $aheadCount = [int]$matches[1]
                $behindCount = [int]$matches[2]
            }

            $desc = '✨ 已是最新進度'
            $color = 'Green'

            if ($behindCount -gt 0 -and ($aheadCount -gt 0 -or $hasUncommitted)) {
                $desc = "⚠️ 需同步 (⬇️ 雲端新 $behindCount 版, ⬆️ 本地 $aheadCount 版/待提交)"
                $color = 'Yellow'
            } elseif ($behindCount -gt 0) {
                $desc = "⬇️ 雲端有更新 ($behindCount 個版本待拉取)"
                $color = 'Cyan'
            } elseif ($aheadCount -gt 0 -or $hasUncommitted) {
                $changeDesc = if ($aheadCount -gt 0) { "$aheadCount 個待推送版本" } else { "未提交之檔案修改" }
                $desc = "⬆️ 本地有修改 ($changeDesc)"
                $color = 'Magenta'
            }

            Write-Host "[$idx/$($repoNames.Count)] $name : " -NoNewline
            Write-Host $desc -ForegroundColor $color

            $stats.Add([PSCustomObject]@{
                Index = $idx
                Name = $name
                Path = $pPath
                HasUncommitted = $hasUncommitted
                Ahead = $aheadCount
                Behind = $behindCount
            })
        } finally {
            Pop-Location
        }
    }

    $behindTotal = @($stats | Where-Object { $_.Behind -gt 0 }).Count
    $aheadTotal = @($stats | Where-Object { $_.Ahead -gt 0 -or $_.HasUncommitted }).Count

    Write-Host '=================================================================' -ForegroundColor Cyan
    Write-Host "📊 【狀態統計】共 $($repoNames.Count) 個專案： ⬇️ 待拉取: $behindTotal 個 | ⬆️ 待推送: $aheadTotal 個" -ForegroundColor White
    Write-Host '=================================================================' -ForegroundColor Cyan

    return $stats
}

function Invoke-PullAll($scanList) {
    Write-Host ''
    Write-Host '=================================================================' -ForegroundColor Cyan
    Write-Host '⬇️ 【正在從 GitHub 拉取所有專案更新...】' -ForegroundColor Green
    Write-Host '=================================================================' -ForegroundColor Cyan

    $pullCount = 0
    foreach ($item in $scanList) {
        if ($item.Behind -eq 0) { continue }
        $pullCount++
        Write-Host "⏳ 正在更新 $($item.Name)..." -ForegroundColor Yellow
        Push-Location $item.Path
        try {
            & git pull --rebase origin main
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ $($item.Name) 更新成功！" -ForegroundColor Green
            } else {
                Write-Host "❌ $($item.Name) 更新失敗，請手動檢視衝突。" -ForegroundColor Red
            }
        } finally {
            Pop-Location
        }
    }
    if ($pullCount -eq 0) {
        Write-Host "✨ 所有專案已是最新進度，無需拉取。" -ForegroundColor Green
    } else {
        Write-Host '🎉 雲端更新拉取完成！' -ForegroundColor Green
    }
}

function Invoke-SyncAI() {
    Write-Host ''
    Write-Host '=================================================================' -ForegroundColor Cyan
    Write-Host '🔀 【正在分發 00_home 的 AI 憲法與 Skills 至所有專案...】' -ForegroundColor Green
    Write-Host '=================================================================' -ForegroundColor Cyan

    $syncScript = Join-Path $homeRepo 'scripts\sync_codex.ps1'
    if (Test-Path -LiteralPath $syncScript) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $syncScript -Execute
    } else {
        Write-Host "⚠️ 找不到 sync_codex.ps1" -ForegroundColor Red
    }
}

function Invoke-PushAll($scanList) {
    Write-Host ''
    Write-Host '=================================================================' -ForegroundColor Cyan
    Write-Host '⬆️ 【正在推送本地修改至 GitHub...】' -ForegroundColor Green
    Write-Host '=================================================================' -ForegroundColor Cyan

    $pushCount = 0
    foreach ($item in $scanList) {
        if ($item.Ahead -eq 0 -and -not $item.HasUncommitted) { continue }
        $pushCount++
        Write-Host "⏳ 正在處理推送：$($item.Name)..." -ForegroundColor Yellow
        Push-Location $item.Path
        try {
            if ($item.HasUncommitted) {
                # 敏感資料安全掃描
                $diffText = (& git diff HEAD 2>$null) -join "`n"
                $untrackedFiles = (& git status --porcelain 2>$null) | Where-Object { $_ -match '^\?\?' }
                foreach ($uf in $untrackedFiles) {
                    $uPath = $uf.Substring(3).Trim()
                    if (Test-Path -LiteralPath $uPath) {
                        try { $diffText += "`n" + (Get-Content -LiteralPath $uPath -Raw -ErrorAction SilentlyContinue) } catch {}
                    }
                }

                $foundSensitive = $false
                foreach ($pattern in $sensitivePatterns) {
                    if ($diffText -match $pattern) {
                        $foundSensitive = $true
                        Write-Host "🚨 安全攔截：$($item.Name) 偵測到疑似 API Key/Token 敏感資訊，已阻止推送！" -ForegroundColor Red
                        break
                    }
                }
                if ($foundSensitive) { continue }

                & git add -A
                $commitMsg = "sync: 自動同步本機修改進度 ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
                & git commit -m "$commitMsg"
            }

            & git push origin main
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ $($item.Name) 推送成功！" -ForegroundColor Green
            } else {
                Write-Host "❌ $($item.Name) 推送失敗。" -ForegroundColor Red
            }
        } finally {
            Pop-Location
        }
    }
    if ($pushCount -eq 0) {
        Write-Host "✨ 本地無任何待推送修改。" -ForegroundColor Green
    } else {
        Write-Host '🎉 本地修改推送完成！' -ForegroundColor Green
    }
}

# 進入主流程
$currentStats = Scan-Projects

if ($Action -eq 'Auto') {
    Invoke-PullAll $currentStats
    Invoke-SyncAI
    $updatedStats = Scan-Projects
    Invoke-PushAll $updatedStats
    return
} elseif ($Action -eq 'Pull') {
    Invoke-PullAll $currentStats
    return
} elseif ($Action -eq 'Push') {
    Invoke-PushAll $currentStats
    return
} elseif ($Action -eq 'SyncAI') {
    Invoke-SyncAI
    return
}

# 互動選單模式
Write-Host ''
Write-Host '請選擇操作：' -ForegroundColor Cyan
Write-Host '  [1] ⚡ 智慧全自動同步 (先拉取 ➜ 分發AI憲法 ➜ 再推送，最推薦 ⭐)' -ForegroundColor Yellow
Write-Host '  [2] ⬇️  僅拉取雲端更新 (Pull All)'
Write-Host '  [3] ⬆️  僅推送本地修改 (Push All)'
Write-Host '  [4] 🔀  僅分發 AI 憲法與 Skills 至本機專案'
Write-Host '  [0] 離開 (或直接按 Enter)'
Write-Host '=================================================================' -ForegroundColor Cyan

$choice = (Read-Host '請輸入選項 (0-4)').Trim()

switch ($choice) {
    '1' {
        Invoke-PullAll $currentStats
        Invoke-SyncAI
        $updatedStats = Scan-Projects
        Invoke-PushAll $updatedStats
    }
    '2' { Invoke-PullAll $currentStats }
    '3' { Invoke-PushAll $currentStats }
    '4' { Invoke-SyncAI }
    default {
        Write-Host '已離開，未執行任何操作。' -ForegroundColor Gray
    }
}
