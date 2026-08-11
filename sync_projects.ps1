[CmdletBinding()]
param(
    [string]$DevelopmentRoot = 'D:\Development\GitHub',
    [switch]$Execute,
    [switch]$SkipAgentSetup
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$config = [ordered]@{
    Manifest = Join-Path $PSScriptRoot 'development-repositories.json'
    AgentSetup = Join-Path $PSScriptRoot 'sync_codex.ps1'
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

foreach ($item in $manifest.repositories) {
    $target = Join-Path $root ([string]$item.folder)
    $safeTarget = $target.Replace('\', '/')
    $url = 'https://github.com/{0}/{1}.git' -f $manifest.githubOwner, $item.repository

    if (-not (Test-Path -LiteralPath $target)) {
        Write-Status 'CLONE' "$url -> $target"
        if ($Execute) {
            git clone $url $target
            if ($LASTEXITCODE -ne 0) { throw "Clone failed: $url" }
        }
        continue
    }

    if (-not (Test-Path -LiteralPath (Join-Path $target '.git'))) {
        Write-Status 'WARN' "Existing directory is not a Git repository; skipped: $target"
        continue
    }

    $changes = @(git -c "safe.directory=$safeTarget" -C $target status --porcelain)
    if ($changes.Count -gt 0) {
        Write-Status 'SKIP' "Working tree has uncommitted changes: $target"
        continue
    }

    Write-Status 'READY' $target
    if ($Execute) {
        git -c "safe.directory=$safeTarget" -C $target pull --ff-only
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
