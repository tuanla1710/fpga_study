@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp001_compile.ps1"
exit /b %ERRORLEVEL%
