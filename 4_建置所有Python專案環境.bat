@echo off
chcp 65001 >nul
REM ==============================================================================
REM  00_home - 一鍵自動建置所有 Python 專案獨立環境
REM  自動檢查並依序為 01, 06, 07, 09, 10 建置獨立可攜版 Python 核心與相依套件
REM ==============================================================================

title [4] 一鍵建置所有 Python 專案環境
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup_all_envs.ps1" %*

echo.
pause