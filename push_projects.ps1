[CmdletBinding()]
param(
    [string]$DevelopmentRoot = '',
    [string]$CommitMessage = '',
    [switch]$Execute
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$config = [ordered]@{
    Manifest = Join-Path $PSScriptRoot 'development-repositories.json'
}

function Write-Status([string]$Level, [string]$Message) {
    Write-Host ('[{0}] {1}' -f $Level, $Message)
}

function Test-IsDangerousPath([string]$PathToCheck) {
    $resolved = [IO.Path]::GetFullPath($PathToCheck).TrimEnd('\', '/')
    $userProfile = [IO.Path]::GetFullPath($env:USERPROFILE).TrimEnd('\', '/')
    $desktop = [IO.Path]::GetFullPath([Environment]::GetFolderPath('Desktop')).TrimEnd('\', '/')
    $downloads = [IO.Path]::GetFullPath((Join-Path $env:USERPROFILE 'Downloads')).TrimEnd('\', '/')
    $temp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\', '/')

    if ($resolved -eq $userProfile -or $resolved -eq $desktop -or $resolved -eq $downloads -or $resolved -eq $temp) {
        return $true
    }
    if ($resolved -match '^[a-zA-Z]:$') {
        return $true
    }
    return $false
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git was not found. Install Git for Windows first.'
}
if (-not (Test-Path -LiteralPath $config.Manifest -PathType Leaf)) {
    throw "Repository manifest not found: $($config.Manifest)"
}

if ([string]::IsNullOrWhiteSpace($DevelopmentRoot)) {
    $parent = Split-Path -Parent $PSScriptRoot
    if ($parent -and ((Split-Path -Leaf $parent) -match '(?i)^GitHub$')) {
        $DevelopmentRoot = $parent
    } elseif (Test-Path -LiteralPath 'D:\') {
        $DevelopmentRoot = 'D:\Development\GitHub'
    } else {
        $DevelopmentRoot = 'C:\Development\GitHub'
    }
}

$root = [IO.Path]::GetFullPath($DevelopmentRoot)

if (Test-IsDangerousPath $root) {
    throw "安全防禦阻擋：指定的開發根目錄 [$root] 屬於危險或系統敏感目錄（如桌面、下載、使用者根目錄或磁碟根目錄），已強制終止以防污染！"
}

$manifest = Get-Content -LiteralPath $config.Manifest -Raw -Encoding UTF8 | ConvertFrom-Json

Write-Status 'MODE' $(if ($Execute) { 'EXECUTE (實際推送至 GitHub)' } else { 'DRY_RUN (僅預覽檢查，未推送)' })
Write-Status 'ROOT' $root

$totalClean = 0
$totalUpdated = 0
$totalSkipped = 0

foreach ($item in $manifest.repositories) {
    $folderName = [string]$item.folder
    $target = Join-Path $root $folderName
    $safeTarget = $target.Replace('\', '/')

    if (-not (Test-Path -LiteralPath $target)) {
        Write-Status 'SKIP' "資料夾不存在：$folderName"
        $totalSkipped++
        continue
    }

    if (-not (Test-Path -LiteralPath (Join-Path $target '.git'))) {
        Write-Status 'SKIP' "非 Git 版本庫：$folderName"
        $totalSkipped++
        continue
    }

    # 檢查是否有未 Commit 的檔案變更
    $changes = @(git -c "safe.directory=$safeTarget" -C "$target" status --porcelain)
    if ($LASTEXITCODE -ne 0) {
        Write-Status 'WARN' "無法讀取 Git 狀態：$folderName"
        $totalSkipped++
        continue
    }

    # 檢查是否有尚未 Push 的本地 Commits
    $unpushed = @()
    try {
        $branch = (git -c "safe.directory=$safeTarget" -C "$target" rev-parse --abbrev-ref HEAD 2>$null)
        if ($branch -and $branch -ne 'HEAD') {
            $unpushed = @(git -c "safe.directory=$safeTarget" -C "$target" cherry "origin/$branch" 2>$null)
        }
    } catch {
        $unpushed = @()
    }

    $hasWorkingChanges = ($changes.Count -gt 0)
    $hasUnpushedCommits = ($unpushed.Count -gt 0)

    if (-not $hasWorkingChanges -and -not $hasUnpushedCommits) {
        Write-Status 'UP-TO-DATE' "無更新，已是最新進度：$folderName"
        $totalClean++
        continue
    }

    # 有變更或待推送 commit
    $statusDesc = @()
    if ($hasWorkingChanges) { $statusDesc += "$($changes.Count) 個未提交變更" }
    if ($hasUnpushedCommits) { $statusDesc += "$($unpushed.Count) 個待推送 Commit" }
    $descStr = $statusDesc -join '、'

    if (-not $Execute) {
        Write-Status 'PENDING' "偵測到更新 ($descStr) -> 待推送：$folderName"
        $totalUpdated++
        continue
    }

    # 執行實際 Commit 與 Push
    Write-Status 'SYNCING' "正在處理推送 ($descStr)：$folderName"

    if ($hasWorkingChanges) {
        git -c "safe.directory=$safeTarget" -C "$target" add -A
        if ($LASTEXITCODE -ne 0) {
            Write-Status 'ERROR' "git add 失敗：$folderName"
            $totalSkipped++
            continue
        }

        $msg = if (-not [string]::IsNullOrWhiteSpace($CommitMessage)) {
            $CommitMessage
        } else {
            "sync: 自動同步本機專案更新 ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
        }

        git -c "safe.directory=$safeTarget" -C "$target" commit -m "$msg"
        if ($LASTEXITCODE -ne 0) {
            Write-Status 'ERROR' "git commit 失敗：$folderName"
            $totalSkipped++
            continue
        }
    }

    # 執行 git push
    git -c "safe.directory=$safeTarget" -C "$target" push
    if ($LASTEXITCODE -ne 0) {
        Write-Status 'ERROR' "git push 推送失敗（請確認網路或 remote 衝突）：$folderName"
        $totalSkipped++
        continue
    }

    Write-Status 'PUSHED' "已成功同步並推送到 GitHub：$folderName"
    $totalUpdated++
}

Write-Host ''
Write-Status 'SUMMARY' "掃描完成：$totalClean 個專案已是最新、 $totalUpdated 個專案$(if ($Execute) { '已成功推送' } else { '有待推送更新' })、 $totalSkipped 個專案略過。"
if (-not $Execute) {
    Write-Status 'NOTE' "目前為預覽模式，未對 GitHub 進行任何推送。若確認推送請加上 -Execute 參數。"
}
