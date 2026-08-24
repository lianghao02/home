@echo off
REM ==============================================================================
REM  00_home - [3] 同步全域 AI 憲法與 Skills
REM
REM  【用途說明】：
REM  將 configs/ 的「全域開發憲法 v8.0」與「10 個核心 Skills」
REM  依分流清單自動部署至本機系統 (%USERPROFILE%\.codex 與 \.gemini)。
REM  只有在修改母庫規範或新電腦環境設定時才需要執行。
REM ==============================================================================

title [3] 同步全域 AI 憲法與 Skills
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\sync_codex.ps1"

echo.
pause
