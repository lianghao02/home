# ============================================================
# 全域專案雙向同步與自動清理腳本 (Global Sync & Cleanup Script)
# ============================================================

$rootDir = "C:\Users\chia-hao\Documents\GitHub"

# 1. 取得 GitHub 上當前活躍的專案 Repo 清單
$githubUser = "lianghao02"
Write-Host "🔍 正在查詢 GitHub ($githubUser) 當前活躍專案清單..."

try {
    $repos = Invoke-RestMethod -Uri "https://api.github.com/users/$githubUser/repos?per_page=100" -Headers @{"Accept"="application/vnd.github+json"}
    $activeRepoNames = $repos.name
    Write-Host "✅ 找到 GitHub 雲端共 $($activeRepoNames.Count) 個專案"
} catch {
    Write-Host "⚠️ 無法取得 GitHub 專案清單，將僅進行本地 Git 同步"
    $activeRepoNames = $null
}

# 2. 本地資料夾掃描與清理
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
        Write-Host "=========================================="
        Write-Host "🔄 正在同步：$dirName"
        Set-Location $dir.FullName
        git pull --ff-only 2>&1
    }
}

Set-Location $rootDir
Write-Host ""
Write-Host "🎉 所有專案同步與廢棄清理完成！"
