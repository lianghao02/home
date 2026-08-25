@echo off
chcp 65001 >nul
title [6] 建立雙 Agent 獨立工作區 (Worktree)
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\interactive_worktree.ps1"
echo.
pause
