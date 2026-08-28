@echo off
chcp 65001 >nul
title [3] 環境建置與工具安裝
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup_environment_hub.ps1"
echo.
pause
