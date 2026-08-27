@echo off
chcp 65001 >nul
title [1] 推送所有專案至 GitHub
cd /d "%~dp0"
echo 正在讀取預覽變更...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\push_projects.ps1"
echo.
echo =================================================================
echo 請選擇操作：
echo   [1] 確認推送所有專案至 GitHub
echo   [2] 取消操作（或直接按 Enter）
echo =================================================================
set /p CONFIRM=請輸入選項 (1 或 2): 
if "%CONFIRM%"=="1" goto :run
if /I "%CONFIRM%"=="YES" goto :run
if /I "%CONFIRM%"=="Y" goto :run
echo 已取消推送操作。
goto :end
:run
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\push_projects.ps1" -Execute
:end
echo.
pause
