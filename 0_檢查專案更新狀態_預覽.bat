@echo off
title [0]  ()
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0push_projects.ps1"
pause
