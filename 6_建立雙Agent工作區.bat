@echo off
REM ==============================================================================
REM  00_home - [6] 建立雙 Agent 協作工作區
REM
REM  【用途說明】：
REM  為指定專案一鍵建立 *-codex 與 *-ag 獨立 Git Worktree。
REM  
REM  【何時需要建立判定標準】：
REM  ‧ 不需要 (90% 日常)：單一 Agent 開發或輪流接力，直接開原專案即可。
REM  ‧ 需要 (10% 特殊)：雙 Agent 同時在線開工或破壞性大實驗，避免暫存踩踏。
REM ==============================================================================

title [6] 建立雙 Agent 協作工作區
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\interactive_worktree.ps1"

echo.
pause
