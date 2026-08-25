[CmdletBinding()]
param([switch]$Execute, [switch]$WithPlaywright)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Test-Tool([string]$Name) {
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Install-WingetPackage([string]$Id, [string]$Name) {
    if (-not (Test-Tool 'winget')) {
        throw "找不到 winget，無法安裝 $Name。請先安裝或更新 Windows App Installer。"
    }
    if (-not $Execute) {
        Write-Host "待安裝：$Name ($Id)"
        return
    }
    Write-Host "正在安裝：$Name"
    & winget install --id $Id --exact --source winget --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { throw "安裝失敗：$Name" }
}

if (Test-Tool 'git') { Write-Host 'Git：已安裝' } else { Install-WingetPackage 'Git.Git' 'Git for Windows' }
if (Test-Tool 'gh') { Write-Host 'GitHub CLI：已安裝' } else { Install-WingetPackage 'GitHub.cli' 'GitHub CLI' }
if (Test-Tool 'node') { Write-Host 'Node.js：已安裝' } else { Install-WingetPackage 'OpenJS.NodeJS.LTS' 'Node.js LTS' }

if (-not $Execute) {
    Write-Host '預覽完成；加入 -Execute 才會安裝 Git、GitHub CLI 與 Node.js。'
    Write-Host 'Playwright 為選用工具；只有明確加入 -WithPlaywright 才會全域安裝。'
    exit 0
}

if (-not (Test-Tool 'gh')) { throw 'GitHub CLI 安裝後尚未出現在目前終端機，請重新開啟此工具再繼續。' }
& gh auth status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host '需要登入 GitHub；即將開啟瀏覽器授權流程。'
    & gh auth login --web --git-protocol https
    if ($LASTEXITCODE -ne 0) { throw 'GitHub 登入未完成。' }
}

if ($WithPlaywright) {
    Write-Host '正在安裝或更新選用的 Playwright 與 Chromium…'
    & npm install --global playwright
    if ($LASTEXITCODE -ne 0) { throw 'Playwright 安裝失敗。' }
    & npx playwright install chromium
    if ($LASTEXITCODE -ne 0) { throw 'Chromium 安裝失敗。' }
} else {
    Write-Host '已略過全域 Playwright；網頁驗證優先使用 Codex 內建 Browser 或專案既有測試設定。'
}

Write-Host '完成：Git、GitHub CLI 與 Node.js 已可使用。'
