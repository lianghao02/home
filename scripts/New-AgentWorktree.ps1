# UTF-8 Compatibility
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)] [string]$Project,
    [Parameter(Mandatory)] [ValidateSet('codex', 'ag', 'both')] [string]$Agent,
    [switch]$SkipRemoteUpdate
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8


function Invoke-Git { param([string]$Repository, [string[]]$Arguments)
    $safePath = $Repository.Replace('\', '/')
    & git '-c' "safe.directory=$safePath" -C $Repository @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Git 指令失敗：git $($Arguments -join ' ')" }
}
function Resolve-ProjectPath { param([string]$InputProject, [string]$Root)
    if (Test-Path -LiteralPath $InputProject -PathType Container) { return [IO.Path]::GetFullPath($InputProject) }
    $exact = Join-Path $Root $InputProject
    if (Test-Path -LiteralPath $exact -PathType Container) { return [IO.Path]::GetFullPath($exact) }
    $matches = @(Get-ChildItem -LiteralPath $Root -Directory | Where-Object { $_.Name -like "*_$InputProject" -or $_.Name -like "*$InputProject" })
    if ($matches.Count -eq 1) { return $matches[0].FullName }
    if ($matches.Count -gt 1) { throw "找到多個符合 [$InputProject] 的專案，請改用完整資料夾名稱或路徑。" }
    throw "找不到專案：$InputProject"
}
function Get-WorktreePathForBranch { param([string]$Repository, [string]$Branch)
    $records = @(Invoke-Git -Repository $Repository -Arguments @('worktree', 'list', '--porcelain'))
    $currentPath = $null
    foreach ($record in $records) {
        if ($record -like 'worktree *') { $currentPath = $record.Substring(9); continue }
        if ($record -eq "branch refs/heads/$Branch") { return $currentPath }
    }
    return $null
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw '找不到 Git，請先安裝 Git for Windows。' }
$homeRepository = Split-Path -Parent $PSScriptRoot
$projectPath = Resolve-ProjectPath -InputProject $Project -Root (Split-Path -Parent $homeRepository)
if (-not (Test-Path -LiteralPath (Join-Path $projectPath '.git'))) { throw "[$projectPath] 不是 Git Repository。" }
$mainWorktree = Get-WorktreePathForBranch -Repository $projectPath -Branch 'main'
if (-not $mainWorktree) { throw '找不到 main 分支的工作區，已停止以避免從錯誤基準建立 Worktree。' }
if (@(Invoke-Git -Repository $mainWorktree -Arguments @('status', '--porcelain')).Count -gt 0) { throw "main 工作區 [$mainWorktree] 有未提交變更；請先處理後再建立 Agent Worktree。" }
if (-not $SkipRemoteUpdate -and $PSCmdlet.ShouldProcess($mainWorktree, 'git fetch origin 與 git pull --ff-only')) {
    Invoke-Git -Repository $mainWorktree -Arguments @('fetch', 'origin')
    Invoke-Git -Repository $mainWorktree -Arguments @('pull', '--ff-only')
}
$agents = if ($Agent -eq 'both') { @('codex', 'ag') } else { @($Agent) }
foreach ($agentName in $agents) {
    $branch = "$agentName/dev"
    $target = Join-Path (Split-Path -Parent $mainWorktree) ("{0}-{1}" -f (Split-Path -Leaf $mainWorktree), $agentName)
    $existing = Get-WorktreePathForBranch -Repository $mainWorktree -Branch $branch
    if ($existing) { Write-Output "已存在：$branch → $existing"; continue }
    if (Test-Path -LiteralPath $target) { throw "目標資料夾已存在但未綁定 [$branch]：$target。腳本不會覆寫。" }
    if ($PSCmdlet.ShouldProcess($target, "建立 $branch Worktree")) {
        Invoke-Git -Repository $mainWorktree -Arguments @('worktree', 'add', '-b', $branch, $target, 'main')
        Write-Output "已建立：$branch → $target"
    } else { Write-Output "預覽：將建立 $branch → $target" }
}
