@echo off
REM ==============================================================================
REM  00_home - 一鍵批次推送專案至 GitHub
REM  自動檢查 12 個專案，將有修改的專案自動 Commit 並 Push 到 GitHub
REM ==============================================================================

title [1] 批次推送專案至 GitHub
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\push_projects.ps1" -Execute

echo.
pause
