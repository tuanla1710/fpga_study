@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp002_read_errors_and_slack.ps1"
if errorlevel 1 exit /b %ERRORLEVEL%
powershell -ExecutionPolicy Bypass -File "%~dp003_find_sof.ps1"
exit /b %ERRORLEVEL%
