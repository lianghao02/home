@echo off
REM ==============================================================================
REM  專案名稱：00_home - 專案更新狀態檢查捷徑 (預覽模式)
REM  主要功能：掃描 12 個 GitHub 專案的本機修改與未推送狀態（僅檢查，不修改檔案）
REM  使用時機：想知道目前有哪些專案改過程式碼、準備好推送時使用
REM  執行命令：powershell.exe 執行 push_projects.ps1 (預設為 Dry-Run 預覽模式)
REM ==============================================================================

title [0] 檢查專案更新狀態 (預覽模式)

REM 以繞過執行原則 (ExecutionPolicy Bypass) 呼叫 PowerShell 進行專案狀態掃描
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0push_projects.ps1"

REM 執行完畢後暫停，保留視窗讓使用者看清楚掃描結果
pause
