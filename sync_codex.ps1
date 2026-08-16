[CmdletBinding()]
param([switch]$CheckOnly, [switch]$Force)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$homeRepo = Split-Path -Parent $PSCommandPath
$githubRoot = Split-Path -Parent $homeRepo
$codexHome = Join-Path $env:USERPROFILE '.codex'
# Codex 官方個人自訂 Skill 位置；.codex\skills\.system 保留給系統內建 Skill。
$agentHome = Join-Path $env:USERPROFILE '.agents'
$antigravityHome = Join-Path $env:USERPROFILE '.gemini\config'
$antigravitySkillRoot = Join-Path $antigravityHome 'skills'
$manifestPath = Join-Path $codexHome 'antigravity-bridge.json'

function Get-TreeHash([string]$Path) {
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
    }
    $records = Get-ChildItem -LiteralPath $Path -File -Recurse -Force |
        Sort-Object FullName |
        ForEach-Object {
            $relative = $_.FullName.Substring($Path.Length).TrimStart('\')
            '{0}|{1}' -f $relative, (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
        }
    $stream = [IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes(($records -join "`n")))
    try { return (Get-FileHash -InputStream $stream -Algorithm SHA256).Hash }
    finally { $stream.Dispose() }
}
function Sync-ManagedItem([string]$Source, [string]$Target, [hashtable]$Old, [hashtable]$New) {
    if (-not (Test-Path -LiteralPath $Source)) { throw "Source does not exist: $Source" }
    $sourceHash = Get-TreeHash $Source
    $targetHash = if (Test-Path -LiteralPath $Target) { Get-TreeHash $Target } else { $null }
    $knownHash = if ($Old.ContainsKey($Target)) { $Old[$Target] } else { $null }

    $New[$Target] = $sourceHash
    if ($targetHash -eq $sourceHash) { Write-Output "Current: $Target"; return }
    if ($targetHash -and -not $knownHash -and -not $Force) {
        throw "Target exists but is not managed; refusing overwrite: $Target"
    }
    if ($targetHash -and $knownHash -and $targetHash -ne $knownHash -and -not $Force) {
        throw "Target was modified after deployment; refusing overwrite: $Target"
    }
    if ($CheckOnly) { Write-Output "Pending: $Target"; return }

    New-Item -ItemType Directory -Path (Split-Path -Parent $Target) -Force | Out-Null
    if (Test-Path -LiteralPath $Target) {
        $backup = Join-Path $codexHome ('bridge-backups\' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
        New-Item -ItemType Directory -Path $backup -Force | Out-Null
        Copy-Item -LiteralPath $Target -Destination $backup -Recurse -Force
        Remove-Item -LiteralPath $Target -Recurse -Force
    }
    Copy-Item -LiteralPath $Source -Destination $Target -Recurse -Force
    Write-Output "Synced: $Target"
}

$old = @{}
if (Test-Path -LiteralPath $manifestPath) {
    $saved = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($item in $saved.items) { $old[[string]$item.target] = [string]$item.hash }
}
$new = @{}
$sharedSkills = @(
    'accesslint',
    'addyosmani-perf',
    'caveman',
    'document-to-markdown',
    'github-workflow',
    'project-planning',
    'release-notes',
    'webapp-testing'
)
$items = @(
    @{ Source = Join-Path $homeRepo 'configs\AGENTS.md'; Target = Join-Path $codexHome 'AGENTS.md' },
    @{ Source = Join-Path $homeRepo 'configs\AGENTS.md'; Target = Join-Path $antigravityHome 'AGENTS.md' }
)
foreach ($skill in $sharedSkills) {
    $source = Join-Path $homeRepo "configs\skills\$skill"
    $items += @{ Source = $source; Target = Join-Path (Join-Path $agentHome 'skills') $skill }
    $items += @{ Source = $source; Target = Join-Path $antigravitySkillRoot $skill }
}
$items += @{
    Source = Join-Path $homeRepo 'configs\skills\skill-creator'
    Target = Join-Path $antigravitySkillRoot 'skill-creator'
}
foreach ($item in $items) { Sync-ManagedItem $item.Source $item.Target $old $new }

if (-not $CheckOnly) {
    $backupBase = Join-Path $codexHome 'bridge-backups'
    if (Test-Path -LiteralPath $backupBase) {
        $oldBackups = Get-ChildItem -LiteralPath $backupBase -Directory | Sort-Object CreationTime -Descending | Select-Object -Skip 10
        foreach ($oldBackup in $oldBackups) {
            Remove-Item -LiteralPath $oldBackup.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    $result = [ordered]@{
        schemaVersion = 1
        source = $homeRepo
        generatedAt = (Get-Date).ToString('o')
        excluded = @{
            skillCreator = 'Custom version is Antigravity-only because Codex includes .system\skill-creator.'
            codexSystemSkills = '.codex\skills\.system is managed by Codex and is never overwritten.'
            legacyCodexCustomSkills = '.codex\skills custom Skill deployments were retired in favor of .agents\skills.'
        }
        items = @($new.Keys | Sort-Object | ForEach-Object { [ordered]@{ target = $_; hash = $new[$_] } })
    }
    $json = $result | ConvertTo-Json -Depth 5
    [System.IO.File]::WriteAllText($manifestPath, $json, [System.Text.UTF8Encoding]::new($false))
    Write-Output "Manifest: $manifestPath"
}
