# smorch-cleanup.ps1 — Remove duplicate skills from Claude machines (Windows)
# Works on: Windows PowerShell 5.1+, PowerShell Core 7+
# Usage: .\scripts\smorch-cleanup.ps1
#   OR:  .\scripts\smorch-cleanup.ps1 -DryRun

param(
    [switch]$DryRun,
    [switch]$Force,
    [switch]$Help
)

$ErrorActionPreference = "Continue"

$SkillsDir = "$env:USERPROFILE\.claude\skills"
$PluginsDir = "$env:USERPROFILE\.claude\plugins"
$CommandsDir = "$env:USERPROFILE\.claude\commands"
$DateStamp = Get-Date -Format "yyyyMMdd"
$SkillsBackup = "$env:USERPROFILE\.claude\skills-cleanup-backup-$DateStamp"
$CommandsBackup = "$env:USERPROFILE\.claude\commands-backup-$DateStamp"

if ($Help) {
    Write-Host "smorch-cleanup — Remove duplicate skills from Claude machines" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USAGE: .\smorch-cleanup.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -DryRun     Show what would be cleaned without making changes"
    Write-Host "  -Force      Skip confirmation prompt"
    Write-Host "  -Help       Show this help message"
    Write-Host ""
    Write-Host "Backup locations:"
    Write-Host "  Skills:   $SkillsBackup"
    Write-Host "  Commands: $CommandsBackup"
    exit 0
}

$SkillDupes = @()
$OversizedCommands = @()

# Find duplicate skills
Write-Host ""
Write-Host "=== Scanning for duplicate skills ===" -ForegroundColor Cyan

if (-not (Test-Path $SkillsDir)) {
    Write-Host "[WARN] No skills directory at $SkillsDir — skipping" -ForegroundColor Yellow
} elseif (-not (Test-Path $PluginsDir)) {
    Write-Host "[WARN] No plugins directory at $PluginsDir — skipping" -ForegroundColor Yellow
} else {
    $pluginFiles = Get-ChildItem -Path $PluginsDir -Recurse -Filter "*.md" -ErrorAction SilentlyContinue |
        ForEach-Object { $_.Name }
    $pluginSet = @{}
    foreach ($f in $pluginFiles) { $pluginSet[$f] = $true }

    Get-ChildItem -Path $SkillsDir -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
        if ($pluginSet.ContainsKey($_.Name)) {
            $script:SkillDupes += $_.FullName
        }
    }

    if ($SkillDupes.Count -eq 0) {
        Write-Host "[OK] No duplicate skills found" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Found $($SkillDupes.Count) duplicate skill(s):" -ForegroundColor Yellow
        foreach ($f in $SkillDupes) {
            Write-Host "  - $(Split-Path $f -Leaf)  ($f)" -ForegroundColor Yellow
        }
    }
}

# Find oversized commands
Write-Host ""
Write-Host "=== Scanning for oversized commands (>50 lines) ===" -ForegroundColor Cyan

if (-not (Test-Path $CommandsDir)) {
    Write-Host "[WARN] No commands directory at $CommandsDir — skipping" -ForegroundColor Yellow
} else {
    Get-ChildItem -Path $CommandsDir -File -ErrorAction SilentlyContinue | ForEach-Object {
        $lines = (Get-Content $_.FullName -ErrorAction SilentlyContinue | Measure-Object -Line).Lines
        if ($lines -gt 50) {
            $script:OversizedCommands += $_.FullName
        }
    }

    if ($OversizedCommands.Count -eq 0) {
        Write-Host "[OK] No oversized commands found" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Found $($OversizedCommands.Count) oversized command(s):" -ForegroundColor Yellow
        foreach ($f in $OversizedCommands) {
            $lines = (Get-Content $f | Measure-Object -Line).Lines
            Write-Host "  - $(Split-Path $f -Leaf)  ($lines lines)" -ForegroundColor Yellow
        }
    }
}

# Confirm and execute
$total = $SkillDupes.Count + $OversizedCommands.Count

if ($total -eq 0) {
    Write-Host ""
    Write-Host "[OK] Nothing to clean up. Machine is already tidy." -ForegroundColor Green
    exit 0
}

if ($DryRun) {
    Write-Host ""
    Write-Host "[INFO] Dry run complete. $total item(s) would be moved to backup." -ForegroundColor Cyan
    exit 0
}

if (-not $Force) {
    Write-Host ""
    Write-Host "Will move $total item(s) to backup directories."
    Write-Host "  Skills backup:   $SkillsBackup"
    Write-Host "  Commands backup: $CommandsBackup"
    Write-Host ""
    $response = Read-Host "Proceed? [y/N]"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "[INFO] Cancelled. No changes made." -ForegroundColor Cyan
        exit 0
    }
}

$movedSkills = 0
$movedCommands = 0

if ($SkillDupes.Count -gt 0) {
    New-Item -ItemType Directory -Path $SkillsBackup -Force | Out-Null
    foreach ($f in $SkillDupes) {
        Move-Item -Path $f -Destination $SkillsBackup -Force
        $movedSkills++
        Write-Host "[INFO] Moved $(Split-Path $f -Leaf) -> skills-cleanup-backup-$DateStamp/" -ForegroundColor Cyan
    }
}

if ($OversizedCommands.Count -gt 0) {
    New-Item -ItemType Directory -Path $CommandsBackup -Force | Out-Null
    foreach ($f in $OversizedCommands) {
        Move-Item -Path $f -Destination $CommandsBackup -Force
        $movedCommands++
        Write-Host "[INFO] Moved $(Split-Path $f -Leaf) -> commands-backup-$DateStamp/" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "=== Cleanup Report ===" -ForegroundColor Cyan
Write-Host "  Skills moved:   $movedSkills" -ForegroundColor Green
Write-Host "  Commands moved: $movedCommands" -ForegroundColor Green
if ($movedSkills -gt 0) { Write-Host "  Skills backup:  $SkillsBackup" -ForegroundColor Cyan }
if ($movedCommands -gt 0) { Write-Host "  Commands backup: $CommandsBackup" -ForegroundColor Cyan }
Write-Host ""
Write-Host "[OK] Cleanup complete. Backups preserved if you need to restore." -ForegroundColor Green
