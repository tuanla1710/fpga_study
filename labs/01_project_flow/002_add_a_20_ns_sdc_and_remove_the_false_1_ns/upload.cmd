@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp004_program_jtag.ps1"
exit /b %ERRORLEVEL%
