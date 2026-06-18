@echo off
REM Double-click: refresh README + CHANGES and push to GitHub
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Unblock-File -LiteralPath '%~dp0UPDATE_CHANGES.ps1' -ErrorAction SilentlyContinue; & '%~dp0UPDATE_CHANGES.ps1'"
if %ERRORLEVEL% neq 0 (
    echo.
    echo   Something went wrong. Check the output above.
    pause
)
