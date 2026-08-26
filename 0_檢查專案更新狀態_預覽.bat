@echo off
chcp 65001 >nul
title [0] 檢查專案更新狀態 (唯讀預覽)
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\push_projects.ps1"
echo.
pause
