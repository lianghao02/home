# UTF-8 Compatibility
[CmdletBinding()]
param(
    [switch]$CheckOnly,
    [switch]$Force,
    [switch]$PruneBackups,
    [switch]$Execute
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

if ($Execute) {
    $Force = $true
    $PruneBackups = $true
} elseif (-not $Force -and -not $CheckOnly) {
    $CheckOnly = $true
}

$homeRepo = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($homeRepo)) {
    $homeRepo = 'C:\Development\GitHub\00_home'
}
$githubRoot = Split-Path -Parent $homeRepo
$codexHome = Join-Path $env:USERPROFILE '.codex'
$agentHome = Join-Path $env:USERPROFILE '.agents'
$codexSkillRoot = Join-Path $agentHome 'skills'
$antigravityHome = Join-Path $env:USERPROFILE '.gemini\config'
$antigravitySkillRoot = Join-Path $antigravityHome 'skills'
$manifestPath = Join-Path $codexHome 'antigravity-bridge.json'
$skillManifestPath = Join-Path $homeRepo 'configs\skills-manifest.json'

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

function Get-BackupDirectory([string]$Target) {
    $backupSession = Get-Date -Format 'yyyyMMdd-HHmmss'
    $targetLabel = [regex]::Replace($Target.TrimEnd([char[]]('\', '/')), '[^A-Za-z0-9._-]', '_').Trim('_')
    if ([string]::IsNullOrWhiteSpace($targetLabel)) {
        $targetLabel = 'managed-item'
    }
    return Join-Path $codexHome (Join-Path (Join-Path 'bridge-backups' $backupSession) $targetLabel)
}

function Sync-ManagedItem([string]$Source, [string]$Target, [hashtable]$Old, [hashtable]$New) {
    if (-not (Test-Path -LiteralPath $Source)) { throw "Source does not exist: $Source" }
    $sourceHash = Get-TreeHash $Source
    $targetHash = if (Test-Path -LiteralPath $Target) { Get-TreeHash $Target } else { $null }
    $knownHash = if ($Old.ContainsKey($Target)) { $Old[$Target] } else { $null }

    $New[$Target] = $sourceHash
    if ($targetHash -eq $sourceHash) { Write-Output "Current: $Target"; return }

    $isEmptyFile = $false
    if ($targetHash -and (Test-Path -LiteralPath $Target -PathType Leaf)) {
        $targetItem = Get-Item -LiteralPath $Target
        if ($targetItem.Length -eq 0) {
            $isEmptyFile = $true
        }
    }

    if ($CheckOnly) {
        if ($targetHash -and -not $knownHash -and -not $isEmptyFile) {
            Write-Warning "Unmanaged (未受管項目，正式同步需 -Force): $Target"
            return
        }
        if ($targetHash -and $knownHash -and $targetHash -ne $knownHash) {
            Write-Warning "Modified (曾被修改，正式同步需 -Force): $Target"
            return
        }
        Write-Output "Pending: $Target"
        return
    }

    if ($targetHash -and -not $knownHash -and -not $Force -and -not $isEmptyFile) {
        throw "Target exists but is not managed; refusing overwrite: $Target"
    }
    if ($targetHash -and $knownHash -and $targetHash -ne $knownHash -and -not $Force) {
        throw "Target was modified after deployment; refusing overwrite: $Target"
    }

    New-Item -ItemType Directory -Path (Split-Path -Parent $Target) -Force | Out-Null
    if (Test-Path -LiteralPath $Target) {
        $backup = Get-BackupDirectory $Target
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
if (-not (Test-Path -LiteralPath $skillManifestPath -PathType Leaf)) {
    throw "找不到 Skill 分流清單：$skillManifestPath"
}
$skillManifest = Get-Content -LiteralPath $skillManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$items = @(
    @{ Source = Join-Path $homeRepo 'configs\AGENTS.md'; Target = Join-Path $codexHome 'AGENTS.md' },
    @{ Source = Join-Path $homeRepo 'configs\AGENTS.md'; Target = Join-Path $antigravityHome 'AGENTS.md' }
)
$mcpConfigSrc = Join-Path $homeRepo 'configs\mcp_config.json'
if (Test-Path -LiteralPath $mcpConfigSrc -PathType Leaf) {
    $items += @{ Source = $mcpConfigSrc; Target = Join-Path $antigravityHome 'mcp_config.json' }
}
$skillSets = @(
    @{ Name = '共用'; Skills = @($skillManifest.shared); Targets = @($codexSkillRoot, $antigravitySkillRoot) },
    @{ Name = 'Codex 專用'; Skills = @($skillManifest.codexOnly); Targets = @($codexSkillRoot) },
    @{ Name = 'Antigravity 專用'; Skills = @($skillManifest.antigravityOnly); Targets = @($antigravitySkillRoot) }
)
$assignedSkills = @{}
foreach ($set in $skillSets) {
    foreach ($skill in $set.Skills) {
        $skillName = [string]$skill
        if ([string]::IsNullOrWhiteSpace($skillName)) { continue }
        if ($assignedSkills.ContainsKey($skillName)) {
            throw "Skill [$skillName] 同時出現在 [$($assignedSkills[$skillName])] 與 [$($set.Name)]，請只保留一個分流類別。"
        }
        $assignedSkills[$skillName] = $set.Name
        $source = Join-Path $homeRepo "configs\skills\$skillName"
        foreach ($targetRoot in $set.Targets) {
            $items += @{ Source = $source; Target = Join-Path $targetRoot $skillName }
        }
    }
}
$availableSkillDirs = Get-ChildItem -LiteralPath (Join-Path $homeRepo 'configs\skills') -Directory -ErrorAction SilentlyContinue
foreach ($dir in $availableSkillDirs) {
    if (-not $assignedSkills.ContainsKey($dir.Name)) {
        Write-Warning "發現未分流的 Skill 目錄 [$($dir.Name)]，未包含於 configs\skills-manifest.json 中。"
    }
}
foreach ($item in $items) { Sync-ManagedItem $item.Source $item.Target $old $new }

if (-not $CheckOnly -and $PruneBackups) {
    $backupBase = Join-Path $codexHome 'bridge-backups'
    if (Test-Path -LiteralPath $backupBase) {
        $oldBackups = Get-ChildItem -LiteralPath $backupBase -Directory | Sort-Object CreationTime -Descending | Select-Object -Skip 10
        foreach ($oldBackup in $oldBackups) {
            Remove-Item -LiteralPath $oldBackup.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

if (-not $CheckOnly) {
    $result = [ordered]@{
        schemaVersion = 1
        source = $homeRepo
        generatedAt = (Get-Date).ToString('o')
        excluded = @{
            codexStandaloneSkills = '.codex\skills is preserved for individual local Skills and is not overwritten by this shared deployment.'
            codexSystemSkills = '.codex\skills\.system is managed by Codex and is never overwritten.'
            routing = 'configs\skills-manifest.json controls shared, Codex-only, and Antigravity-only Skill deployment.'
        }
        items = @($new.Keys | Sort-Object | ForEach-Object { [ordered]@{ target = $_; hash = $new[$_] } })
    }
    $json = $result | ConvertTo-Json -Depth 5
    [System.IO.File]::WriteAllText($manifestPath, $json, [System.Text.UTF8Encoding]::new($false))
    Write-Output "Manifest: $manifestPath"
}
