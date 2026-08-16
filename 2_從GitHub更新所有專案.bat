@echo off
title [2]  GitHub 
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync_projects.ps1" -Execute
pause
