# ============================================================
#  INITIAL.ps1  -  One-time bootstrap for a new Drive/Folder
#  Run inside the "tracker" folder (or via "#1- INITIAL.cmd").
#  Safe to re-run (idempotent).
# ============================================================

# Location-aware: scripts live in a "tracker" subfolder; the tracked
# drive/folder (where .git lives) is its PARENT.
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
if ((Split-Path $scriptDir -Leaf) -ieq 'tracker') {
    $root = Split-Path $scriptDir -Parent
} else {
    $root = $scriptDir
}
Set-Location -LiteralPath $root

$updateScript = Join-Path $scriptDir "UPDATE_CHANGES.ps1"
$folderName   = Split-Path $root -Leaf

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host "   Drive/Folder Activity Tracker - Setup" -ForegroundColor Cyan
Write-Host "   Tracking folder: $folderName" -ForegroundColor Cyan
Write-Host "  ============================================" -ForegroundColor Cyan
Write-Host ""

function Test-Cmd($name) { return [bool](Get-Command $name -ErrorAction SilentlyContinue) }

# ------------------------------------------------------------
# 0a. Auto-create the root .gitignore if missing (self-healing)
# ------------------------------------------------------------
$gitignore = Join-Path $root ".gitignore"
if (-not (Test-Path -LiteralPath $gitignore)) {
    @'
# Ignore everything by default
*

# Keep the landing index at repo root
!README.md
!.gitignore

# Keep the whole tracker folder (scripts, launchers, SETUP.md, CHANGES.md)
!tracker/
!tracker/**
'@ | Set-Content -LiteralPath $gitignore -Encoding UTF8
    Write-Host "  .gitignore created at repo root." -ForegroundColor Green
}

# ------------------------------------------------------------
# 0b. Core scripts present? (restore from git if missing)
# ------------------------------------------------------------
$coreFull = @($updateScript, (Join-Path $scriptDir "RESET_CHANGES.ps1"))
$missing  = $coreFull | Where-Object { -not (Test-Path -LiteralPath $_) }

if ((Test-Path -LiteralPath "$root\.git") -and $missing.Count -gt 0) {
    Write-Host "  Some files missing - restoring from git..." -ForegroundColor Yellow
    git restore tracker .gitignore 2>$null
    $missing = $coreFull | Where-Object { -not (Test-Path -LiteralPath $_) }
}

if ($missing.Count -gt 0) {
    Write-Host "  ERROR: required files are missing:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
    Write-Host "  Get them from the template repo, then re-run." -ForegroundColor Yellow
    Read-Host "  Press Enter to exit"
    return
}

# ------------------------------------------------------------
# 1. Already set up? (.git + remote) -> just update
# ------------------------------------------------------------
$hasGit = Test-Path -LiteralPath "$root\.git"
$hasRemote = $false
if ($hasGit) {
    $remoteUrl = (git remote get-url origin 2>$null)
    if ($LASTEXITCODE -eq 0 -and $remoteUrl) { $hasRemote = $true }
}

if ($hasGit -and $hasRemote) {
    Write-Host "  Already set up. Remote: $remoteUrl" -ForegroundColor Green
    Write-Host "  Running update..." -ForegroundColor Yellow
    & $updateScript
    return
}

# ------------------------------------------------------------
# 2. git available?
# ------------------------------------------------------------
if (-not (Test-Cmd git)) {
    Write-Host "  ERROR: git is not installed." -ForegroundColor Red
    Write-Host "  Install Git first: https://git-scm.com/download/win" -ForegroundColor Yellow
    Read-Host "  Press Enter to exit"
    return
}

# ------------------------------------------------------------
# 3. gh (GitHub CLI) available? If not, offer to install.
# ------------------------------------------------------------
if (-not (Test-Cmd gh)) {
    Write-Host "  GitHub CLI (gh) is NOT installed." -ForegroundColor Yellow
    Write-Host "  gh is needed to auto-create the GitHub repo." -ForegroundColor Yellow
    Write-Host ""
    $ans = Read-Host "  Install gh now? (Y/N)"
    if ($ans -match '^(y|yes)$') {
        if (Test-Cmd winget) {
            Write-Host "  Installing gh via winget..." -ForegroundColor Yellow
            winget install --id GitHub.cli --silent --accept-source-agreements --accept-package-agreements
            Write-Host ""
            Write-Host "  Installed. CLOSE this window and run '#1- INITIAL.cmd' again." -ForegroundColor Green
        } else {
            Write-Host "  winget not found. Install gh manually:" -ForegroundColor Red
            Write-Host "    https://github.com/cli/cli/releases/latest" -ForegroundColor Cyan
        }
        Read-Host "  Press Enter to exit"
        return
    }
    else {
        $sugg = ($folderName -replace '[^a-zA-Z0-9._-]', '-') + "-Activity-Tracker"
        Write-Host ""
        Write-Host "  ===== MANUAL SETUP (no gh) =====" -ForegroundColor Magenta
        Write-Host "  1. Open: https://github.com/new" -ForegroundColor White
        Write-Host "  2. Create a PRIVATE repo. Add NOTHING (no README)." -ForegroundColor White
        Write-Host "  3. Then run these commands here:" -ForegroundColor White
        Write-Host ""
        Write-Host "     Suggested repo name:  $sugg" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "     git init" -ForegroundColor Gray
        Write-Host "     git add -A" -ForegroundColor Gray
        Write-Host "     git commit -m \"Initial setup\"" -ForegroundColor Gray
        Write-Host "     git branch -M master" -ForegroundColor Gray
        Write-Host "     git remote add origin https://github.com/<you>/$sugg.git" -ForegroundColor Gray
        Write-Host "     git push -u origin master" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  After that, just use '#2- UPDATE_CHANGES.cmd'." -ForegroundColor White
        Read-Host "  Press Enter to exit"
        return
    }
}

# ------------------------------------------------------------
# 4. gh logged in?
# ------------------------------------------------------------
gh auth status 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "  You are not logged in to GitHub CLI." -ForegroundColor Yellow
    Write-Host "  A browser window will open to log in..." -ForegroundColor Yellow
    gh auth login
    gh auth status 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  Login failed. Run 'gh auth login' manually, then re-run." -ForegroundColor Red
        Read-Host "  Press Enter to exit"
        return
    }
}

# ------------------------------------------------------------
# 5. Decide repo name
# ------------------------------------------------------------
$autoName = ($folderName -replace '[^a-zA-Z0-9._-]', '-') + "-Activity-Tracker"
Write-Host ""
$nameAns = Read-Host "  Custom repo name? (Y = type it / N = auto '$autoName')"
if ($nameAns -match '^(y|yes)$') {
    $repoName = Read-Host "  Enter repo name"
    $repoName = ($repoName -replace '[^a-zA-Z0-9._-]', '-')
    if (-not $repoName) { $repoName = $autoName }
} else {
    $repoName = $autoName
}
Write-Host "  Repo name: $repoName  (Private)" -ForegroundColor Cyan

# ------------------------------------------------------------
# 6. git init + first commit (if needed)
# ------------------------------------------------------------
if (-not $hasGit) {
    git init | Out-Null
    git branch -M master 2>$null
}
git add -A
git commit -m "Initial setup" 2>$null | Out-Null

# ------------------------------------------------------------
# 7. Create the GitHub repo (or link if it exists) + push
# ------------------------------------------------------------
Write-Host "  Creating GitHub repo..." -ForegroundColor Yellow
gh repo create $repoName --private --source=. --remote=origin --push 2>$null

if ($LASTEXITCODE -ne 0) {
    $ghUser = (gh api user --jq .login 2>$null)
    if ($ghUser) {
        Write-Host "  Linking $ghUser/$repoName ..." -ForegroundColor Yellow
        git remote remove origin 2>$null
        git remote add origin "https://github.com/$ghUser/$repoName.git"
        git push -u origin master
    } else {
        Write-Host "  Could not create or link the repo. Check gh login." -ForegroundColor Red
        Read-Host "  Press Enter to exit"
        return
    }
}

# ------------------------------------------------------------
# 8. First content (README + CHANGES) + push
# ------------------------------------------------------------
Write-Host ""
Write-Host "  Repo ready. Generating README + CHANGES..." -ForegroundColor Green
& $updateScript

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Magenta
Write-Host "   DONE! '$repoName' is live and tracking." -ForegroundColor Magenta
Write-Host "   From now on just run '#2- UPDATE_CHANGES.cmd'" -ForegroundColor Magenta
Write-Host "  ============================================" -ForegroundColor Magenta
Read-Host "  Press Enter to exit"
