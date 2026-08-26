# UTF-8 Compatibility
param(



    [string]$DevelopmentRoot = '',



    [string]$CommitMessage = '',



    [switch]$Execute,



    [switch]$ConfirmEach



)







$ErrorActionPreference = 'Stop'



Set-StrictMode -Version Latest







$projectRoot = Split-Path -Parent $PSScriptRoot



$config = [ordered]@{



    Manifest = Join-Path $projectRoot 'development-repositories.json'



}







function Write-Status([string]$Level, [string]$Message) {



    Write-Host ('[{0}] {1}' -f $Level, $Message)



}







function Test-IsDangerousPath([string]$PathToCheck) {



    $resolved = [IO.Path]::GetFullPath($PathToCheck).TrimEnd('\', '/')



    $userProfile = [IO.Path]::GetFullPath($env:USERPROFILE).TrimEnd('\', '/')



    $desktop = [IO.Path]::GetFullPath([Environment]::GetFolderPath('Desktop')).TrimEnd('\', '/')



    $downloads = [IO.Path]::GetFullPath((Join-Path $env:USERPROFILE 'Downloads')).TrimEnd('\', '/')



    $temp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\', '/')







    if ($resolved -eq $userProfile -or $resolved -eq $desktop -or $resolved -eq $downloads -or $resolved -eq $temp) {



        return $true



    }



    if ($resolved -match '^[a-zA-Z]:$') {



        return $true



    }



    return $false



}







if (-not (Get-Command git -ErrorAction SilentlyContinue)) {



    throw '找不到 Git 工具，請先安裝 Git for Windows。'



}



if (-not (Test-Path -LiteralPath $config.Manifest -PathType Leaf)) {



    throw "找不到專案清單檔案：$($config.Manifest)"



}







if ([string]::IsNullOrWhiteSpace($DevelopmentRoot)) {



    $parent = Split-Path -Parent $projectRoot



    if ($parent -and ((Split-Path -Leaf $parent) -match '(?i)^GitHub$')) {



        $DevelopmentRoot = $parent



    } elseif (Test-Path -LiteralPath 'D:\') {



        $DevelopmentRoot = 'D:\Development\GitHub'



    } else {



        $DevelopmentRoot = 'C:\Development\GitHub'



    }



}







$root = [IO.Path]::GetFullPath($DevelopmentRoot)







if (Test-IsDangerousPath $root) {



    throw "安全防禦阻擋：指定的開發根目錄 [$root] 屬於危險或系統敏感目錄（如桌面、下載、使用者根目錄或磁碟根目錄），已強制終止以防污染！"



}







$manifest = Get-Content -LiteralPath $config.Manifest -Raw -Encoding UTF8 | ConvertFrom-Json







Write-Host '================================================================='



if ($Execute) {



    Write-Host '🚀 【執行模式】正式批次推送至 GitHub 雲端版本庫'



} else {



    Write-Host '🔍 【預覽模式】僅掃描專案更新狀態（尚未推送至 GitHub）'



}



Write-Host "📁 【工作目錄】$root"



Write-Host '================================================================='



Write-Host ''







$totalClean = 0



$totalUpdated = 0



$totalSkipped = 0



$repoIndex = 0



$totalRepos = $manifest.repositories.Count







foreach ($item in $manifest.repositories) {



    $repoIndex++



    $folderName = [string]$item.folder



    $target = Join-Path $root $folderName



    $safeTarget = $target.Replace('\', '/')



    $prefix = "[$repoIndex/$totalRepos] $folderName"







    if (-not (Test-Path -LiteralPath $target)) {



        Write-Host "$prefix : ⚠️  跳過（本機資料夾不存在）"



        $totalSkipped++



        continue



    }







    if (-not (Test-Path -LiteralPath (Join-Path $target '.git'))) {



        Write-Host "$prefix : ⚠️  跳過（非 Git 版本庫）"



        $totalSkipped++



        continue



    }







    # 檢查是否有未 Commit 的檔案變更



    $oldEap = $ErrorActionPreference



    $ErrorActionPreference = 'Continue'



    $changes = @()



    $statusExit = 0



    try {



        $changes = @(git -c "safe.directory=$safeTarget" -c core.safecrlf=false -C "$target" status --porcelain 2>$null)



        $statusExit = $LASTEXITCODE



    } catch {



        $statusExit = 1



    } finally {



        $ErrorActionPreference = $oldEap



    }



    if ($statusExit -ne 0) {



        Write-Host "$prefix : ⚠️  無法讀取 Git 狀態，已跳過"



        $totalSkipped++



        continue



    }







    # 檢查是否有尚未 Push 的本地 Commits



    $unpushed = @()



    $oldEap = $ErrorActionPreference



    $ErrorActionPreference = 'Continue'



    try {



        $branch = (git -c "safe.directory=$safeTarget" -c core.safecrlf=false -C "$target" rev-parse --abbrev-ref HEAD 2>$null)



        if ($branch -and $branch -ne 'HEAD') {



            $unpushed = @(git -c "safe.directory=$safeTarget" -c core.safecrlf=false -C "$target" cherry "origin/$branch" 2>$null)



        }



    } catch {



        $unpushed = @()



    } finally {



        $ErrorActionPreference = $oldEap



    }







    $hasWorkingChanges = ($changes.Count -gt 0)



    $hasUnpushedCommits = ($unpushed.Count -gt 0)







    if (-not $hasWorkingChanges -and -not $hasUnpushedCommits) {



        Write-Host "$prefix : ✨ 無任何修改，已是最新進度"



        $totalClean++



        continue



    }







    # 有變更或待推送 commit



    $statusDesc = @()



    if ($hasWorkingChanges) { $statusDesc += "$($changes.Count) 個檔案變更" }



    if ($hasUnpushedCommits) { $statusDesc += "$($unpushed.Count) 個待推送版本" }



    $descStr = $statusDesc -join '、'







    if (-not $Execute) {



        Write-Host "$prefix : 📝 偵測到更新 ($descStr) ➜ 等待推送"



        $totalUpdated++



        continue



    }







    if ($hasWorkingChanges) {



        $oldEap = $ErrorActionPreference



        $ErrorActionPreference = 'Continue'



        $diffCheckCode = 0



        try {



            $diffCheck = @(git -c "safe.directory=$safeTarget" -c core.safecrlf=false -c core.whitespace=-trailing-space,-blank-at-eol,-blank-at-eof -C "$target" diff --check 2>$null)



            $diffCheckCode = $LASTEXITCODE



        } catch {



            $diffCheckCode = 1



        } finally {



            $ErrorActionPreference = $oldEap



        }



        if ($diffCheckCode -ne 0) {



            Write-Host "$prefix : ❌ 格式檢查失敗 (git diff --check)，已略過"



            $totalSkipped++



            continue



        }



    }







    if ($ConfirmEach) {



        $confirm = Read-Host "$prefix : 確定提交並推送上述範圍嗎？(Y/N)"



        if ($confirm -notmatch '^(?i)y$') {



            Write-Host "$prefix : 已依使用者選擇略過"



            $totalSkipped++



            continue



        }



    }







    # 執行實際 Commit 與 Push



    Write-Host "$prefix : ⏳ 正在處理推送 ($descStr)..."







    if ($hasWorkingChanges) {



        $oldEap = $ErrorActionPreference



        $ErrorActionPreference = 'Continue'



        try {



            $null = git -c "safe.directory=$safeTarget" -c core.safecrlf=false -C "$target" add -A 2>$null



        } finally {



            $ErrorActionPreference = $oldEap



        }







        if ($LASTEXITCODE -ne 0) {



            Write-Host "$prefix : ❌ 暫存檔案失敗 (git add)"



            $totalSkipped++



            continue



        }







        $stagedDiff = [string](git -c "safe.directory=$safeTarget" -c core.safecrlf=false -C "$target" diff --cached --no-ext-diff 2>$null)



        $sensitivePattern = '(?im)(api[_-]?key|secret|token|password|private[_-]?key)\s*[:=]\s*["'']?[A-Za-z0-9_\-]{12,}'



        if ($stagedDiff -match $sensitivePattern) {



            $stagedFiles = @(git -c "safe.directory=$safeTarget" -c core.safecrlf=false -C "$target" diff --cached --name-only 2>$null) -join '、'



            Write-Host "$prefix : ⚠️  偵測到疑似敏感資料，已停止 Commit／Push。請檢查已暫存檔案：$stagedFiles"



            $totalSkipped++



            continue



        }







        $msg = if (-not [string]::IsNullOrWhiteSpace($CommitMessage)) {



            $CommitMessage



        } else {



            "sync: 自動同步本機專案更新 ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"



        }







        $oldEap = $ErrorActionPreference



        $ErrorActionPreference = 'Continue'



        try {



            $null = git -c "safe.directory=$safeTarget" -c core.safecrlf=false -C "$target" commit -m "$msg" 2>$null



        } finally {



            $ErrorActionPreference = $oldEap



        }







        if ($LASTEXITCODE -ne 0) {



            Write-Host "$prefix : ❌ 建立版本紀錄失敗 (git commit)"



            $totalSkipped++



            continue



        }



    }







    # 執行 git push（安全隔離 stderr，防範 PowerShell 5.1 NativeCommandError）



    $oldEap = $ErrorActionPreference



    $ErrorActionPreference = 'Continue'



    try {



        $null = git -c "safe.directory=$safeTarget" -c core.safecrlf=false -C "$target" push 2>$null



    } finally {



        $ErrorActionPreference = $oldEap



    }







    if ($LASTEXITCODE -ne 0) {



        Write-Host "$prefix : ❌ 上傳推送失敗（可能有網路問題或遠端衝突）"



        $totalSkipped++



        continue



    }







    Write-Host "$prefix : ✅ 【成功】已完成同步並推送到 GitHub 雲端"



    $totalUpdated++



}







Write-Host ''



Write-Host '================================================================='



Write-Host "📊 【掃描完成】共 $totalRepos 個專案："



Write-Host "   • ✨ $totalClean 個專案已是最新進度"



Write-Host "   • $(if ($Execute) { '✅ ' + $totalUpdated + ' 個專案已成功推送至 GitHub' } else { '📝 ' + $totalUpdated + ' 個專案有更新等待推送' })"



if ($totalSkipped -gt 0) {



    Write-Host "   • ⚠️  $totalSkipped 個專案略過或推送失敗"



}



Write-Host '================================================================='



if (-not $Execute) {



    Write-Host '💡 提示：目前為預覽模式，未對 GitHub 進行任何推送。若確認推送請雙擊【1_推送所有專案至GitHub.bat】。'



}



