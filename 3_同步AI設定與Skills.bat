@echo off
chcp 65001 >nul
title [3] 同步 AI 設定與 Skills
cd /d "%~dp0"
echo 正在預覽 AI 設定與 Skills 同步範圍...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\sync_codex.ps1"
echo.
echo =================================================================
echo 請選擇操作：
echo   [1] 確認同步 AI 設定與 Skills 至所有專案
echo   [2] 取消操作（或直接按 Enter）
echo =================================================================
set /p CONFIRM=請輸入選項 (1 或 2): 
if "%CONFIRM%"=="1" goto :run
if /I "%CONFIRM%"=="YES" goto :run
if /I "%CONFIRM%"=="Y" goto :run
echo 已取消同步操作。
goto :end
:run
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\sync_codex.ps1" -Execute
:end
echo.
pause
