# RESET CHANGES.md - fresh start
# Double-click / Run with PowerShell

# Location-aware: in a "tracker" subfolder -> track PARENT; else track own folder
$scriptDir  = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
if ((Split-Path $scriptDir -Leaf) -ieq 'tracker') {
    $root       = Split-Path $scriptDir -Parent
    $changesLog = "$scriptDir\CHANGES.md"
} else {
    $root       = $scriptDir
    $changesLog = "$root\CHANGES.md"
}
$snapId     = ($root -replace '[^a-zA-Z0-9]', '_')
$snapFile   = "$env:TEMP\drivetrack_$snapId.txt"
$date       = Get-Date -Format "yyyy-MM-dd HH:mm"

Write-Host ""
Write-Host "  This will WIPE CHANGES.md and start fresh." -ForegroundColor Yellow
$confirm = Read-Host "  Type 'yes' to continue"
if ($confirm -ne "yes") {
    Write-Host "  Cancelled." -ForegroundColor Red
    Start-Sleep -Seconds 1
    return
}

$emScroll = [char]::ConvertFromUtf32(0x1F4DC)

# Fresh empty CHANGES.md (header + empty entries marker)
$fresh = @"
<div align="center">

# $emScroll Change Log

### Google Drive/Drive/Folder - Activity Tracker

![Auto](https://img.shields.io/badge/AUTO--GENERATED-2188ff?style=for-the-badge) &nbsp; ![Live](https://img.shields.io/badge/LIVE_TRACKING-2ea44f?style=for-the-badge)

</div>

> Every file or folder added/rename/move/deleted is recorded below - **newest first**.

> Log reset on ``$date`` - tracking restarts from here.

---

<!--ENTRIES-->
"@

Set-Content -LiteralPath $changesLog -Value $fresh -Encoding UTF8
Write-Host "  CHANGES.md reset." -ForegroundColor Green

# Reset snapshot so next run treats current state as the new baseline
if (Test-Path -LiteralPath $snapFile) {
    Remove-Item -LiteralPath $snapFile -Force
    Write-Host "  Snapshot cleared (next UPDATE will set new baseline)." -ForegroundColor Green
}

# Push the reset to GitHub
Set-Location -LiteralPath $root
git add -A
git commit -m "CHANGES.md reset: $date"
git push
Write-Host ""
Write-Host "  Done! Fresh start pushed." -ForegroundColor Magenta
Start-Sleep -Seconds 2
