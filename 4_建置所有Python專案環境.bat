@echo off
REM ==============================================================================
REM  專案名稱：00_home - 一鍵批次建置所有 Python 專案之自癒環境
REM  主要功能：自動檢查並依序為 01, 06, 07, 09, 10 建置獨立可攜版 Python 核心與套件
REM  使用時機：在新電腦首次建置環境，或想一次鋪好所有 Python 專案時使用
REM  執行命令：powershell.exe 執行 setup_all_envs.ps1
REM ==============================================================================

title [4] 一鍵建置所有 Python 專案環境
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup_all_envs.ps1"

echo.
pause
