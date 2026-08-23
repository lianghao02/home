[CmdletBinding()]
param([switch]$Execute)

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
    Write-Host '預覽完成；加入 -Execute 才會安裝工具與瀏覽器。'
    exit 0
}

if (-not (Test-Tool 'gh')) { throw 'GitHub CLI 安裝後尚未出現在目前終端機，請重新開啟此工具再繼續。' }
& gh auth status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host '需要登入 GitHub；即將開啟瀏覽器授權流程。'
    & gh auth login --web --git-protocol https
    if ($LASTEXITCODE -ne 0) { throw 'GitHub 登入未完成。' }
}

Write-Host '正在安裝或更新 Playwright 與 Chromium…'
& npm install --global playwright
if ($LASTEXITCODE -ne 0) { throw 'Playwright 安裝失敗。' }
& npx playwright install chromium
if ($LASTEXITCODE -ne 0) { throw 'Chromium 安裝失敗。' }

Write-Host '完成：Git、GitHub CLI、Playwright 與 Chromium 已可使用。'
