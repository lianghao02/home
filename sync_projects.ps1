# ============================================================
# ?¨å?å°ˆæ??™å??Œæ­¥?Agent è¨­å??„å??‡å»¢æ£„æ??†è…³??# (Global Sync, Config Restoration & Cleanup Script)
# ============================================================

$rootDir = Split-Path -Parent $PSScriptRoot
$globalConfigDir = "C:\Users\chia-hao\.gemini\config"
$homeConfigsDir = Join-Path $PSScriptRoot "configs"

Write-Host "=========================================="
Write-Host "?™ï? æ­?œ¨?Œæ­¥ Antigravity ?¨å??²æ???Agent Skills è¨­å?..."
Write-Host "=========================================="

# 1. ?ªå?è¤‡è£½ home/configs/AGENTS.md ??.gemini/config/AGENTS.md
if (Test-Path (Join-Path $homeConfigsDir "AGENTS.md")) {
    if (-not (Test-Path $globalConfigDir)) { 
        New-Item -ItemType Directory -Path $globalConfigDir -Force | Out-Null 
    }
    Copy-Item -Path (Join-Path $homeConfigsDir "AGENTS.md") -Destination (Join-Path $globalConfigDir "AGENTS.md") -Force
    Write-Host "??å·²å?æ­¥å…¨?Ÿæ†²æ³?v7.1 AGENTS.md ??$globalConfigDir"
}

# 2. ?ªå?è¤‡è£½ home/configs/skills/ ??.gemini/config/skills/
if (Test-Path (Join-Path $homeConfigsDir "skills")) {
    $targetSkillsDir = Join-Path $globalConfigDir "skills"
    if (-not (Test-Path $targetSkillsDir)) { 
        New-Item -ItemType Directory -Path $targetSkillsDir -Force | Out-Null 
    }
    Copy-Item -Path (Join-Path $homeConfigsDir "skills\*") -Destination $targetSkillsDir -Recurse -Force
    Write-Host "??å·²å?æ­?5 å¤?Agent Skills ??$targetSkillsDir"
}

Write-Host "`n=========================================="
Write-Host "?? æ­?œ¨?¥è©¢ GitHub (lianghao02) ?¶å?æ´»è?å°ˆæ?æ¸…å–®..."
Write-Host "=========================================="

# 3. ?–å? GitHub ä¸Šç•¶?æ´»èºç?å°ˆæ? Repo æ¸…å–®
$githubUser = "lianghao02"
$activeRepoNames = $null

try {
    $headers = @{ "Accept" = "application/vnd.github+json" }
    $repos = Invoke-RestMethod -Uri "https://api.github.com/users/$githubUser/repos?per_page=100" -Headers $headers
    $activeRepoNames = $repos.name
    Write-Host "???¾åˆ° GitHub ?²ç«¯??$($activeRepoNames.Count) ?‹å?æ¡?
} catch {
    Write-Host "? ï? ?¡æ??–å? GitHub å°ˆæ?æ¸…å–®ï¼Œå??…é€²è??¬åœ° Git ?Œæ­¥"
}

# 4. ?¬åœ°è³‡æ?å¤¾æ??è?æ¸…ç?
$localDirs = Get-ChildItem -Path $rootDir -Directory

foreach ($dir in $localDirs) {
    $dirName = $dir.Name
    
    # å¦‚æ? GitHub ä¸Šç? Repo å·²è¢«?ªé™¤ï¼Œè‡ª?•æ??†æœ¬?°è??™å¤¾
    if ($activeRepoNames -and ($dirName -notin $activeRepoNames)) {
        Write-Host "??ï¸??¼ç¾å·²åœ¨ GitHub å»¢æ??ªé™¤ä¹‹å?æ¡ˆï?$dirName ??æ­?œ¨?ªå?æ¸…ç??¬æ?è³‡æ?å¤?.."
        Remove-Item -Path $dir.FullName -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "??å·²æ??¤æœ¬æ©Ÿå»¢æ£„å?æ¡ˆï?$dirName"
        continue
    }

    # æ­?¸¸å°ˆæ??²è? Git ?‰å??Œæ­¥
    $gitPath = Join-Path $dir.FullName ".git"
    if (Test-Path $gitPath) {
        Write-Host "------------------------------------------"
        Write-Host "?? æ­?œ¨?Œæ­¥å°ˆæ?ï¼?dirName"
        Set-Location $dir.FullName
        git pull --ff-only 2>&1
    }
}

Set-Location $rootDir
Write-Host "`n=========================================="
Write-Host "?? ?¨å??²æ??Agent Skills?å?æ¡ˆå?æ­¥è?å»¢æ?æ¸…ç??¨æ•¸å®Œæ?ï¼?
Write-Host "=========================================="


