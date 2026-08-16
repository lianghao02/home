@echo off
REM ==============================================================================
REM  專案名稱：00_home - 一鍵同步 AI Agent 全域憲法與 Skills
REM  主要功能：將 configs/ 內的中央全域憲法與 8 個 Skills 部署至 Codex 與 Antigravity
REM  使用時機：修改了全域憲法 AGENTS.md 或更新了自訂 Skill 時使用
REM  部署位置：
REM    - 全域憲法：~/.codex/AGENTS.md 與 ~/.gemini/config/AGENTS.md
REM    - 自訂Skills：~/.agents/skills/ 與 ~/.gemini/config/skills/
REM  執行命令：powershell.exe 執行 sync_codex.ps1
REM ==============================================================================

title [3] 同步 AI 設定與 Skills

REM 呼叫 PowerShell 執行全域憲法與共用 Skills 的一致性雜湊檢查與正式部署
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync_codex.ps1"

REM 執行完畢後暫停，保留視窗顯示部署清單
pause
