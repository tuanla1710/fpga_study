@echo off
setlocal
cd /d "%~dp0"

if "%~1"=="" goto usage
if /I "%~1"=="1" set "script=01_compile.ps1" & goto run
if /I "%~1"=="2" set "script=02_read_errors_and_slack.ps1" & goto run
if /I "%~1"=="3" set "script=03_find_sof.ps1" & goto run
if /I "%~1"=="4" set "script=04_program_jtag.ps1" & goto run

set "script=%~1"
goto run

:usage
echo Usage: run 1 ^| 2 ^| 3 ^| 4
echo    or: run 01_compile.ps1
exit /b 1

:run
if not exist "%~dp0%script%" (
  echo Script not found: %script%
  exit /b 1
)
powershell -ExecutionPolicy Bypass -File "%~dp0%script%"
exit /b %ERRORLEVEL%
