@echo off
REM ==============================================================================
REM  00_home - 一鍵同步 AI Agent 憲法與 Skills
REM  將 configs/ 憲法與 Skills 分流同步至 Codex 與 Antigravity
REM ==============================================================================

title [3] 同步 AI Agent 憲法與 Skills
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\sync_codex.ps1"

echo.
pause
