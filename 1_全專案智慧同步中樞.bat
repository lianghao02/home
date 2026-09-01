@echo off
chcp 65001 >nul
title [1] 全專案智慧同步中樞
cd /d "%~dp0"
set "PS_HOST=pwsh.exe"
where.exe pwsh.exe >nul 2>&1
if errorlevel 1 set "PS_HOST=powershell.exe"
"%PS_HOST%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\workspace_sync_hub.ps1"
echo.
pause
