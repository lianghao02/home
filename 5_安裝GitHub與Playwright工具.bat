@echo off
REM ==============================================================================
REM  00_home - [5] 安裝 GitHub 與 Playwright 工具
REM
REM  【用途說明】：
REM  新電腦環境初始化專用。自動檢查並安裝 Git for Windows、
REM  GitHub CLI (gh) 以及 Web 自動化測試所需的 Playwright 與 Chromium 核心。
REM ==============================================================================

title [5] 安裝 GitHub 與 Playwright 工具
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup_developer_tools.ps1" -Execute

echo.
pause
