@echo off
title [1]  GitHub
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0push_projects.ps1" -Execute
pause
