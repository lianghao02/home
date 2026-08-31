# UTF-8 Compatibility
[CmdletBinding()]
param(
    [string]$DevelopmentRoot = '',
    [switch]$Execute,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 優先使用 PowerShell 7 正確解析無 BOM 的 UTF-8 子腳本；未安裝時仍支援
# Windows PowerShell 5.1，並於呼叫階段建立同目錄的暫時 BOM 複本。
$powerShell7 = Get-Command 'pwsh.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
$projectPowerShell = if ($powerShell7) { $powerShell7.Source } else { 'powershell.exe' }
$usingWindowsPowerShell = [IO.Path]::GetFileName($projectPowerShell) -ieq 'powershell.exe'

if ([string]::IsNullOrWhiteSpace($DevelopmentRoot)) {
    $DevelopmentRoot = Split-Path -Parent $PSScriptRoot
}

$root = [IO.Path]::GetFullPath($DevelopmentRoot)
if (-not (Test-Path -LiteralPath $root)) {
    throw "找不到開發根目錄：$root"
}

# 統一提供目前使用者安裝的完整 .NET SDK，讓各專案既有腳本不受 PATH 僅含 Runtime 影響。
$localDotnetRoot = Join-Path $env:LOCALAPPDATA 'Microsoft\dotnet'
$localDotnetExe = Join-Path $localDotnetRoot 'dotnet.exe'
$dotnetCommand = 'dotnet'
if (Test-Path -LiteralPath $localDotnetExe) {
    $dotnetCommand = $localDotnetExe
    $env:DOTNET_ROOT = $localDotnetRoot
    if (($env:PATH -split ';') -notcontains $localDotnetRoot) {
        $env:PATH = "$localDotnetRoot;$env:PATH"
    }
}
# 注入 Rust Cargo 與 MinGW 工具鏈 (若存在)
$cargoBin = Join-Path $env:USERPROFILE '.cargo\bin'
$mingwBin = Join-Path $env:USERPROFILE 'scoop\apps\mingw\current\bin'
if (Test-Path -LiteralPath $cargoBin) { $env:PATH = "$cargoBin;$env:PATH" }
if (Test-Path -LiteralPath $mingwBin) { $env:PATH = "$mingwBin;$env:PATH" }

function Get-ReleaseVersion([string]$VersionFile) {
    if (-not (Test-Path -LiteralPath $VersionFile -PathType Leaf)) {
        throw "找不到版本宣告檔：$VersionFile"
    }

    $version = (Get-Content -LiteralPath $VersionFile -Encoding UTF8 -TotalCount 1).Trim()
    if ($version -notmatch '^[vV]?\d+\.\d+\.\d+$') {
        throw "版本宣告格式錯誤：$VersionFile -> $version"
    }
    if ($version -notmatch '^[vV]') {
        $version = "v$version"
    }
    return $version
}

$policeImageToolkitVersion = Get-ReleaseVersion (Join-Path $root '03_Police-Image-Toolkit\src\PoliceImageToolkit\version.txt')
$systemOptimizerVersion = Get-ReleaseVersion (Join-Path $root '06_System-Optimizer-Tool\version.txt')
$paperSwitchVersion = Get-ReleaseVersion (Join-Path $root '09_PaperSwitch\version.txt')
$photoReportVersion = Get-ReleaseVersion (Join-Path $root '04_Photo-Report-Generator\version.txt')


# -----------------------------------------------------------------
# 📌 自動建立 Windows 桌面捷徑輔助函式
# -----------------------------------------------------------------
function New-DesktopShortcut {
    param(
        [string]$TargetExe,
        [string]$ShortcutName,
        [string]$Description = '',
        [string]$Arguments = '',
        [string]$WorkingDirectory = '',
        [string]$IconLocation = ''
    )

    if (-not (Test-Path -LiteralPath $TargetExe)) {
        return $false
    }

    $targetFile = $TargetExe
    if (-not $targetFile.EndsWith('.exe', [StringComparison]::OrdinalIgnoreCase)) {
        if (Test-Path -LiteralPath $targetFile -PathType Container) {
            $innerExe = Get-ChildItem -Path $targetFile -Filter "*.exe" -File | Select-Object -First 1
            if ($innerExe) { $targetFile = $innerExe.FullName } else { return $false }
        } else {
            return $false
        }
    }

    try {
        $desktop = [Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)
        if (-not (Test-Path -LiteralPath $desktop)) {
            return $false
        }

        $shortcutPath = Join-Path $desktop "$ShortcutName.lnk"
        $wsh = New-Object -ComObject WScript.Shell
        $shortcut = $wsh.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $targetFile
        $shortcut.WorkingDirectory = if (-not [string]::IsNullOrWhiteSpace($WorkingDirectory)) { $WorkingDirectory } else { Split-Path -Parent $targetFile }
        if (-not [string]::IsNullOrWhiteSpace($Arguments)) {
            $shortcut.Arguments = $Arguments
        }
        if (-not [string]::IsNullOrWhiteSpace($IconLocation)) {
            $shortcut.IconLocation = $IconLocation
        }
        if (-not [string]::IsNullOrWhiteSpace($Description)) {
            $shortcut.Description = $Description
        }
        $shortcut.Save()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wsh) | Out-Null
        Write-Host "  📌 [桌面捷徑] 已建立/更新桌面捷徑 ➜ $ShortcutName.lnk" -ForegroundColor Cyan
        return $true
    } catch {
        Write-Host "  ⚠️ 建立桌面捷徑失敗：$($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

$projects = @(
    [PSCustomObject]@{
        Name = '01_AG-MONITOR-Smart-Video-Screening'
        BuildScript = Join-Path $root '01_AG-MONITOR-Smart-Video-Screening\scripts\build_portable_release.py'
        BuildArguments = @()
        SourceExe = Join-Path $root '01_AG-MONITOR-Smart-Video-Screening\dist\AG-MONITOR-v4.0.0\AG-MONITOR.exe'
        Repo = 'lianghao02/AG-MONITOR-Smart-Video-Screening'
        Tag = 'v4.0.0'
        RequireTagMatch = $true
        ReleaseTitle = 'AG-MONITOR 智慧影像快篩系統 v4.0.0'
        ReleaseNotes = Join-Path $root '01_AG-MONITOR-Smart-Video-Screening\docs\RELEASE_NOTES_v4.0.0.md'
        ReleaseFiles = @(
            (Join-Path $root '01_AG-MONITOR-Smart-Video-Screening\dist\AG-MONITOR-Smart-Video-Screening-v4.0.0-win-x64-portable.zip'),
            (Join-Path $root '01_AG-MONITOR-Smart-Video-Screening\dist\AG-MONITOR-Smart-Video-Screening-v4.0.0-win-x64-portable.zip.sha256')
        )
    },
    [PSCustomObject]@{
        Name = '03_Police-Image-Toolkit'
        BuildScript = Join-Path $root '03_Police-Image-Toolkit\scripts\build.ps1'
        BuildArguments = @()
        SourceExe = Join-Path $root '03_Police-Image-Toolkit\dist\PoliceImageToolkit.exe'
        Repo = 'lianghao02/Police-Image-Toolkit'
        Tag = $policeImageToolkitVersion
        ReleaseFiles = @(
            (Join-Path $root '03_Police-Image-Toolkit\dist\PoliceImageToolkit.exe'),
            (Join-Path $root "03_Police-Image-Toolkit\dist\PoliceImageToolkit-$policeImageToolkitVersion-win-x64.zip")
        )
    },
    [PSCustomObject]@{
        Name = '06_System-Optimizer-Tool'
        BuildScript = Join-Path $root '06_System-Optimizer-Tool\dotnet-src\build_release.ps1'
        BuildArguments = @()
        SourceExe = Join-Path $root '06_System-Optimizer-Tool\dotnet-src\publish\standalone\SystemOptimizer.App.exe'
        Repo = 'lianghao02/System-Optimizer-Tool'
        Tag = $systemOptimizerVersion
        ReleaseFiles = @(
            (Join-Path $root "06_System-Optimizer-Tool\dotnet-src\publish\SystemOptimizer-$systemOptimizerVersion-Standalone-x64.exe"),
            (Join-Path $root "06_System-Optimizer-Tool\dotnet-src\publish\SystemOptimizer-$systemOptimizerVersion-Slim-x64.exe")
        )
    },
    [PSCustomObject]@{
        Name = '09_PaperSwitch'
        BuildScript = Join-Path $root '09_PaperSwitch\dotnet-src\scripts\build.ps1'
        BuildArguments = @('-SelfContained')
        SourceExe = Join-Path $root '09_PaperSwitch\dist\publish\PaperSwitch.exe'
        Repo = 'lianghao02/PaperSwitch'
        Tag = $paperSwitchVersion
        ReleaseFiles = @(
            (Join-Path $root "09_PaperSwitch\dist\release_assets\PaperSwitch-$paperSwitchVersion-Standalone.exe"),
            (Join-Path $root "09_PaperSwitch\dist\release_assets\PaperSwitch-$paperSwitchVersion-FrameworkDependent.zip")
        )
    },
    [PSCustomObject]@{
        Name = '04_Photo-Report-Generator'
        BuildScript = Join-Path $root '04_Photo-Report-Generator\scripts\build-portable.ps1'
        BuildArguments = @()
        SourceExe = Join-Path $root '04_Photo-Report-Generator\src-tauri\target\x86_64-pc-windows-gnu\release\photo-report-generator.exe'
        Repo = 'lianghao02/Photo-Report-Generator'
        Tag = $photoReportVersion
        ReleaseFiles = @(
            (Join-Path $root "04_Photo-Report-Generator\src-tauri\target\x86_64-pc-windows-gnu\release\bundle\nsis\Photo-Report-Generator-$photoReportVersion-Setup.exe"),
            (Join-Path $root "04_Photo-Report-Generator\src-tauri\target\x86_64-pc-windows-gnu\release\bundle\nsis\Photo-Report-Generator-$photoReportVersion-Portable.zip")
        )
    },
    [PSCustomObject]@{
        Name = '07_auto-learning-bot'
        DisplayName = '行政效能領航員'
        BuildScript = Join-Path $root '07_auto-learning-bot\scripts\build_portable_release.py'
        BuildArguments = @()
        SourceExe = Join-Path $root '07_auto-learning-bot\dist\行政效能領航員_V3.1.1_Portable\current\runtime\pythonw.exe'
        Arguments = '-B "ui.py"'
        WorkingDirectory = Join-Path $root '07_auto-learning-bot\dist\行政效能領航員_V3.1.1_Portable\current'
        IconLocation = Join-Path $root '07_auto-learning-bot\dist\行政效能領航員_V3.1.1_Portable\current\icons\app.ico,0'
        Repo = 'lianghao02/auto-learning-bot'
        Tag = 'V3.1.1'
        ReleaseFiles = @(
            (Join-Path $root '07_auto-learning-bot\dist\AdminEfficiencyPilot_V3.1.1_Portable.zip'),
            (Join-Path $root '07_auto-learning-bot\dist\AdminEfficiencyPilot_V3.1.1_Portable.zip.sha256')
        )
    }
)

Write-Host '=================================================================' -ForegroundColor Cyan
Write-Host '🖥️ 【Windows 桌面應用程式集中建置】' -ForegroundColor Yellow
Write-Host "📂 開發根目錄：$root" -ForegroundColor Gray
Write-Host "📌 發行模式：  $($projects.Count) 個專案各自輸出桌面免安裝／可攜式應用程式" -ForegroundColor Gray
if (Test-Path -LiteralPath $localDotnetExe) {
    Write-Host "🔧 .NET SDK：     $localDotnetExe" -ForegroundColor Gray
} else {
    Write-Host '⚠️  .NET SDK：未在使用者本機目錄找到，使用系統預設 dotnet。' -ForegroundColor Yellow
}
Write-Host "🟦 PowerShell：   $projectPowerShell" -ForegroundColor Gray
Write-Host '=================================================================' -ForegroundColor Cyan

foreach ($project in $projects) {
    $status = if (Test-Path -LiteralPath $project.BuildScript) { '就緒' } else { '缺少發布腳本' }
    Write-Host "  - $($project.Name)：$status"
}

if (-not $Execute) {
    Write-Host ''
    Write-Host '💡 目前為預覽模式，未建置任何專案。' -ForegroundColor Yellow
    Write-Host '實際建置請執行：' -ForegroundColor Yellow
    Write-Host '  .\build_all_desktop_apps.ps1 -Execute  （執行時選擇專案）' -ForegroundColor White
    return
}

$selectedProjects = @()
if ($Force) {
    $selectedProjects = $projects
    Write-Host '已使用 -Force，將直接建置全部專案。' -ForegroundColor Yellow
} else {
    Write-Host ''
    Write-Host '請選擇要建置的專案：' -ForegroundColor Cyan
    for ($index = 0; $index -lt $projects.Count; $index++) {
        Write-Host "  $($index + 1). $($projects[$index].Name)"
    }
        Write-Host "  A. 全部專案（預設輸入 A 或 1-$($projects.Count)）"
    Write-Host '  0. 取消'

    $selection = (Read-Host '請輸入選項').Trim()
    if ($selection -eq '0') {
        Write-Host '已取消，未開始建置。' -ForegroundColor Yellow
        return
    }
    if ($selection -match '^(?i)a(ll)?$' -or [string]::IsNullOrWhiteSpace($selection)) {
        $selectedProjects = $projects
    } elseif ($selection -match '^[1-9]\d*$' -and [int]$selection -le $projects.Count) {
        $selectedProjects = @($projects[[int]$selection - 1])
    } else {
        Write-Host '選項無效，未開始建置。' -ForegroundColor Red
        return
    }

    Write-Host "已選擇：$($selectedProjects.Name -join '、')" -ForegroundColor Green
}

$missingScripts = @($selectedProjects | Where-Object { -not (Test-Path -LiteralPath $_.BuildScript) })
if ($missingScripts.Count -gt 0) {
    $names = $missingScripts.Name -join '、'
    throw "缺少發布腳本，已取消：$names"
}

$results = [System.Collections.Generic.List[object]]::new()
$successfulProjects = [System.Collections.Generic.List[object]]::new()

foreach ($project in $selectedProjects) {
    Write-Host ''
    Write-Host "=================================================================" -ForegroundColor Gray
    Write-Host "🚀 正在建置：$($project.Name)" -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Gray

    try {
        $pScript = $project.BuildScript
        $pDir = Split-Path -Parent (Split-Path -Parent $pScript)
        
        if ($pScript.EndsWith('.py', [System.StringComparison]::OrdinalIgnoreCase)) {
            Push-Location (Join-Path $root $project.Name)
            try {
                $projectPython = Join-Path (Join-Path $root $project.Name) 'python_embed\python.exe'
                $pythonCommand = if (Test-Path -LiteralPath $projectPython) { $projectPython } else { 'python.exe' }
                & $pythonCommand $pScript @($project.BuildArguments)
            } finally {
                Pop-Location
            }
        } else {
            $scriptToRun = $pScript
            $temporaryUtf8Script = $null
            try {
                if ($usingWindowsPowerShell) {
                    $scriptBytes = [IO.File]::ReadAllBytes($pScript)
                    $hasUtf8Bom = $scriptBytes.Length -ge 3 -and
                        $scriptBytes[0] -eq 0xEF -and
                        $scriptBytes[1] -eq 0xBB -and
                        $scriptBytes[2] -eq 0xBF
                    if (-not $hasUtf8Bom) {
                        $temporaryUtf8Script = Join-Path (
                            Split-Path -Parent $pScript
                        ) ".central-build-$([Guid]::NewGuid().ToString('N')).ps1"
                        $sourceText = [IO.File]::ReadAllText(
                            $pScript,
                            [Text.UTF8Encoding]::new($false)
                        )
                        [IO.File]::WriteAllText(
                            $temporaryUtf8Script,
                            $sourceText,
                            [Text.UTF8Encoding]::new($true)
                        )
                        $scriptToRun = $temporaryUtf8Script
                    }
                }
                & $projectPowerShell -NoProfile -ExecutionPolicy Bypass -File $scriptToRun @($project.BuildArguments)
            } finally {
                if ($temporaryUtf8Script -and (Test-Path -LiteralPath $temporaryUtf8Script)) {
                    Remove-Item -LiteralPath $temporaryUtf8Script -Force
                }
            }
        }

        $exitCode = $LASTEXITCODE
        if ($null -eq $exitCode) { $exitCode = 0 }
        if ($exitCode -ne 0) {
            throw "建置腳本結束代碼為 $exitCode"
        }
        
        # 尋找輸出成品
        $exePath = $project.SourceExe
        if (-not (Test-Path -LiteralPath $exePath)) {
            $pRoot = Join-Path $root $project.Name
            $foundExe = Get-ChildItem -Path $pRoot -Filter "*.exe" -Recurse -File | Where-Object { $_.FullName -notmatch '\\(obj|bin|build)\\' } | Select-Object -First 1
            if ($foundExe) {
                $exePath = $foundExe.FullName
            } else {
                # 若為純 ZIP 發布包
                $foundZip = Get-ChildItem -Path (Join-Path $pRoot 'dist') -Filter "*.zip" -File | Select-Object -First 1
                if ($foundZip) {
                    $exePath = $foundZip.FullName
                } else {
                    throw "建置後找不到預期發行成品：$($project.SourceExe)"
                }
            }
        }

        # 針對 09 PaperSwitch 補充複製產出 Standalone EXE
        if ($project.Name -eq '09_PaperSwitch') {
            $saTarget = Join-Path $root "09_PaperSwitch\dist\release_assets\PaperSwitch-$($project.Tag)-Standalone.exe"
            New-Item -ItemType Directory -Path (Split-Path $saTarget) -Force | Out-Null
            if ($exePath -ne $saTarget -and (Test-Path -LiteralPath $exePath)) {
                Copy-Item -LiteralPath $exePath -Destination $saTarget -Force
            }
        }

        # 針對 06 補充複製 Standalone 與 Slim 命名檔案
        if ($project.Name -eq '06_System-Optimizer-Tool') {
            $pubDir = Join-Path $root '06_System-Optimizer-Tool\dotnet-src\publish'
            $saSrc = Join-Path $pubDir 'standalone\SystemOptimizer.App.exe'
            $slimSrc = Join-Path $pubDir 'slim\SystemOptimizer.App.exe'
            $saDest = Join-Path $pubDir "SystemOptimizer-$($project.Tag)-Standalone-x64.exe"
            $slimDest = Join-Path $pubDir "SystemOptimizer-$($project.Tag)-Slim-x64.exe"
            if ((Test-Path -LiteralPath $saSrc) -and ($saSrc -ne $saDest)) { Copy-Item -LiteralPath $saSrc -Destination $saDest -Force }
            if ((Test-Path -LiteralPath $slimSrc) -and ($slimSrc -ne $slimDest)) { Copy-Item -LiteralPath $slimSrc -Destination $slimDest -Force }
        }

        # 針對 04 補充命名標準 NSIS EXE 與 Portable ZIP
        if ($project.Name -eq '04_Photo-Report-Generator') {
            $nsisDir = Join-Path $root '04_Photo-Report-Generator\src-tauri\target\x86_64-pc-windows-gnu\release\bundle\nsis'
            $destSetup = Join-Path $nsisDir "Photo-Report-Generator-$($project.Tag)-Setup.exe"
            $destZip = Join-Path $nsisDir "Photo-Report-Generator-$($project.Tag)-Portable.zip"
            $rawSetup = Get-ChildItem -Path $nsisDir -Filter "*setup.exe" | Where-Object { $_.FullName -ne $destSetup } | Select-Object -First 1
            $rawZip = Get-ChildItem -Path $nsisDir -Filter "*.zip" | Where-Object { $_.FullName -ne $destZip } | Select-Object -First 1
            if ($rawSetup) { Copy-Item -LiteralPath $rawSetup.FullName -Destination $destSetup -Force }
            if ($rawZip) { Copy-Item -LiteralPath $rawZip.FullName -Destination $destZip -Force }
        }

        $sizeMb = [math]::Round((Get-Item -LiteralPath $exePath).Length / 1MB, 2)
        $results.Add([PSCustomObject]@{ Project = $project.Name; Result = '成功'; Detail = "$exePath ($sizeMb MB)" })
        $successfulProjects.Add($project)
        Write-Host "✅ 建置完成：$exePath ($sizeMb MB)" -ForegroundColor Green
    } catch {
        $results.Add([PSCustomObject]@{ Project = $project.Name; Result = '失敗'; Detail = $_.Exception.Message })
        Write-Host "❌ $($project.Name) 建置失敗：$($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ''
Write-Host '=================================================================' -ForegroundColor Cyan
Write-Host '📋 桌面應用程式集中建置結果' -ForegroundColor Yellow
Write-Host '=================================================================' -ForegroundColor Cyan
$results | Format-Table -AutoSize

$failed = @($results | Where-Object { $_.Result -eq '失敗' })
if ($failed.Count -gt 0) {
    Write-Host "❌ 完成但有 $($failed.Count) 個專案建置失敗。" -ForegroundColor Red
    exit 1
} else {
    Write-Host "🎉 已選桌面專案全數建置成功！" -ForegroundColor Green
}

# =================================================================
# 🌐 GitHub Releases A+B 雙軌融合發布系統
# =================================================================
if ($successfulProjects.Count -gt 0) {
    Write-Host ''
    Write-Host '=================================================================' -ForegroundColor Cyan
    Write-Host '🌐 【GitHub Releases 發布通道選擇 (A+B 雙軌架構)】' -ForegroundColor Yellow
    Write-Host '請選擇發布通道：' -ForegroundColor Cyan
    Write-Host '  [1] 🚀 正式發布 (Stable - 嚴格匹配版本 Tag，保護正式發布版)'
    Write-Host '  [2] 🧪 測試預覽發布 (Pre-release - 覆蓋更新至測試通道，供同仁下載)'
    Write-Host '  [3] 💻 僅保留本機發行檔案（預設，按 Enter 亦可）'
    Write-Host '=================================================================' -ForegroundColor Cyan

    $relChoice = (Read-Host '請輸入選項 (1, 2 或 3)').Trim()
    
    if ($relChoice -eq '1') {
        Write-Host ''
        Write-Host '🚀 [軌道 A] 正在執行正式發布 (Stable Release)...' -ForegroundColor Cyan
        
        foreach ($p in $successfulProjects) {
            $existingFiles = @($p.ReleaseFiles | Where-Object { Test-Path -LiteralPath $_ })
            if ($existingFiles.Count -eq 0) {
                Write-Host "⚠️  $($p.Name)：找不到可發布的檔案，略過。" -ForegroundColor Yellow
                continue
            }

            # 軌道 A 嚴格 Tag 匹配防護
            $repoPath = Join-Path $root $p.Name
            $tagCommit = & git -c "safe.directory=$repoPath" -C $repoPath rev-list -n 1 $p.Tag 2>$null
            $headCommit = & git -c "safe.directory=$repoPath" -C $repoPath rev-parse HEAD 2>$null
            if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($tagCommit) -or $tagCommit -ne $headCommit) {
                Write-Host "⚠️  $($p.Name)：目前 HEAD 與 $($p.Tag) 不一致，為保護既有正式 Release，已安全略過。" -ForegroundColor Yellow
                Write-Host "    💡 提示：若要發布正式版請先建立新版本與 Tag；若僅供測試請使用選項 [2] 測試預覽通道。" -ForegroundColor Gray
                continue
            }
            
            Write-Host "⏳ 正在處理 $($p.Name) -> 正式發布 $($p.Tag)..." -ForegroundColor Yellow
            try {
                $null = & gh release view $p.Tag --repo $p.Repo 2>$null
                $releaseExists = ($LASTEXITCODE -eq 0)
                if ($releaseExists) {
                    & gh release upload $p.Tag $existingFiles --clobber --repo $p.Repo
                } else {
                    $releaseTitle = if ($p.PSObject.Properties.Name -contains 'ReleaseTitle') { $p.ReleaseTitle } else { "$($p.Name) $($p.Tag)" }
                    $releaseArgs = @('release', 'create', $p.Tag) + $existingFiles + @('--verify-tag', '--latest', '--title', $releaseTitle, '--repo', $p.Repo)
                    if (($p.PSObject.Properties.Name -contains 'ReleaseNotes') -and (Test-Path -LiteralPath $p.ReleaseNotes)) {
                        $releaseArgs += @('--notes-file', $p.ReleaseNotes)
                    } else {
                        $releaseArgs += @('--generate-notes')
                    }
                    & gh @releaseArgs
                }
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✅ $($p.Name) 正式版發行檔案已成功發布 ($($p.Tag))！" -ForegroundColor Green
                } else {
                    Write-Host "❌ $($p.Name) 正式發布失敗 (ExitCode: $LASTEXITCODE)。" -ForegroundColor Red
                }
            } catch {
                Write-Host "❌ $($p.Name) 上傳異常：$($_.Exception.Message)" -ForegroundColor Red
            }
        }
        Write-Host ''
        Write-Host '🎉 正式發布流程已執行完畢！' -ForegroundColor Green

    } elseif ($relChoice -eq '2') {
        Write-Host ''
        Write-Host '🧪 [軌道 B] 正在發布至測試預覽通道 (Pre-release)...' -ForegroundColor Cyan
        
        $preReleaseTag = 'pre-release'
        foreach ($p in $successfulProjects) {
            $existingFiles = @($p.ReleaseFiles | Where-Object { Test-Path -LiteralPath $_ })
            if ($existingFiles.Count -eq 0) {
                Write-Host "⚠️  $($p.Name)：找不到可發布的檔案，略過。" -ForegroundColor Yellow
                continue
            }

            Write-Host "⏳ 正在推送 $($p.Name) -> 測試預覽版 (Pre-release)..." -ForegroundColor Yellow
            try {
                $null = & gh release view $preReleaseTag --repo $p.Repo 2>$null
                $releaseExists = ($LASTEXITCODE -eq 0)
                if ($releaseExists) {
                    & gh release upload $preReleaseTag $existingFiles --clobber --repo $p.Repo
                } else {
                    $releaseTitle = "$($p.Name) 測試預覽版 (Pre-release)"
                    $releaseNotesText = "### 🧪 測試預覽版本 (Pre-release)`n`n此版本為開發中最新測試建置成品，檔案隨時會被覆蓋更新。供同仁搶先驗證新功能使用。"
                    $releaseArgs = @('release', 'create', $preReleaseTag) + $existingFiles + @('--prerelease', '--title', $releaseTitle, '--notes', $releaseNotesText, '--repo', $p.Repo)
                    & gh @releaseArgs
                }
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✅ $($p.Name) 測試預覽檔案已成功更新至 Pre-release 通道！" -ForegroundColor Green
                } else {
                    Write-Host "❌ $($p.Name) 預覽版發布失敗 (ExitCode: $LASTEXITCODE)。" -ForegroundColor Red
                }
            } catch {
                Write-Host "❌ $($p.Name) 上傳異常：$($_.Exception.Message)" -ForegroundColor Red
            }
        }
        Write-Host ''
        Write-Host '🎉 測試預覽版發布流程已執行完畢！' -ForegroundColor Green

    } else {
        Write-Host '已選擇僅保留本機發行檔案，未上傳至 GitHub Releases。' -ForegroundColor Gray
    }
}

