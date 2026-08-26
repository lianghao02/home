# PowerShell UTF-8 Compatibility
[CmdletBinding(SupportsShouldProcess)]
param([Parameter(Mandatory)][string]$Project)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$homeRepo = Split-Path -Parent $PSScriptRoot
$root = Split-Path -Parent $homeRepo
$repo = if (Test-Path -LiteralPath $Project) { [IO.Path]::GetFullPath($Project) } else { Join-Path $root $Project }
if (-not (Test-Path -LiteralPath (Join-Path $repo '.git'))) { throw "不是 Git Repository：$repo" }
$safe = $repo.Replace('\', '/')
$changes = @(& git -c "safe.directory=$safe" -C $repo status --porcelain)
if ($changes.Count -gt 0) { throw "工作區不乾淨，已略過：$repo" }
$name = Split-Path -Leaf $repo
$docs = @"
# 雙 Agent 協作

本專案共用程式、測試、文件與 CI；Codex 讀取 `.agents/AGENTS.md`，Antigravity 讀取 `.gemini/AGENTS.md`。需要平行開發時，從 `00_home` 執行：

```powershell
.\scripts\New-AgentWorktree.ps1 -Project $name -Agent both
```

提交前執行 `scripts/qa.ps1`，並依本專案既有 README 的測試方式進行功能驗收。
"@
$codex = @"
# Codex 專案指引

先閱讀根目錄 `AGENTS.md`、專案文件與 `docs/DEVELOPMENT_RULES.md`。

- 負責程式碼審查、回歸測試與小範圍修正。
- 不修改 `.gemini/`，也不複製 Antigravity 指引。
- 使用 `codex/dev` Worktree，完成後執行 `scripts/qa.ps1`。
"@
$antigravity = @"
# Antigravity 專案指引

先閱讀根目錄 `AGENTS.md`、專案文件與 `docs/DEVELOPMENT_RULES.md`。

- 負責功能實作、跨檔案整合與必要測試。
- 不修改 `.agents/`，也不複製 Codex 指引。
- 使用 `ag/dev` Worktree，完成後執行 `scripts/qa.ps1`。
"@
$qa = @'
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$safe = $root.Replace('\', '/')
& git -c "safe.directory=$safe" -C $root diff --check
if ($LASTEXITCODE -ne 0) { throw 'Git 差異格式檢查失敗。' }
$pattern = '(?i)(api[_-]?key|secret|access[_-]?token|password)\s*[:=]\s*["''][^"'']{8,}'
$files = @(& git -c "safe.directory=$safe" -C $root ls-files --cached --others --exclude-standard)
foreach ($file in $files) {
    if ($file -match '(^|/)\.env(\.|$)|\.(png|jpe?g|gif|zip|db|ico)$') { continue }
    try { if (Select-String -LiteralPath (Join-Path $root $file) -Pattern $pattern -Quiet -Encoding UTF8 -ErrorAction Stop) { throw "疑似敏感值：$file" } } catch [System.ArgumentException] { }
}
Write-Output '共用 QA 通過；請再依 README 執行本專案專屬測試。'
'@
function Write-Utf8([string]$Path, [string]$Content) { New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null; [IO.File]::WriteAllText($Path, $Content, [Text.UTF8Encoding]::new($false)) }
if ($PSCmdlet.ShouldProcess($repo, '建立雙 Agent 專案骨架')) {
    Write-Utf8 (Join-Path $repo 'docs\DEVELOPMENT_RULES.md') $docs
    Write-Utf8 (Join-Path $repo '.agents\AGENTS.md') $codex
    Write-Utf8 (Join-Path $repo '.gemini\AGENTS.md') $antigravity
    Write-Utf8 (Join-Path $repo 'scripts\qa.ps1') $qa
    Write-Output "已套用：$name"
}
