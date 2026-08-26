@echo off
chcp 65001 >nul
title [4] 建置所有 Python 專案可攜環境
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup_all_envs.ps1" %*
echo.
pause
