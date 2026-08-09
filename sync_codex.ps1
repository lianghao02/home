[CmdletBinding()]
param([switch]$CheckOnly, [switch]$Force)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$homeRepo = Split-Path -Parent $PSCommandPath
$githubRoot = Split-Path -Parent $homeRepo
$codexHome = Join-Path $env:USERPROFILE '.codex'
$skillRoot = Join-Path $env:USERPROFILE '.agents\skills'
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

    if ($targetHash -and -not $knownHash -and -not $Force) {
        throw "Target exists but is not managed; refusing overwrite: $Target"
    }
    if ($targetHash -and $knownHash -and $targetHash -ne $knownHash -and -not $Force) {
        throw "Target was modified after deployment; refusing overwrite: $Target"
    }
    $New[$Target] = $sourceHash
    if ($targetHash -eq $sourceHash) { Write-Output "Current: $Target"; return }
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
$items = @(
    @{ Source = Join-Path $homeRepo 'configs\AGENTS.md'; Target = Join-Path $codexHome 'AGENTS.md' },
    @{ Source = Join-Path $homeRepo 'configs\skills\accesslint'; Target = Join-Path $skillRoot 'accesslint' },
    @{ Source = Join-Path $homeRepo 'configs\skills\addyosmani-perf'; Target = Join-Path $skillRoot 'addyosmani-perf' },
    @{ Source = Join-Path $homeRepo 'configs\skills\caveman'; Target = Join-Path $skillRoot 'caveman' },
    @{ Source = Join-Path $homeRepo 'configs\skills\webapp-testing'; Target = Join-Path $skillRoot 'webapp-testing' }
)
foreach ($item in $items) { Sync-ManagedItem $item.Source $item.Target $old $new }

if (-not $CheckOnly) {
    $result = [ordered]@{
        schemaVersion = 1
        source = $homeRepo
        generatedAt = (Get-Date).ToString('o')
        excluded = @{
            skillCreator = 'Not deployed because it conflicts with the built-in Codex skill-creator.'
            formalWriting = 'Deployed separately because the repository package uses a POSIX symlink that is not materialized on Windows.'
        }
        items = @($new.Keys | Sort-Object | ForEach-Object { [ordered]@{ target = $_; hash = $new[$_] } })
    }
    $result | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
    Write-Output "Manifest: $manifestPath"
}
