@echo off
REM ==============================================================================
REM  00_home - 龄˙ AI Agent 办舅猭籔 Skills
REM  盢 configs/ ずいァ办舅猭籔 Skills 场竝 Codex 籔 Antigravity
REM ==============================================================================

title [3] ˙ AI Agent 办舅猭籔 Skills
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\sync_codex.ps1"

echo.
pause
