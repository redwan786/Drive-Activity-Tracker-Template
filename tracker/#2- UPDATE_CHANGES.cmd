@echo off
REM Double-click: refresh README + CHANGES and push to GitHub
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Unblock-File -LiteralPath '%~dp0UPDATE_CHANGES.ps1' -ErrorAction SilentlyContinue; & '%~dp0UPDATE_CHANGES.ps1'"
echo.
pause
