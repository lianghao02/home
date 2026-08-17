@echo off
REM ==============================================================================
REM  00_home - 龄眖 GitHub 更籔穝┮Τ盡
REM  уΩ眖 GitHub ┰ 12 盡程穝秈璝ぶ玥笆 Clone 更
REM ==============================================================================

title [2] 眖 GitHub 更籔穝盡
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\sync_projects.ps1" -Execute

echo.
pause
