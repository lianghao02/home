[CmdletBinding()]
param(
    [switch]$Execute,
    [switch]$RemoveSourceAfterValidation,
    [switch]$FinalizeBackups,
    [switch]$AllowDirtyGit,
    [switch]$InternalRelay,
    [string]$TargetWorkspace = 'D:\Development\GitHub',
    [string]$TargetCacheRoot = 'D:\Caches'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# ASCII-only source is intentional. Windows PowerShell 5 may decode UTF-8 files
# without a BOM using the active ANSI code page and corrupt non-ASCII strings.

$CONFIG = [ordered]@{
    SchemaVersion = 1
    RequiredFreeBufferGB = 5
    SourceWorkspace = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'GitHub'
    TargetWorkspace = [IO.Path]::GetFullPath($TargetWorkspace)
    TargetCacheRoot = [IO.Path]::GetFullPath($TargetCacheRoot)
    LogRoot = 'D:\MigrationLogs'
    ManifestPath = 'D:\MigrationLogs\development-migration-latest.json'
    BlockedProcesses = @(
        'Antigravity',
        'Code',
        'Codex',
        'GitHubDesktop',
        'python',
        'pythonw'
    )
}

$userProfile = [Environment]::GetFolderPath('UserProfile')
$localAppData = [Environment]::GetFolderPath('LocalApplicationData')
$CONFIG.CacheItems = @(
    [ordered]@{
        Name = 'huggingface'
        Source = Join-Path $userProfile '.cache\huggingface'
        Target = Join-Path $CONFIG.TargetCacheRoot 'huggingface'
        EnvironmentVariable = 'HF_HOME'
    },
    [ordered]@{
        Name = 'pip'
        Source = Join-Path $localAppData 'pip\Cache'
        Target = Join-Path $CONFIG.TargetCacheRoot 'pip'
        EnvironmentVariable = 'PIP_CACHE_DIR'
    },
    [ordered]@{
        Name = 'ms-playwright'
        Source = Join-Path $localAppData 'ms-playwright'
        Target = Join-Path $CONFIG.TargetCacheRoot 'ms-playwright'
        EnvironmentVariable = 'PLAYWRIGHT_BROWSERS_PATH'
    }
)

function Write-Step {
    param([Parameter(Mandatory)][string]$Message)
    Write-Host ("[STEP] {0}" -f $Message) -ForegroundColor Cyan
}

function Write-Ok {
    param([Parameter(Mandatory)][string]$Message)
    Write-Host ("[ OK ] {0}" -f $Message) -ForegroundColor Green
}

function Write-Warn {
    param([Parameter(Mandatory)][string]$Message)
    Write-Host ("[WARN] {0}" -f $Message) -ForegroundColor Yellow
}

function Assert-ExactChildPath {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Parent
    )

    $resolvedPath = [IO.Path]::GetFullPath($Path)
    $resolvedParent = [IO.Path]::GetFullPath($Parent).TrimEnd('\') + '\'
    if (-not $resolvedPath.StartsWith($resolvedParent, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path is outside the expected parent: $resolvedPath"
    }
    if ($resolvedPath -eq $resolvedParent.TrimEnd('\')) {
        throw "Path must not equal its parent: $resolvedPath"
    }
    return $resolvedPath
}

function Assert-RegularDirectory {
    param(
        [Parameter(Mandatory)][string]$Path,
        [switch]$AllowMissing
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        if ($AllowMissing) { return }
        throw "Directory does not exist: $Path"
    }
    $item = Get-Item -LiteralPath $Path -Force
    if (-not $item.PSIsContainer) {
        throw "Path is not a directory: $Path"
    }
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw "Unexpected reparse point: $Path"
    }
}

function Get-DirectoryMetrics {
    param([Parameter(Mandatory)][string]$Path)

    $fileCount = [long]0
    $directoryCount = [long]0
    $bytes = [long]0
    $stack = [Collections.Generic.Stack[IO.DirectoryInfo]]::new()
    $stack.Push((Get-Item -LiteralPath $Path -Force))

    while ($stack.Count -gt 0) {
        $directory = $stack.Pop()
        foreach ($item in @(Get-ChildItem -LiteralPath $directory.FullName -Force -ErrorAction Stop)) {
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                continue
            }
            if ($item.PSIsContainer) {
                $directoryCount++
                $stack.Push($item)
            }
            else {
                $fileCount++
                $bytes += [long]$item.Length
            }
        }
    }

    return [pscustomobject]@{
        Files = $fileCount
        Directories = $directoryCount
        Bytes = $bytes
    }
}

function Get-GitSnapshots {
    param([Parameter(Mandatory)][string]$Workspace)

    if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) {
        throw 'git.exe is not available on PATH.'
    }

    $repositories = [Collections.Generic.List[string]]::new()
    if (Test-Path -LiteralPath (Join-Path $Workspace '.git')) {
        $repositories.Add('')
    }
    foreach ($directory in @(Get-ChildItem -LiteralPath $Workspace -Directory -Force)) {
        if (Test-Path -LiteralPath (Join-Path $directory.FullName '.git')) {
            $repositories.Add($directory.Name)
        }
    }

    $snapshots = [ordered]@{}
    foreach ($relativePath in ($repositories | Sort-Object -Unique)) {
        $repositoryPath = if ($relativePath) {
            Join-Path $Workspace $relativePath
        }
        else {
            $Workspace
        }
        $status = @(& git.exe -C $repositoryPath status --porcelain=v1 --untracked-files=all 2>&1)
        if ($LASTEXITCODE -ne 0) {
            throw "Unable to read Git status: $repositoryPath`n$($status -join "`n")"
        }
        $snapshots[$relativePath] = ($status -join "`n")
    }
    return $snapshots
}

function Compare-GitSnapshots {
    param(
        [Parameter(Mandatory)][System.Collections.IDictionary]$Before,
        [Parameter(Mandatory)][System.Collections.IDictionary]$After
    )

    $beforeKeys = @($Before.Keys | Sort-Object)
    $afterKeys = @($After.Keys | Sort-Object)
    if (($beforeKeys -join "`n") -ne ($afterKeys -join "`n")) {
        throw 'Git repository list changed during migration.'
    }
    foreach ($key in $beforeKeys) {
        if ([string]$Before[$key] -ne [string]$After[$key]) {
            throw "Git status changed during migration: $key"
        }
    }
}

function Assert-GitSnapshotsClean {
    param([Parameter(Mandatory)][System.Collections.IDictionary]$Snapshots)

    $dirty = [Collections.Generic.List[string]]::new()
    foreach ($key in $Snapshots.Keys) {
        if (-not [string]::IsNullOrWhiteSpace([string]$Snapshots[$key])) {
            $displayName = if ([string]::IsNullOrEmpty([string]$key)) { '.' } else { [string]$key }
            $dirty.Add($displayName)
        }
    }
    if ($dirty.Count -gt 0 -and -not $AllowDirtyGit) {
        throw ("Git repositories contain uncommitted or untracked changes: {0}. Commit and push first, or use -AllowDirtyGit only after making a separate backup." -f ($dirty -join ', '))
    }
    if ($dirty.Count -gt 0) {
        Write-Warn ("Dirty Git state explicitly allowed for: {0}" -f ($dirty -join ', '))
    }
    else {
        Write-Ok 'All discovered Git repositories have clean working trees.'
    }
}

function Get-ValidatedJunctionTarget {
    param(
        [Parameter(Mandatory)][string]$Link,
        [Parameter(Mandatory)][string]$ExpectedTarget
    )

    $item = Get-Item -LiteralPath $Link -Force -ErrorAction Stop
    if (-not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw "Expected a junction: $Link"
    }
    $actualTarget = [IO.Path]::GetFullPath([string]$item.Target)
    $expected = [IO.Path]::GetFullPath($ExpectedTarget)
    if ($actualTarget -ne $expected) {
        throw "Junction target mismatch: $Link -> $actualTarget"
    }
    return $actualTarget
}

function Save-MigrationManifest {
    param([Parameter(Mandatory)][System.Collections.IDictionary]$Manifest)

    New-Item -ItemType Directory -Path (Split-Path -Parent $CONFIG.ManifestPath) -Force | Out-Null
    $temporaryManifest = "$($CONFIG.ManifestPath).tmp"
    $Manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $temporaryManifest -Encoding UTF8
    Move-Item -LiteralPath $temporaryManifest -Destination $CONFIG.ManifestPath -Force
    Write-Ok "Migration manifest saved: $($CONFIG.ManifestPath)"
}

function Invoke-BackupFinalization {
    if (-not (Test-Path -LiteralPath $CONFIG.ManifestPath)) {
        throw "Migration manifest does not exist: $($CONFIG.ManifestPath)"
    }
    $manifest = Get-Content -LiteralPath $CONFIG.ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ([int]$manifest.schemaVersion -ne $CONFIG.SchemaVersion) {
        throw 'Unsupported migration manifest schema.'
    }
    if ([bool]$manifest.backupsRemoved) {
        Write-Ok 'Backups were already finalized. No action is required.'
        return
    }

    $blocked = @(Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $CONFIG.BlockedProcesses -contains $_.ProcessName
    } | Select-Object -ExpandProperty ProcessName -Unique)
    if ($blocked.Count -gt 0) {
        throw "Close these processes before finalization: $($blocked -join ', ')"
    }

    foreach ($migration in @($manifest.migrations)) {
        Get-ValidatedJunctionTarget -Link $migration.source -ExpectedTarget $migration.target | Out-Null
        Assert-RegularDirectory -Path $migration.target
        Assert-RegularDirectory -Path $migration.backup
        Assert-MetricsEqual -Source $migration.backup -Destination $migration.target | Out-Null
        if ([bool]$migration.isWorkspace) {
            $backupGit = Get-GitSnapshots -Workspace $migration.backup
            $targetGit = Get-GitSnapshots -Workspace $migration.target
            Compare-GitSnapshots -Before $backupGit -After $targetGit
            Write-Ok 'Workspace Git states match before backup finalization.'
        }
    }

    foreach ($migration in @($manifest.migrations)) {
        Remove-ValidatedBackup `
            -BackupPath $migration.backup `
            -ExpectedParent $migration.backupParent `
            -ExpectedPrefix $migration.backupPrefix
    }

    $manifest.backupsRemoved = $true
    $manifest.finalizedAt = (Get-Date).ToString('o')
    $updated = [ordered]@{}
    foreach ($property in $manifest.PSObject.Properties) {
        $updated[$property.Name] = $property.Value
    }
    Save-MigrationManifest -Manifest $updated
    Write-Ok 'All validated C-drive backups were finalized.'
}

function Invoke-RobocopyDirectory {
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Destination
    )

    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    $arguments = @(
        $Source,
        $Destination,
        '/E',
        '/COPY:DAT',
        '/DCOPY:DAT',
        '/XJ',
        '/R:1',
        '/W:1',
        '/MT:8',
        '/NP',
        '/NFL',
        '/NDL'
    )
    & robocopy.exe @arguments
    $exitCode = $LASTEXITCODE
    if ($exitCode -ge 8) {
        throw "Robocopy failed with exit code $exitCode."
    }
    Write-Ok "Robocopy completed with exit code $exitCode."
}

function Assert-MetricsEqual {
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Destination
    )

    Write-Step "Measuring source: $Source"
    $sourceMetrics = Get-DirectoryMetrics -Path $Source
    Write-Step "Measuring destination: $Destination"
    $destinationMetrics = Get-DirectoryMetrics -Path $Destination
    if ($sourceMetrics.Files -ne $destinationMetrics.Files -or
        $sourceMetrics.Directories -ne $destinationMetrics.Directories -or
        $sourceMetrics.Bytes -ne $destinationMetrics.Bytes) {
        throw ("Metric mismatch. Source files={0}, dirs={1}, bytes={2}; destination files={3}, dirs={4}, bytes={5}." -f
            $sourceMetrics.Files,
            $sourceMetrics.Directories,
            $sourceMetrics.Bytes,
            $destinationMetrics.Files,
            $destinationMetrics.Directories,
            $destinationMetrics.Bytes)
    }
    Write-Ok ("Verified files={0}, directories={1}, bytes={2}." -f
        $sourceMetrics.Files,
        $sourceMetrics.Directories,
        $sourceMetrics.Bytes)
    return $sourceMetrics
}

function New-ValidatedJunction {
    param(
        [Parameter(Mandatory)][string]$Link,
        [Parameter(Mandatory)][string]$Target
    )

    if (Test-Path -LiteralPath $Link) {
        throw "Junction path already exists: $Link"
    }
    New-Item -ItemType Junction -Path $Link -Target $Target | Out-Null
    $item = Get-Item -LiteralPath $Link -Force
    if (-not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw "Junction validation failed: $Link"
    }
    $resolvedTarget = [IO.Path]::GetFullPath([string]$item.Target)
    if ($resolvedTarget -ne [IO.Path]::GetFullPath($Target)) {
        throw "Junction target mismatch: $Link"
    }
    Write-Ok "Junction created: $Link -> $Target"
}

function Remove-ValidatedBackup {
    param(
        [Parameter(Mandatory)][string]$BackupPath,
        [Parameter(Mandatory)][string]$ExpectedParent,
        [Parameter(Mandatory)][string]$ExpectedPrefix
    )

    $resolved = Assert-ExactChildPath -Path $BackupPath -Parent $ExpectedParent
    $leaf = Split-Path -Leaf $resolved
    if (-not $leaf.StartsWith($ExpectedPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Unexpected backup directory name: $resolved"
    }
    Assert-RegularDirectory -Path $resolved
    Remove-Item -LiteralPath $resolved -Recurse -Force -ErrorAction Stop
    if (Test-Path -LiteralPath $resolved) {
        throw "Backup deletion failed: $resolved"
    }
    Write-Ok "Removed validated backup: $resolved"
}

function Move-WithJunction {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Target,
        [Parameter(Mandatory)][string]$Timestamp,
        [switch]$IsWorkspace
    )

    $sourceParent = Split-Path -Parent $Source
    $targetParent = Split-Path -Parent $Target
    $staging = "$Target.migrating"
    $backup = Join-Path $sourceParent ("{0}.migration-backup-{1}" -f (Split-Path -Leaf $Source), $Timestamp)

    Assert-ExactChildPath -Path $Source -Parent $sourceParent | Out-Null
    Assert-ExactChildPath -Path $Target -Parent $targetParent | Out-Null
    Assert-ExactChildPath -Path $staging -Parent $targetParent | Out-Null
    Assert-ExactChildPath -Path $backup -Parent $sourceParent | Out-Null
    Assert-RegularDirectory -Path $Source

    if (Test-Path -LiteralPath $Target) {
        throw "Final target already exists: $Target"
    }
    if (Test-Path -LiteralPath $backup) {
        throw "Backup path already exists: $backup"
    }

    Write-Step "Copying $Name to staging: $staging"
    Invoke-RobocopyDirectory -Source $Source -Destination $staging
    Assert-MetricsEqual -Source $Source -Destination $staging | Out-Null

    Write-Step "Switching $Name to the D drive."
    Rename-Item -LiteralPath $Source -NewName (Split-Path -Leaf $backup) -ErrorAction Stop
    try {
        Rename-Item -LiteralPath $staging -NewName (Split-Path -Leaf $Target) -ErrorAction Stop
        New-ValidatedJunction -Link $Source -Target $Target
    }
    catch {
        Write-Warn "Cutover failed. Starting rollback for $Name."
        if (Test-Path -LiteralPath $Source) {
            $sourceItem = Get-Item -LiteralPath $Source -Force
            if ($sourceItem.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                Remove-Item -LiteralPath $Source -Force -ErrorAction Stop
            }
        }
        if ((Test-Path -LiteralPath $Target) -and -not (Test-Path -LiteralPath $staging)) {
            Rename-Item -LiteralPath $Target -NewName (Split-Path -Leaf $staging) -ErrorAction Stop
        }
        if ((Test-Path -LiteralPath $backup) -and -not (Test-Path -LiteralPath $Source)) {
            Rename-Item -LiteralPath $backup -NewName (Split-Path -Leaf $Source) -ErrorAction Stop
        }
        throw
    }

    return [pscustomobject]@{
        Name = $Name
        Source = $Source
        Target = $Target
        Backup = $backup
        BackupParent = $sourceParent
        BackupPrefix = "$(Split-Path -Leaf $Source).migration-backup-"
        IsWorkspace = [bool]$IsWorkspace
    }
}

function Start-RelayIfNeeded {
    if (-not $Execute -or $InternalRelay) {
        return $false
    }

    $relayRoot = Join-Path ([IO.Path]::GetTempPath()) 'codex-development-migration'
    New-Item -ItemType Directory -Path $relayRoot -Force | Out-Null
    $relayScript = Join-Path $relayRoot 'migrate_development_to_d.ps1'
    Copy-Item -LiteralPath $PSCommandPath -Destination $relayScript -Force

    $relayArguments = @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', ('"{0}"' -f $relayScript),
        '-Execute',
        '-InternalRelay',
        '-TargetWorkspace', ('"{0}"' -f $CONFIG.TargetWorkspace),
        '-TargetCacheRoot', ('"{0}"' -f $CONFIG.TargetCacheRoot)
    )
    if ($RemoveSourceAfterValidation) {
        $relayArguments += '-RemoveSourceAfterValidation'
    }
    if ($AllowDirtyGit) {
        $relayArguments += '-AllowDirtyGit'
    }

    Write-Step "Relaying execution to: $relayScript"
    $process = Start-Process -FilePath 'powershell.exe' -ArgumentList $relayArguments -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        throw "Relay process failed with exit code $($process.ExitCode)."
    }
    return $true
}

$mutex = [Threading.Mutex]::new($false, 'Global\CodexDevelopmentMigration')
$mutexAcquired = $false
$transcriptStarted = $false

try {
    $mutexAcquired = $mutex.WaitOne(0)
    if (-not $mutexAcquired) {
        throw 'Another migration process is already running.'
    }

    if ($Execute -and $FinalizeBackups) {
        throw 'Use either -Execute or -FinalizeBackups, not both.'
    }
    if ($RemoveSourceAfterValidation -and -not $Execute) {
        throw '-RemoveSourceAfterValidation requires -Execute.'
    }

    if ($Execute -and -not $InternalRelay) {
        $mutex.ReleaseMutex()
        $mutexAcquired = $false
        if (Start-RelayIfNeeded) {
            exit 0
        }
    }

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $activeLogRoot = if ($Execute) {
        $CONFIG.LogRoot
    }
    else {
        Join-Path ([IO.Path]::GetTempPath()) 'codex-development-migration-logs'
    }
    New-Item -ItemType Directory -Path $activeLogRoot -Force | Out-Null
    $logPath = Join-Path $activeLogRoot "development-migration-$timestamp.log"
    Start-Transcript -LiteralPath $logPath -Force | Out-Null
    $transcriptStarted = $true

    Write-Host 'Development migration C -> D' -ForegroundColor White
    $mode = if ($FinalizeBackups) { 'FINALIZE_BACKUPS' } elseif ($Execute) { 'EXECUTE' } else { 'DRY_RUN' }
    Write-Host ("Mode: {0}" -f $mode)
    Write-Host ("Workspace: {0} -> {1}" -f $CONFIG.SourceWorkspace, $CONFIG.TargetWorkspace)
    Write-Host ("Cache root: {0}" -f $CONFIG.TargetCacheRoot)
    Write-Host ("Log: {0}" -f $logPath)

    if ($FinalizeBackups) {
        Invoke-BackupFinalization
        exit 0
    }

    $targetWorkspaceRoot = [IO.Path]::GetPathRoot($CONFIG.TargetWorkspace)
    $targetCacheRoot = [IO.Path]::GetPathRoot($CONFIG.TargetCacheRoot)
    if ($targetWorkspaceRoot -ne $targetCacheRoot) {
        throw 'Workspace and cache targets must be on the same destination volume.'
    }
    $volume = Get-Volume -DriveLetter $targetWorkspaceRoot.Substring(0, 1)
    if ($volume.FileSystem -ne 'NTFS' -or $volume.HealthStatus -ne 'Healthy') {
        throw "Destination volume must be healthy NTFS: $targetWorkspaceRoot"
    }

    Assert-RegularDirectory -Path $CONFIG.SourceWorkspace
    $workspaceMetrics = Get-DirectoryMetrics -Path $CONFIG.SourceWorkspace
    $requiredBytes = [long]$workspaceMetrics.Bytes
    foreach ($cache in $CONFIG.CacheItems) {
        if (Test-Path -LiteralPath $cache.Source) {
            Assert-RegularDirectory -Path $cache.Source
            $requiredBytes += [long](Get-DirectoryMetrics -Path $cache.Source).Bytes
        }
    }
    $requiredBytes += [long]($CONFIG.RequiredFreeBufferGB * 1GB)
    if ([long]$volume.SizeRemaining -lt $requiredBytes) {
        throw ("Insufficient destination space. Required={0:N2} GB, free={1:N2} GB." -f
            ($requiredBytes / 1GB),
            ($volume.SizeRemaining / 1GB))
    }
    Write-Ok ("Destination free space: {0:N2} GB." -f ($volume.SizeRemaining / 1GB))
    Write-Ok ("Workspace files={0}, directories={1}, bytes={2}." -f
        $workspaceMetrics.Files,
        $workspaceMetrics.Directories,
        $workspaceMetrics.Bytes)

    if (-not $Execute) {
        Write-Warn 'DRY_RUN only. No files, junctions, or environment variables were changed.'
        Write-Host 'Execute and keep recoverable C-drive backups:'
        Write-Host '  .\migrate_development_to_d.ps1 -Execute'
        Write-Host 'Execute and delete validated C-drive backups after all checks:'
        Write-Host '  .\migrate_development_to_d.ps1 -Execute -RemoveSourceAfterValidation'
        Write-Host 'Recommended two-stage flow:'
        Write-Host '  .\migrate_development_to_d.ps1 -Execute'
        Write-Host '  # Restart and test all tools, then close them again.'
        Write-Host '  .\migrate_development_to_d.ps1 -FinalizeBackups'
        exit 0
    }

    $blocked = @(Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $CONFIG.BlockedProcesses -contains $_.ProcessName
    } | Select-Object -ExpandProperty ProcessName -Unique)
    if ($blocked.Count -gt 0) {
        throw "Close these processes before migration: $($blocked -join ', ')"
    }

    $beforeGit = Get-GitSnapshots -Workspace $CONFIG.SourceWorkspace
    Assert-GitSnapshotsClean -Snapshots $beforeGit
    $migrations = [Collections.Generic.List[object]]::new()

    New-Item -ItemType Directory -Path (Split-Path -Parent $CONFIG.TargetWorkspace) -Force | Out-Null
    $workspaceMigration = Move-WithJunction `
        -Name 'GitHub workspace' `
        -Source $CONFIG.SourceWorkspace `
        -Target $CONFIG.TargetWorkspace `
        -Timestamp $timestamp `
        -IsWorkspace
    $migrations.Add($workspaceMigration)

    $afterGit = Get-GitSnapshots -Workspace $CONFIG.TargetWorkspace
    Compare-GitSnapshots -Before $beforeGit -After $afterGit
    Write-Ok 'All Git repository states match after workspace migration.'

    New-Item -ItemType Directory -Path $CONFIG.TargetCacheRoot -Force | Out-Null
    foreach ($cache in $CONFIG.CacheItems) {
        if (-not (Test-Path -LiteralPath $cache.Source)) {
            Write-Warn "Cache source does not exist; skipped: $($cache.Source)"
            [Environment]::SetEnvironmentVariable(
                $cache.EnvironmentVariable,
                $cache.Target,
                'User'
            )
            continue
        }
        $cacheMigration = Move-WithJunction `
            -Name $cache.Name `
            -Source $cache.Source `
            -Target $cache.Target `
            -Timestamp $timestamp
        $migrations.Add($cacheMigration)
        [Environment]::SetEnvironmentVariable(
            $cache.EnvironmentVariable,
            $cache.Target,
            'User'
        )
        Write-Ok "User environment variable set: $($cache.EnvironmentVariable)=$($cache.Target)"
    }

    Assert-MetricsEqual -Source $CONFIG.SourceWorkspace -Destination $CONFIG.TargetWorkspace | Out-Null
    $finalGit = Get-GitSnapshots -Workspace $CONFIG.SourceWorkspace
    Compare-GitSnapshots -Before $beforeGit -After $finalGit
    Write-Ok 'Final workspace and Git validation passed through the C-drive junction.'

    $manifest = [ordered]@{
        schemaVersion = $CONFIG.SchemaVersion
        createdAt = (Get-Date).ToString('o')
        sourceWorkspace = $CONFIG.SourceWorkspace
        targetWorkspace = $CONFIG.TargetWorkspace
        targetCacheRoot = $CONFIG.TargetCacheRoot
        backupsRemoved = $false
        finalizedAt = $null
        migrations = @(
            foreach ($migration in $migrations) {
                [ordered]@{
                    name = $migration.Name
                    source = $migration.Source
                    target = $migration.Target
                    backup = $migration.Backup
                    backupParent = $migration.BackupParent
                    backupPrefix = $migration.BackupPrefix
                    isWorkspace = $migration.IsWorkspace
                }
            }
        )
    }
    Save-MigrationManifest -Manifest $manifest

    if ($RemoveSourceAfterValidation) {
        Write-Step 'Removing validated C-drive backups.'
        foreach ($migration in $migrations) {
            Remove-ValidatedBackup `
                -BackupPath $migration.Backup `
                -ExpectedParent $migration.BackupParent `
                -ExpectedPrefix $migration.BackupPrefix
        }
        $manifest.backupsRemoved = $true
        $manifest.finalizedAt = (Get-Date).ToString('o')
        Save-MigrationManifest -Manifest $manifest
    }
    else {
        Write-Warn 'Validated C-drive backups were retained for recovery.'
        foreach ($migration in $migrations) {
            Write-Host ("Backup: {0}" -f $migration.Backup)
        }
        Write-Warn 'C-drive space is not reclaimed until these backups are removed.'
    }

    Write-Ok 'Migration completed successfully.'
    Write-Host 'Restart Windows before using Codex, Antigravity, VS Code, or Python projects.'
}
catch {
    Write-Host ("[FAIL] {0}" -f $_.Exception.Message) -ForegroundColor Red
    Write-Host 'No stronger retry or automatic destructive recovery will be attempted.' -ForegroundColor Red
    exit 1
}
finally {
    if ($transcriptStarted) {
        Stop-Transcript | Out-Null
    }
    if ($mutexAcquired) {
        $mutex.ReleaseMutex()
    }
    $mutex.Dispose()
}
