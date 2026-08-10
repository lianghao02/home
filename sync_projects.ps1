# ============================================================
# 全域專案雙向同步、Agent 設定還原與廢棄清理腳本
# (Global Sync, Config Restoration & Cleanup Script)
# ============================================================

$rootDir = "C:\Users\chia-hao\Documents\GitHub"
$globalConfigDir = "C:\Users\chia-hao\.gemini\config"
$homeConfigsDir = Join-Path $rootDir "home\configs"

Write-Host "=========================================="
Write-Host "⚙️ 正在同步 Antigravity 全域憲法與 Agent Skills 設定..."
Write-Host "=========================================="

# 1. 自動複製 home/configs/AGENTS.md 到 .gemini/config/AGENTS.md
if (Test-Path (Join-Path $homeConfigsDir "AGENTS.md")) {
    if (-not (Test-Path $globalConfigDir)) { 
        New-Item -ItemType Directory -Path $globalConfigDir -Force | Out-Null 
    }
    Copy-Item -Path (Join-Path $homeConfigsDir "AGENTS.md") -Destination (Join-Path $globalConfigDir "AGENTS.md") -Force
    Write-Host "✅ 已同步全域憲法 v7.1 AGENTS.md 至 $globalConfigDir"
}

# 2. 自動複製 home/configs/skills/ 到 .gemini/config/skills/
if (Test-Path (Join-Path $homeConfigsDir "skills")) {
    $targetSkillsDir = Join-Path $globalConfigDir "skills"
    if (-not (Test-Path $targetSkillsDir)) { 
        New-Item -ItemType Directory -Path $targetSkillsDir -Force | Out-Null 
    }
    Copy-Item -Path (Join-Path $homeConfigsDir "skills\*") -Destination $targetSkillsDir -Recurse -Force
    Write-Host "✅ 已同步 5 大 Agent Skills 至 $targetSkillsDir"
}

Write-Host "`n=========================================="
Write-Host "🔍 正在查詢 GitHub (lianghao02) 當前活躍專案清單..."
Write-Host "=========================================="

# 3. 取得 GitHub 上當前活躍的專案 Repo 清單
$githubUser = "lianghao02"
$activeRepoNames = $null

try {
    $headers = @{ "Accept" = "application/vnd.github+json" }
    $repos = Invoke-RestMethod -Uri "https://api.github.com/users/$githubUser/repos?per_page=100" -Headers $headers
    $activeRepoNames = $repos.name
    Write-Host "✅ 找到 GitHub 雲端共 $($activeRepoNames.Count) 個專案"
} catch {
    Write-Host "⚠️ 無法取得 GitHub 專案清單，將僅進行本地 Git 同步"
}

# 4. 本地資料夾掃描與清理
$localDirs = Get-ChildItem -Path $rootDir -Directory

foreach ($dir in $localDirs) {
    $dirName = $dir.Name
    
    # 如果 GitHub 上的 Repo 已被刪除，自動清理本地資料夾
    if ($activeRepoNames -and ($dirName -notin $activeRepoNames)) {
        Write-Host "🗑️ 發現已在 GitHub 廢棄刪除之專案：$dirName → 正在自動清理本機資料夾..."
        Remove-Item -Path $dir.FullName -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "✅ 已清除本機廢棄專案：$dirName"
        continue
    }

    # 正常專案進行 Git 拉取同步
    $gitPath = Join-Path $dir.FullName ".git"
    if (Test-Path $gitPath) {
        Write-Host "------------------------------------------"
        Write-Host "🔄 正在同步專案：$dirName"
        Set-Location $dir.FullName
        git pull --ff-only 2>&1
    }
}

Set-Location $rootDir
Write-Host "`n=========================================="
Write-Host "🎉 全域憲法、Agent Skills、專案同步與廢棄清理全數完成！"
Write-Host "=========================================="
