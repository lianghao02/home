@echo off
chcp 65001 >nul
title [2] 從 GitHub 更新所有專案
cd /d "%~dp0"
echo 正在檢查更新...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\sync_projects.ps1"
echo.
set /p CONFIRM=請輸入 YES 確認更新: 
if /I not "%CONFIRM%"=="YES" goto :end
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\sync_projects.ps1" -Execute
:end
echo.
pause
