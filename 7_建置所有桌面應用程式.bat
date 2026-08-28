@echo off
chcp 65001 >nul
title [7] 建置所有桌面應用程式
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_all_desktop_apps.ps1" -Execute %*
echo.
pause
