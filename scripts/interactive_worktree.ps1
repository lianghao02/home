# UTF-8 Compatibility
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8


$homeRepo = Split-Path -Parent $PSScriptRoot
$githubRoot = Split-Path -Parent $homeRepo
$repoConfigPath = Join-Path $homeRepo 'development-repositories.json'

if (-not (Test-Path -LiteralPath $repoConfigPath)) {
    throw ("找不到專案清單檔案：" + $repoConfigPath)
}

$repoConfig = Get-Content -LiteralPath $repoConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
$projects = @($repoConfig.repositories | Where-Object { $_.folder -ne '00_home' })

Clear-Host
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  🛠️  雙 Agent 協作工作區建立精靈 (Dual-Agent Worktree Setup) " -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "💡 判定提醒：" -ForegroundColor DarkYellow
Write-Host "  • 輪流接力／單一 Agent 開發 (90%)：直接開原專案即可，無需建立 Worktree。" -ForegroundColor DarkGray
Write-Host "  • 雙 Agent 同時開工／大範圍實驗 (10%)：建議建立獨立 Worktree 避免暫存踩踏。" -ForegroundColor DarkGray
Write-Host "-----------------------------------------------------------------" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "請選擇要為哪一個專案建立 Codex 與 Antigravity 獨立工作區：" -ForegroundColor Yellow
Write-Host ""

for ($i = 0; $i -lt $projects.Count; $i++) {
    $num = "{0,2}" -f ($i + 1)
    $folder = $projects[$i].folder
    Write-Host ("  [" + $num + "] " + $folder) -ForegroundColor White
}
Write-Host "  [ Q] 離開 (Quit)" -ForegroundColor DarkGray
Write-Host ""

$maxCount = $projects.Count
$promptMsg = "請輸入專案編號 (1-" + $maxCount + ") 或 Q"
$choice = Read-Host $promptMsg
if ([string]::IsNullOrWhiteSpace($choice) -or $choice -match '^(?i)q') {
    Write-Host "已取消操作。" -ForegroundColor Yellow
    return
}

$index = $null
if (-not [int]::TryParse($choice, [ref]$index) -or $index -lt 1 -or $index -gt $projects.Count) {
    Write-Host "❌ 無效的選擇，請重新執行。" -ForegroundColor Red
    return
}

$selectedProject = $projects[$index - 1].folder
$mainProjectPath = Join-Path $githubRoot $selectedProject

Write-Host ""
Write-Host "-----------------------------------------------------------------" -ForegroundColor DarkCyan
Write-Host ("📋 專案選定：" + $selectedProject) -ForegroundColor Green
Write-Host ("📁 主庫位置：" + $mainProjectPath) -ForegroundColor DarkGray
Write-Host "-----------------------------------------------------------------" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "🔍 正在執行預覽檢查 (Preview / Dry-Run)..." -ForegroundColor Yellow
Write-Host ""

$newWorktreeScript = Join-Path $PSScriptRoot 'New-AgentWorktree.ps1'

try {
    & $newWorktreeScript -Project $selectedProject -Agent both -WhatIf
} catch {
    Write-Host ""
    Write-Host "❌ 預覽檢查未通過：" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "請依照上述提示排除問題（例如先 Commit 主庫變更）後再試。" -ForegroundColor Yellow
    return
}

Write-Host ""
Write-Host "-----------------------------------------------------------------" -ForegroundColor DarkCyan
$confirm = Read-Host "確定要正式建立上述雙 Agent 工作區嗎？[預設 Y，輸入 N 取消]"
if ($confirm -match '^(?i)n(o)?$') {
    Write-Host "已取消建立。" -ForegroundColor Yellow
    return
}

Write-Host ""
Write-Host "🚀 正在建立雙 Agent 工作區..." -ForegroundColor Cyan
Write-Host ""

try {
    & $newWorktreeScript -Project $selectedProject -Agent both
    Write-Host ""
    Write-Host "=================================================================" -ForegroundColor Green
    Write-Host "✅ 雙 Agent 工作區建立完成！" -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host ("👉 Codex 開工目錄       : " + (Join-Path $githubRoot ($selectedProject + "-codex")) + " (分支: codex/dev)") -ForegroundColor Cyan
    Write-Host ("👉 Antigravity 開工目錄 : " + (Join-Path $githubRoot ($selectedProject + "-ag")) + " (分支: ag/dev)") -ForegroundColor Magenta
    Write-Host ""
    Write-Host "💡 提示：兩者完全獨立隔離，不共用未提交檔案與暫存資料。" -ForegroundColor White
} catch {
    Write-Host ""
    Write-Host "❌ 建立過程發生錯誤：" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
