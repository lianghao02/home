@echo off
REM ==============================================================================
REM  專案名稱：00_home - 一鍵批次推送專案至 GitHub
REM  主要功能：自動檢查 12 個專案，將有修改的專案自動 Commit 並 Push 到 GitHub
REM  使用時機：日常開發完成、需要將所有本機進度安全備份推送到雲端時使用
REM  安全防護：具備無更新自動略過機制，無未提交變更的專案不會重複推送
REM  執行命令：powershell.exe 執行 push_projects.ps1 -Execute
REM ==============================================================================

title [1] 批次推送專案至 GitHub

REM 以正式執行參數 (-Execute) 呼叫 PowerShell 執行批次 Commit 與 Push
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0push_projects.ps1" -Execute

REM 執行完畢後暫停，保留視窗顯示推送統計結果
pause
