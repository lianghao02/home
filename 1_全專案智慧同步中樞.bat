@echo off
chcp 65001 >nul
title [1] 全專案智慧同步中樞
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\workspace_sync_hub.ps1"
echo.
pause
