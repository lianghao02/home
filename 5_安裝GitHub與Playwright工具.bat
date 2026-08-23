@echo off
chcp 65001 >nul
REM ==============================================================================
REM  00_home - 安裝 Git、GitHub CLI 與 Playwright/Chromium
REM  僅供新電腦首次設定；已安裝的工具會自動略過。
REM ==============================================================================

title [5] 安裝 GitHub 與 Playwright 工具
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup_developer_tools.ps1" -Execute

echo.
pause
