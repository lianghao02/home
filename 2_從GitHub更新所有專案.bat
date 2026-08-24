@echo off
REM ==============================================================================
REM  00_home - [2] 從 GitHub 下載與更新專案
REM
REM  【用途說明】：
REM  1. 新電腦開工：自動 Clone 缺漏的專案至本機。
REM  2. 日常同步：拉取 (Pull) 12 個專案的最新雲端進度。
REM  3. 安全防護：若本機有未提交的修改，會主動保護跳過，不強制覆蓋。
REM ==============================================================================

title [2] 從 GitHub 下載與更新專案
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\sync_projects.ps1" -Execute

echo.
pause
