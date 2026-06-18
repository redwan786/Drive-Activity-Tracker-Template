@echo off
REM Double-click: first-time setup (creates repo, pushes)
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Unblock-File -LiteralPath '%~dp0INITIAL.ps1' -ErrorAction SilentlyContinue; & '%~dp0INITIAL.ps1'"
echo.
pause
