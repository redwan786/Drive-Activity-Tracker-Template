@echo off
REM Double-click: first-time setup (creates repo, pushes)
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Unblock-File -LiteralPath '%~dp0INITIAL.ps1' -ErrorAction SilentlyContinue; & '%~dp0INITIAL.ps1'"
if %ERRORLEVEL% neq 0 (
    echo.
    echo   Something went wrong. Check the output above.
    pause
)
