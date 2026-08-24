@echo off
REM ==============================================================================
REM  00_home - [0] 檢查專案更新狀態 (安全預覽)
REM
REM  【用途說明】：
REM  唯讀掃描 12 個 GitHub 專案的本機修改、未追蹤檔案與遠端差異。
REM  本腳本「只讀不寫」，不會修改任何程式碼或歷史，可隨時安心執行。
REM ==============================================================================

title [0] 檢查專案更新狀態 (安全預覽)
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\push_projects.ps1"

echo.
pause
