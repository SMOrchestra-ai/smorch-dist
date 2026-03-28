# smorch-sync.ps1 — Pull latest updates for all SMOrchestra repos
# Works on: Windows PowerShell 5.1+, PowerShell Core 7+ (all platforms)
# Usage: .\scripts\smorch-sync.ps1
#   OR:  powershell -File scripts\smorch-sync.ps1

$ErrorActionPreference = "Continue"

# Prerequisite check
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] git is required but not installed. See: https://git-scm.com/downloads" -ForegroundColor Red
    exit 1
}

# Auto-detect workspace directory (override with SMORCH_WORKSPACE env var)
$workspace = $null
if ($env:SMORCH_WORKSPACE -and (Test-Path $env:SMORCH_WORKSPACE)) {
    $workspace = $env:SMORCH_WORKSPACE
} else {
    $candidates = @(
        "$env:USERPROFILE\Desktop\cowork-workspace",
        "$env:USERPROFILE\smorch-workspace",
        "$env:USERPROFILE\workspace",
        "$HOME\Desktop\cowork-workspace",
        "$HOME\smorch-workspace",
        "$HOME\workspace"
    )
    foreach ($path in $candidates) {
        if (Test-Path $path) {
            $workspace = $path
            break
        }
    }
}

if (-not $workspace) {
    Write-Host "ERROR: Cannot find workspace directory." -ForegroundColor Red
    Write-Host "Expected one of:"
    foreach ($path in $candidates) { Write-Host "  $path" }
    exit 1
}

Write-Host "smorch-sync — Pulling latest from all repos" -ForegroundColor Cyan
Write-Host "Workspace: $workspace"
Write-Host "------------------------------------"

$success = 0
$failed = 0

Get-ChildItem $workspace -Directory | ForEach-Object {
    $repo = $_.FullName
    $name = $_.Name

    # Check if it's a git repo
    if (-not (Test-Path "$repo\.git")) { return }

    # Try main first, then dev — capture error for diagnostics
    $errMain = git -C "$repo" pull origin main 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  $name — synced (main)" -ForegroundColor Green
        $script:success++
    } else {
        $errDev = git -C "$repo" pull origin dev 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  $name — synced (dev)" -ForegroundColor Green
            $script:success++
        } else {
            Write-Host "  $name — FAILED" -ForegroundColor Red
            Write-Host "    $errDev" -ForegroundColor Yellow
            $script:failed++
        }
    }
}

Write-Host "------------------------------------"
Write-Host "Synced: $success  |  Failed: $failed"

if ($failed -gt 0) {
    Write-Host "Fix failed repos: cd into the repo and run 'git pull' to see the error." -ForegroundColor Yellow
}
