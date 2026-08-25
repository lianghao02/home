@echo off
chcp 65001 >nul
title [3] 同步 AI 設定與 Skills
cd /d "%~dp0"
echo 正在檢查設定與 Skills 一致性...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\sync_codex.ps1" -CheckOnly
echo.
set /p CONFIRM=請輸入 YES 確認同步: 
if /I not "%CONFIRM%"=="YES" goto :end
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\sync_codex.ps1"
:end
echo.
pause
