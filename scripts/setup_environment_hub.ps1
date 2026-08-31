# UTF-8 Compatibility
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$homeRepo = Split-Path -Parent $PSScriptRoot

Write-Host '=================================================================' -ForegroundColor Cyan
Write-Host '🛠️ 【環境建置與工具安裝中樞】' -ForegroundColor Yellow
Write-Host '=================================================================' -ForegroundColor Cyan
Write-Host '請選擇要執行的環境操作：' -ForegroundColor Cyan
Write-Host '  [1] 🐍 建置所有 Python 專案可攜環境（python_embed / 01、07、10）'
Write-Host '  [2] 🔧 診斷並安裝開發者工具鏈 (Git, GH CLI, Rust, .NET SDK, Playwright)'
Write-Host '  [0] 離開 (或直接按 Enter)'
Write-Host '=================================================================' -ForegroundColor Cyan

$choice = (Read-Host '請輸入選項 (0-2)').Trim()

switch ($choice) {
    '1' {
        $envScript = Join-Path $homeRepo 'setup_all_envs.ps1'
        if (Test-Path -LiteralPath $envScript) {
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $envScript
        } else {
            Write-Host "⚠️ 找不到 setup_all_envs.ps1" -ForegroundColor Red
        }
    }
    '2' {
        $toolScript = Join-Path $homeRepo 'scripts\setup_developer_tools.ps1'
        if (Test-Path -LiteralPath $toolScript) {
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $toolScript -Execute
        } else {
            Write-Host "⚠️ 找不到 setup_developer_tools.ps1" -ForegroundColor Red
        }
    }
    default {
        Write-Host '已離開，未執行任何環境變更。' -ForegroundColor Gray
    }
}
