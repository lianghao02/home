[CmdletBinding()]
param(
    [string]$DevelopmentRoot = 'D:\Development\GitHub',
    [switch]$Execute,
    [switch]$SkipAgentSetup,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$config = [ordered]@{
    Manifest = Join-Path $PSScriptRoot 'development-repositories.json'
    AgentSetup = Join-Path $PSScriptRoot 'sync_codex.ps1'
    RootAgents = Join-Path $PSScriptRoot 'configs\AGENTS.md'
}

function Write-Status([string]$Level, [string]$Message) {
    Write-Host ('[{0}] {1}' -f $Level, $Message)
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git was not found. Install Git for Windows first.'
}
if (-not (Test-Path -LiteralPath $config.Manifest -PathType Leaf)) {
    throw "Repository manifest not found: $($config.Manifest)"
}

$manifest = Get-Content -LiteralPath $config.Manifest -Raw -Encoding UTF8 | ConvertFrom-Json
$root = [IO.Path]::GetFullPath($DevelopmentRoot)
Write-Status 'MODE' $(if ($Execute) { 'EXECUTE' } else { 'DRY_RUN' })
Write-Status 'ROOT' $root

if ($Execute -and -not (Test-Path -LiteralPath $root)) {
    New-Item -ItemType Directory -Path $root -Force | Out-Null
}

$rootAgentsTarget = Join-Path $root 'AGENTS.md'
$sourceAgentsHash = (Get-FileHash -LiteralPath $config.RootAgents -Algorithm SHA256).Hash
$targetAgentsHash = if (Test-Path -LiteralPath $rootAgentsTarget -PathType Leaf) {
    (Get-FileHash -LiteralPath $rootAgentsTarget -Algorithm SHA256).Hash
} else { $null }
if ($targetAgentsHash -eq $sourceAgentsHash) {
    Write-Status 'CURRENT' $rootAgentsTarget
} elseif ($targetAgentsHash -and -not $Force) {
    Write-Status 'SKIP' "Root AGENTS.md differs; use -Force to back up and replace: $rootAgentsTarget"
} else {
    Write-Status 'AGENTS' "Pending root guidance: $rootAgentsTarget"
    if ($Execute) {
        if ($targetAgentsHash) {
            $backup = Join-Path $root ('AGENTS.backup-{0}.md' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
            Copy-Item -LiteralPath $rootAgentsTarget -Destination $backup -Force
        }
        Copy-Item -LiteralPath $config.RootAgents -Destination $rootAgentsTarget -Force
    }
}

foreach ($item in $manifest.repositories) {
    $target = Join-Path $root ([string]$item.folder)
    $safeTarget = $target.Replace('\', '/')
    $url = 'https://github.com/{0}/{1}.git' -f $manifest.githubOwner, $item.repository

    if (-not (Test-Path -LiteralPath $target)) {
        Write-Status 'CLONE' "$url -> $target"
        if ($Execute) {
            git clone "$url" "$target"
            if ($LASTEXITCODE -ne 0) { throw "Clone failed: $url" }
        }
        continue
    }

    if (-not (Test-Path -LiteralPath (Join-Path $target '.git'))) {
        Write-Status 'WARN' "Existing directory is not a Git repository; skipped: $target"
        continue
    }

    $changes = @(git -c "safe.directory=$safeTarget" -C "$target" status --porcelain)
    if ($LASTEXITCODE -ne 0) {
        Write-Status 'WARN' "Failed to query Git status for: $target"
        continue
    }
    if ($changes.Count -gt 0) {
        Write-Status 'SKIP' "Working tree has uncommitted changes: $target"
        continue
    }

    Write-Status 'READY' $target
    if ($Execute) {
        git -c "safe.directory=$safeTarget" -C "$target" pull --ff-only
        if ($LASTEXITCODE -ne 0) { throw "Pull failed: $target" }
    }
}

if (-not $SkipAgentSetup) {
    if (-not (Test-Path -LiteralPath $config.AgentSetup -PathType Leaf)) {
        throw "Agent setup script not found: $($config.AgentSetup)"
    }
    if ($Execute) { & $config.AgentSetup } else { & $config.AgentSetup -CheckOnly }
}

Write-Status 'DONE' $(if ($Execute) { 'Projects and agent settings are synchronized.' } else { 'Preview only. No files changed. Run with -Execute to apply.' })
