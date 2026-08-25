@echo off
chcp 65001 >nul
title [5] 安裝開發者工具與 Playwright
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup_developer_tools.ps1" -Execute
echo.
pause
