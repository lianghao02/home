@echo off
REM ==============================================================================
REM  00_home - 專案更新狀態檢查捷徑 (預覽模式)
REM  掃描 12 個 GitHub 專案的本機修改與未推送狀態（僅檢查，不修改檔案）
REM ==============================================================================

title [0] 檢查專案更新狀態 (預覽模式)
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\push_projects.ps1"

echo.
pause
