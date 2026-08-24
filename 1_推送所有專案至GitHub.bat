@echo off
REM ==============================================================================
REM  00_home - [1] 批次推送專案至 GitHub
REM
REM  【用途說明】：
REM  自動掃描 12 個專案，將有變更的專案依 Conventional Commits 格式
REM  自動完成本機 Commit 並推播 (Push) 至遠端 GitHub 雲端版本庫。
REM ==============================================================================

title [1] 批次推送專案至 GitHub
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\push_projects.ps1" -Execute

echo.
pause
