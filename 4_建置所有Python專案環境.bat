@echo off
REM ==============================================================================
REM  00_home - [4] 建置所有 Python 專案環境
REM
REM  【用途說明】：
REM  自動為 5 個 Python 專案 (01, 06, 07, 09, 10) 部署免安裝的可攜版
REM  Python 3.13 獨立環境並自動補齊 requirements.txt 相依套件。
REM  具備自癒能力，新電腦或環境損壞時執行一次即可。
REM ==============================================================================

title [4] 建置所有 Python 專案環境
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup_all_envs.ps1" %*

echo.
pause
