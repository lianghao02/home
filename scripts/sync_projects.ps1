# PowerShell UTF-8 Compatibility
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
    Write-Host '🔍 【預覽模式】僅掃描本機專案與 GitHub 同步狀態（尚未修改檔案）'
}
Write-Host "📁 【工作目錄】$root"
Write-Host '================================================================='
Write-Host ''

if ($Execute -and -not (Test-Path -LiteralPath $root)) {
    New-Item -ItemType Directory -Path $root -Force | Out-Null
}

$repoIndex = 0
$totalRepos = $manifest.repositories.Count

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

            if ($LASTEXITCODE -ne 0) { throw "下載失敗：$url" }
            Write-Host "$prefix : ✅ 下載完成"
        } else {
            Write-Host "$prefix : 📥 待下載（新電腦缺少此專案）"
        }
        continue
    }

    if (-not (Test-Path -LiteralPath (Join-Path $target '.git'))) {
        if ($folderName -eq '00_home' -and $Execute) {
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
            Write-Host "$prefix : ⚠️  已略過（本機已存在但非 Git 專案）"
            continue
        }
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
        Write-Host "$prefix : ⚠️  無法讀取 Git 狀態，已略過"
        continue
    }
    if ($changes.Count -gt 0) {
        Write-Host "$prefix : 🛡️  保護略過（本機有未提交的修改，不強制覆蓋）"
        continue
    }

    if ($Execute) {
        Write-Host "$prefix : 🔄 正在從 GitHub 更新 (git pull)..."
        $oldEap = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            $null = git -c "safe.directory=$safeTarget" -C "$target" pull --ff-only 2>$null
        } finally {
            $ErrorActionPreference = $oldEap
        }

        if ($LASTEXITCODE -ne 0) { throw "更新失敗：$target" }
        Write-Host "$prefix : ✅ 已更新至最新進度"
    } else {
        Write-Host "$prefix : ✨ 準備就緒（本機工作區乾淨，可安全更新）"
    }
}

Write-Host '-----------------------------------------------------------------'
if (-not $SkipAgentSetup) {
    Write-Host '🤖 正在同步 AI Agent 設定與 Skills...'
    if (-not (Test-Path -LiteralPath $config.AgentSetup -PathType Leaf)) {
        throw "找不到 Agent 設定腳本：$($config.AgentSetup)"
    }
    if ($Execute) { & $config.AgentSetup } else { & $config.AgentSetup -CheckOnly }
}

Write-Host ''
Write-Host '================================================================='
if ($Execute) {
    Write-Host '🎉 【完成】所有專案與 AI Agent 設定已全數同步更新完畢！'
} else {
    Write-Host '💡 【完成】預覽掃描結束。若要正式拉取下載，請雙擊【2_從GitHub更新所有專案.bat】。'
}
Write-Host '================================================================='
