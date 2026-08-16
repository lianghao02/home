@echo off
REM ==============================================================================
REM  專案名稱：00_home - 一鍵從 GitHub 下載與更新所有專案
REM  主要功能：批次從 GitHub 拉取 12 個專案的最新進度，若缺少則自動 Clone 下載
REM  使用時機：在新電腦首次建置環境，或在其他電腦開發後要同步最新程式碼時使用
REM  安全防護：若本機有未存檔修改會自動略過 (SKIP)，絕不強制覆寫本地程式碼
REM  執行命令：powershell.exe 執行 sync_projects.ps1 -Execute
REM ==============================================================================

title [2] 批次從 GitHub 更新所有專案

REM 以正式執行參數 (-Execute) 呼叫 PowerShell 執行批次拉取、下載與環境重建
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync_projects.ps1" -Execute

REM 執行完畢後暫停，保留視窗顯示更新統計結果
pause
