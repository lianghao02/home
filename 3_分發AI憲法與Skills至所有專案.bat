@echo off
chcp 65001 >nul
title [3] 分發 AI 憲法與 Skills 至所有專案
cd /d "%~dp0"
echo 正在預覽 AI 憲法與 Skills 本機分發範圍...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\sync_codex.ps1"
echo.
echo =================================================================
echo 請選擇操作：
echo   [1] 確認分發 AI 憲法與 Skills 至本機所有專案
echo   [2] 取消操作（或直接按 Enter）
echo =================================================================
set /p CONFIRM=請輸入選項 (1 或 2): 
if "%CONFIRM%"=="1" goto :run
if /I "%CONFIRM%"=="YES" goto :run
if /I "%CONFIRM%"=="Y" goto :run
echo 已取消分發操作。
goto :end
:run
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\sync_codex.ps1" -Execute
:end
echo.
pause
