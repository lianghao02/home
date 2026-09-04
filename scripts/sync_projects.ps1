# UTF-8 Compatibility
[CmdletBinding()]
param(
    [string]$DevelopmentRoot = '',
    [switch]$Execute,
    [switch]$SkipAgentSetup,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8


$projectRoot = Split-Path -Parent $PSScriptRoot
$config = [ordered]@{
    Manifest = Join-Path $projectRoot 'development-repositories.json'
    AgentSetup = Join-Path $PSScriptRoot 'sync_codex.ps1'
}

function Test-IsDangerousPath([string]$PathToCheck) {
    $resolved = [IO.Path]::GetFullPath($PathToCheck).TrimEnd('\', '/')
    $protectedPaths = @(
        $env:USERPROFILE,
        [Environment]::GetFolderPath('Desktop'),
        $(if ($env:USERPROFILE) { Join-Path $env:USERPROFILE 'Downloads' }),
        [IO.Path]::GetTempPath()
    )

    foreach ($protectedPath in $protectedPaths) {
        if ([string]::IsNullOrWhiteSpace($protectedPath)) {
            continue
        }
        $normalizedProtectedPath = [IO.Path]::GetFullPath($protectedPath).TrimEnd('\', '/')
        if ($resolved -eq $normalizedProtectedPath) {
            return $true
        }
    }
    if ($resolved -match '^[a-zA-Z]:$') {
        return $true
    }
    return $false
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw '找不到 Git 工具，請先安裝 Git for Windows。'
}
if (-not (Test-Path -LiteralPath $config.Manifest -PathType Leaf)) {
    throw "找不到專案清單檔案：$($config.Manifest)"
}

if ([string]::IsNullOrWhiteSpace($DevelopmentRoot)) {
    $parent = Split-Path -Parent $projectRoot
    if ($parent -and ((Split-Path -Leaf $parent) -match '(?i)^GitHub$')) {
        $DevelopmentRoot = $parent
    } elseif (Test-Path -LiteralPath 'D:\') {
        $DevelopmentRoot = 'D:\Development\GitHub'
    } else {
        $DevelopmentRoot = 'C:\Development\GitHub'
    }
}

$manifest = Get-Content -LiteralPath $config.Manifest -Raw -Encoding UTF8 | ConvertFrom-Json
$root = [IO.Path]::GetFullPath($DevelopmentRoot)

if (Test-IsDangerousPath $root) {
    throw "安全防禦阻擋：指定的開發根目錄 [$root] 屬於危險或系統敏感目錄（如桌面、下載、使用者根目錄或磁碟根目錄），已強制終止以防污染！"
}

Write-Host '================================================================='
if ($Execute) {
    Write-Host '🚀 【執行模式】正式從 GitHub 拉取／下載最新專案與部署'
} else {
    Write-Host '🔍 【預覽模式】更新遠端參照並掃描同步狀態（不修改工作檔案）'
}
Write-Host "📁 【工作目錄】$root"
Write-Host '================================================================='
Write-Host ''

if ($Execute -and -not (Test-Path -LiteralPath $root)) {
    New-Item -ItemType Directory -Path $root -Force | Out-Null
}

$repoIndex = 0
$totalRepos = $manifest.repositories.Count
$failures = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

foreach ($item in $manifest.repositories) {
    $repoIndex++
    $folderName = [string]$item.folder
    $target = Join-Path $root $folderName
    $safeTarget = $target.Replace('\', '/')
    $url = 'https://github.com/{0}/{1}.git' -f $manifest.githubOwner, $item.repository
    $prefix = "[$repoIndex/$totalRepos] $folderName"

    if (-not (Test-Path -LiteralPath $target)) {
        if ($Execute) {
            Write-Host "$prefix : 📥 正在從 GitHub 下載專案 (git clone)..."
            $oldEap = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            try {
                $null = git clone "$url" "$target" 2>$null
            } finally {
                $ErrorActionPreference = $oldEap
            }

            if ($LASTEXITCODE -ne 0) {
                $message = "$folderName：下載失敗（$url）"
                $failures.Add($message)
                Write-Host "$prefix : ❌ $message"
                continue
            }
            Write-Host "$prefix : ✅ 下載完成"
        } else {
            Write-Host "$prefix : 📥 待下載（新電腦缺少此專案）"
        }
        continue
    }

    if (-not (Test-Path -LiteralPath (Join-Path $target '.git'))) {
        if (($folderName -eq '00_Dev-Control-Center' -or $folderName -eq '00_home') -and $Execute) {
            Write-Host "$prefix : 🛠️  本機缺少 .git，正在自動初始化並連結遠端..."
            $oldEap = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            try {
                git -C "$target" init 2>$null
                git -C "$target" remote add origin "$url" 2>$null
                git -C "$target" fetch origin main 2>$null
                git -C "$target" branch -M main 2>$null
                git -C "$target" reset --mixed origin/main 2>$null
            } finally {
                $ErrorActionPreference = $oldEap
            }
            Write-Host "$prefix : ✅ 已完成 Git 版本庫自癒連結"
        } else {
            $message = "$folderName：本機已存在但不是 Git 專案"
            $warnings.Add($message)
            Write-Host "$prefix : ⚠️  已略過（$message）"
            continue
        }
    }

    $fetchOutput = @()
    $fetchExitCode = 1
    for ($fetchAttempt = 1; $fetchAttempt -le 2; $fetchAttempt++) {
        $oldEap = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            $fetchOutput = @(git -c "safe.directory=$safeTarget" -C "$target" fetch --prune origin 2>&1)
            $fetchExitCode = $LASTEXITCODE
        } finally {
            $ErrorActionPreference = $oldEap
        }
        if ($fetchExitCode -eq 0) { break }
        if ($fetchAttempt -eq 1) {
            Write-Host "$prefix : 🌐 GitHub 連線失敗，2 秒後重試一次..."
            Start-Sleep -Seconds 2
        }
    }
    if ($fetchExitCode -ne 0) {
        $message = "$folderName：無法取得 GitHub 最新分支"
        $failures.Add($message)
        Write-Host "$prefix : ❌ $message"
        if ($fetchOutput) { Write-Host ($fetchOutput -join [Environment]::NewLine) }
        continue
    }

    $oldEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $changes = @()
    try {
        $changes = @(git -c "safe.directory=$safeTarget" -C "$target" status --porcelain 2>$null)
    } finally {
        $ErrorActionPreference = $oldEap
    }

    if ($LASTEXITCODE -ne 0) {
        $message = "$folderName：無法讀取 Git 狀態"
        $failures.Add($message)
        Write-Host "$prefix : ❌ $message"
        continue
    }
    if ($changes.Count -gt 0) {
        $message = "$folderName：本機有未提交修改"
        $warnings.Add($message)
        Write-Host "$prefix : 🛡️  保護略過（本機有未提交的修改，不強制覆蓋）"
        continue
    }

    $branch = ''
    $upstream = @()
    $oldEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $branch = @(git -c "safe.directory=$safeTarget" -C "$target" branch --show-current 2>$null)
        $branchExitCode = $LASTEXITCODE
        if ($branch) {
            $branch = [string]$branch[0]
        }
        if ($branchExitCode -eq 0 -and $branch) {
            $upstream = @(git -c "safe.directory=$safeTarget" -C "$target" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>$null)
            $upstreamExitCode = $LASTEXITCODE
        }
    } finally {
        $ErrorActionPreference = $oldEap
    }

    if ($branchExitCode -ne 0 -or -not $branch) {
        $message = "$folderName：無法判斷目前 Git 分支"
        $failures.Add($message)
        Write-Host "$prefix : ❌ $message"
        continue
    }

    if ($upstreamExitCode -ne 0 -or -not $upstream) {
        if ($Execute) {
            Write-Host "$prefix : 🛠️  $branch 未設定上游分支，正在連結 origin/$branch..."
            $oldEap = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            try {
                $linkOutput = @(git -c "safe.directory=$safeTarget" -C "$target" branch --set-upstream-to="origin/$branch" "$branch" 2>&1)
                $linkExitCode = $LASTEXITCODE
            } finally {
                $ErrorActionPreference = $oldEap
            }
            if ($linkExitCode -ne 0) {
                $message = "$folderName：無法設定上游分支 origin/$branch"
                $failures.Add($message)
                Write-Host "$prefix : ❌ $message"
                if ($linkOutput) { Write-Host ($linkOutput -join [Environment]::NewLine) }
                continue
            }
            Write-Host "$prefix : ✅ 已連結上游分支 origin/$branch"
            $upstream = @("origin/$branch")
        } else {
            $message = "$folderName：$branch 未設定上游分支"
            $warnings.Add($message)
            Write-Host "$prefix : ⚠️  $message（執行模式將嘗試連結 origin/$branch）"
            continue
        }
    }

    $oldEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $counts = @(git -c "safe.directory=$safeTarget" -C "$target" rev-list --left-right --count 'HEAD...@{upstream}' 2>$null)
        $countsExitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldEap
    }
    if ($countsExitCode -ne 0 -or -not $counts) {
        $message = "$folderName：無法比較本機與上游分支"
        $failures.Add($message)
        Write-Host "$prefix : ❌ $message"
        continue
    }

    $parts = ([string]$counts[0]).Trim() -split '\s+'
    $ahead = [int]$parts[0]
    $behind = [int]$parts[1]

    if ($Execute) {
        if ($ahead -gt 0 -and $behind -gt 0) {
            $message = "$folderName：本機與 GitHub 已分歧（本機 +$ahead、GitHub +$behind），需人工合併"
            $failures.Add($message)
            Write-Host "$prefix : ❌ $message"
            continue
        }
        if ($ahead -gt 0) {
            $message = "$folderName：本機領先 GitHub $ahead 筆提交，未自動推送"
            $warnings.Add($message)
            Write-Host "$prefix : ⬆️  $message"
            continue
        }
        if ($behind -eq 0) {
            Write-Host "$prefix : ✅ 已是最新進度"
            continue
        }

        Write-Host "$prefix : 🔄 GitHub 領先 $behind 筆提交，正在安全快轉..."
        $oldEap = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            $pullOutput = @(git -c "safe.directory=$safeTarget" -C "$target" merge --ff-only '@{upstream}' 2>&1)
            $pullExitCode = $LASTEXITCODE
        } finally {
            $ErrorActionPreference = $oldEap
        }
        if ($pullExitCode -ne 0) {
            $message = "$folderName：安全快轉失敗"
            $failures.Add($message)
            Write-Host "$prefix : ❌ $message"
            if ($pullOutput) { Write-Host ($pullOutput -join [Environment]::NewLine) }
            continue
        }
        Write-Host "$prefix : ✅ 已快轉 $behind 筆提交"
    } else {
        if ($ahead -eq 0 -and $behind -eq 0) {
            Write-Host "$prefix : ✅ 本機與 GitHub 已同步"
        } elseif ($ahead -eq 0) {
            Write-Host "$prefix : ⬇️  GitHub 領先 $behind 筆提交，可安全快轉"
        } elseif ($behind -eq 0) {
            $message = "$folderName：本機領先 GitHub $ahead 筆提交"
            $warnings.Add($message)
            Write-Host "$prefix : ⬆️  $message"
        } else {
            $message = "$folderName：本機與 GitHub 已分歧（本機 +$ahead、GitHub +$behind）"
            $failures.Add($message)
            Write-Host "$prefix : ❌ $message"
        }
    }
}

Write-Host '-----------------------------------------------------------------'
if (-not $SkipAgentSetup) {
    Write-Host '🤖 正在同步 AI Agent 設定與 Skills...'
    if (-not (Test-Path -LiteralPath $config.AgentSetup -PathType Leaf)) {
        $failures.Add("找不到 Agent 設定腳本：$($config.AgentSetup)")
    } else {
        try {
            if ($Execute) { & $config.AgentSetup } else { & $config.AgentSetup -CheckOnly }
        } catch {
            $failures.Add("Agent 設定同步失敗：$($_.Exception.Message)")
        }
    }
}

Write-Host ''
Write-Host '================================================================='
if ($failures.Count -gt 0) {
    Write-Host "❌ 【完成但需處理】失敗或分歧：$($failures.Count) 項；保護略過或待推送：$($warnings.Count) 項。"
    foreach ($failure in $failures) { Write-Host "  - $failure" }
    foreach ($warning in $warnings) { Write-Host "  - $warning" }
    Write-Host '================================================================='
    exit 1
} elseif ($Execute) {
    Write-Host "🎉 【完成】$totalRepos 個專案與 AI Agent 設定已完成同步；提醒事項：$($warnings.Count) 項。"
    foreach ($warning in $warnings) { Write-Host "  - $warning" }
} else {
    Write-Host "💡 【完成】$totalRepos 個專案預覽掃描結束；提醒事項：$($warnings.Count) 項。"
    foreach ($warning in $warnings) { Write-Host "  - $warning" }
    Write-Host '若要正式拉取下載，請雙擊【2_從GitHub更新所有專案.bat】。'
}
Write-Host '================================================================='
