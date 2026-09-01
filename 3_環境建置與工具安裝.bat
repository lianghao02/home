@echo off
chcp 65001 >nul
title [3] 環境建置與工具安裝
cd /d "%~dp0"
set "PS_HOST=pwsh.exe"
where.exe pwsh.exe >nul 2>&1
if errorlevel 1 set "PS_HOST=powershell.exe"
"%PS_HOST%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup_environment_hub.ps1"
echo.
pause
