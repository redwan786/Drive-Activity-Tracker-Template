@echo off
REM Double-click: wipe the change-log for a fresh start
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Unblock-File -LiteralPath '%~dp0RESET_CHANGES.ps1' -ErrorAction SilentlyContinue; & '%~dp0RESET_CHANGES.ps1'"
if %ERRORLEVEL% neq 0 (
    echo.
    echo   Something went wrong. Check the output above.
    pause
)
