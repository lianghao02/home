@echo off
chcp 65001 >nul
title [1] 推送所有專案至 GitHub
cd /d "%~dp0"
echo 正在讀取預覽變更...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\push_projects.ps1"
echo.
set /p CONFIRM=請輸入 YES 確認推送所有專案: 
if /I not "%CONFIRM%"=="YES" goto :end
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\push_projects.ps1" -Execute -ConfirmEach
:end
echo.
pause
