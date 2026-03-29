# smorch-setup.ps1 — One-command setup for SMOrchestra skills (Windows)
# Works on: Windows PowerShell 5.1+, PowerShell Core 7+
#
# Quick install (run in PowerShell):
#   irm https://raw.githubusercontent.com/SMOrchestra-ai/smorch-dist/main/scripts/smorch-setup.ps1 | iex
#
# Or clone first, then run:
#   .\scripts\smorch-setup.ps1 -Role dev

param(
    [string]$Role,
    [switch]$List,
    [switch]$Update,
    [switch]$Help
)

$ErrorActionPreference = "Continue"
$Version = "1.0.0"
$RepoUrl = "https://github.com/SMOrchestra-ai/smorch-dist.git"

# --- Helpers ---
function Write-Info  { param([string]$Msg) Write-Host "[INFO] $Msg" -ForegroundColor Cyan }
function Write-Ok    { param([string]$Msg) Write-Host "[OK] $Msg" -ForegroundColor Green }
function Write-Warn  { param([string]$Msg) Write-Host "[WARN] $Msg" -ForegroundColor Yellow }
function Write-Fail  { param([string]$Msg) Write-Host "[ERROR] $Msg" -ForegroundColor Red; exit 1 }

# --- Detect workspace ---
function Get-Workspace {
    if ($env:SMORCH_WORKSPACE -and (Test-Path $env:SMORCH_WORKSPACE)) {
        return $env:SMORCH_WORKSPACE
    }
    $desktopWs = Join-Path $env:USERPROFILE "Desktop\cowork-workspace"
    if (Test-Path $desktopWs) { return $desktopWs }

    $smarchWs = Join-Path $env:USERPROFILE "smorch-workspace"
    if (Test-Path $smarchWs) { return $smarchWs }

    # Default: create on Desktop
    return $desktopWs
}

# --- Show help ---
function Show-Help {
    Write-Host "smorch-setup v$Version - One-command SMOrchestra skill installer" -ForegroundColor White
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor White
    Write-Host "  .\smorch-setup.ps1 -Role <role>     Download + install for your role"
    Write-Host "  .\smorch-setup.ps1 -List             Show available roles"
    Write-Host "  .\smorch-setup.ps1 -Update           Pull latest updates only"
    Write-Host "  .\smorch-setup.ps1 -Help             Show this help"
    Write-Host ""
    Write-Host "ROLES:" -ForegroundColor White
    Write-Host "  gtm-eo       GTM-EO team (Cowork plugins only)"
    Write-Host "  gtm-smo      GTM-SMO team (Cowork plugins only)"
    Write-Host "  dev          Dev team (Cowork + 7 Claude Code tools)"
    Write-Host "  eo-student   EO student (Cowork + 7 Claude Code tools)"
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor White
    Write-Host "  .\smorch-setup.ps1 -Role gtm-eo"
    Write-Host "  .\smorch-setup.ps1 -Role dev"
    Write-Host "  .\smorch-setup.ps1 -Update"
}

# --- Show role list ---
function Show-List {
    Write-Host "Available Roles:" -ForegroundColor White
    Write-Host ""
    Write-Host "gtm-eo" -ForegroundColor Green -NoNewline; Write-Host "       GTM-EO team"
    Write-Host "  Cowork (7): smorch-context-brain, smorch-gtm-tools, smorch-gtm-engine,"
    Write-Host "              smorch-design, mamoun-personal-branding, smorch-gtm-scoring,"
    Write-Host "              eo-microsaas-os"
    Write-Host "  Code:       None"
    Write-Host ""
    Write-Host "gtm-smo" -ForegroundColor Green -NoNewline; Write-Host "      GTM-SMO team"
    Write-Host "  Cowork (6): smorch-context-brain, smorch-gtm-tools, smorch-gtm-engine,"
    Write-Host "              smorch-design, mamoun-personal-branding, smorch-gtm-scoring"
    Write-Host "  Code:       None"
    Write-Host ""
    Write-Host "dev" -ForegroundColor Green -NoNewline; Write-Host "          Developer team"
    Write-Host "  Cowork (2): smorch-dev, smorch-dev-scoring"
    Write-Host "  Code (7):   typescript-lsp, pyright-lsp, rust-analyzer-lsp, gopls-lsp,"
    Write-Host "              code-review, frontend-design, github"
    Write-Host ""
    Write-Host "eo-student" -ForegroundColor Green -NoNewline; Write-Host "   EO student"
    Write-Host "  Cowork (3): eo-microsaas-os, smorch-dev, smorch-dev-scoring"
    Write-Host "  Code (7):   typescript-lsp, pyright-lsp, rust-analyzer-lsp, gopls-lsp,"
    Write-Host "              code-review, frontend-design, github"
}

# --- Step 1: Download / Clone ---
function Step-Download {
    param([string]$Workspace)
    $distDir = Join-Path $Workspace "smorch-dist"

    Write-Host ""
    Write-Host "--- Step 1: Download SMOrchestra Skills ---" -ForegroundColor Cyan

    if (Test-Path (Join-Path $distDir ".git")) {
        Write-Info "smorch-dist found at $distDir - pulling latest..."
        $null = git -C $distDir pull origin main 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "Pull failed. Using existing version."
        } else {
            Write-Ok "Updated to latest version."
        }
    } else {
        Write-Info "Cloning smorch-dist to $distDir..."
        if (-not (Test-Path $Workspace)) {
            New-Item -ItemType Directory -Path $Workspace -Force | Out-Null
        }
        git clone $RepoUrl $distDir 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Fail "Clone failed. Check your internet connection and try again."
        }
        Write-Ok "Downloaded smorch-dist."
    }

    return $distDir
}

# --- Step 2: Verify integrity ---
function Step-Verify {
    param([string]$DistDir)

    Write-Host ""
    Write-Host "--- Step 2: Verify Plugin Integrity ---" -ForegroundColor Cyan

    $manifest = Join-Path $DistDir "dist\.manifest"
    if (-not (Test-Path $manifest)) {
        Write-Warn "No integrity manifest found. Skipping verification."
        return
    }

    $failures = 0
    $checked = 0
    Get-Content $manifest | ForEach-Object {
        if ($_ -match '^(\S+)\s+(.+)$') {
            $expectedHash = $Matches[1]
            $filename = $Matches[2]
            $filePath = Join-Path $DistDir "dist\$filename"
            if (Test-Path $filePath) {
                $actualHash = (Get-FileHash -Path $filePath -Algorithm SHA256).Hash.ToLower()
                if ($expectedHash -ne $actualHash) {
                    Write-Host "  FAIL $filename" -ForegroundColor Red
                    $script:failures++
                }
                $script:checked++
            }
        }
    }

    if ($failures -gt 0) {
        Write-Fail "$failures plugin(s) failed integrity check. Re-run or contact admin."
    }

    Write-Ok "All $checked plugins verified (SHA-256)."
}

# --- Step 3: Install Claude Code plugins ---
function Step-CodePlugins {
    param([string]$Role)

    if ($Role -ne "dev" -and $Role -ne "eo-student") { return }

    Write-Host ""
    Write-Host "--- Step 3: Install Claude Code Dev Tools ---" -ForegroundColor Cyan

    if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
        Write-Warn "Claude CLI not found. Skipping Code plugin install."
        Write-Warn "Install Claude Code first, then re-run this script."
        return
    }

    Write-Host "  Language Servers:" -ForegroundColor Blue
    foreach ($p in @("typescript-lsp", "pyright-lsp", "rust-analyzer-lsp", "gopls-lsp")) {
        Write-Host "  Installing ${p}@claude-plugins-official..." -ForegroundColor Blue
        $null = claude /plugin install "${p}@claude-plugins-official" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    OK" -ForegroundColor Green
        } else {
            Write-Host "    SKIP (already installed or unavailable)" -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "  Dev Tools:" -ForegroundColor Blue
    foreach ($p in @("code-review", "frontend-design", "github")) {
        Write-Host "  Installing ${p}@claude-plugins-official..." -ForegroundColor Blue
        $null = claude /plugin install "${p}@claude-plugins-official" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    OK" -ForegroundColor Green
        } else {
            Write-Host "    SKIP (already installed or unavailable)" -ForegroundColor Yellow
        }
    }

    Write-Ok "Claude Code dev tools installed."
}

# --- Step 4: Cowork Desktop instructions ---
function Step-CoworkInstructions {
    param([string]$DistDir, [string]$Role)

    Write-Host ""
    Write-Host "--- Step 4: Connect to Cowork Desktop ---" -ForegroundColor Cyan
    Write-Host ""

    $plugins = switch ($Role) {
        "gtm-eo"     { "smorch-context-brain, smorch-gtm-tools, smorch-gtm-engine, smorch-design, mamoun-personal-branding, smorch-gtm-scoring, eo-microsaas-os" }
        "gtm-smo"    { "smorch-context-brain, smorch-gtm-tools, smorch-gtm-engine, smorch-design, mamoun-personal-branding, smorch-gtm-scoring" }
        "dev"        { "smorch-dev, smorch-dev-scoring" }
        "eo-student" { "eo-microsaas-os, smorch-dev, smorch-dev-scoring" }
    }

    Write-Host "  To activate plugins in Cowork Desktop:" -ForegroundColor White
    Write-Host ""
    Write-Host "  1. Open Claude Desktop (Cowork)"
    Write-Host "  2. Go to Customize > Workspace"
    Write-Host "  3. Set workspace path to:"
    Write-Host ""
    Write-Host "     $DistDir\plugins" -ForegroundColor Green
    Write-Host ""
    Write-Host "  4. Click Save - plugins are now active"
    Write-Host ""
    Write-Host "  Your role ($Role) gets: $plugins" -ForegroundColor Cyan
}

# --- Step 5: Summary ---
function Step-Summary {
    param([string]$DistDir, [string]$Role)

    Write-Host ""
    Write-Host "  ========================================" -ForegroundColor Green
    Write-Host "  Setup complete!" -ForegroundColor Green
    Write-Host "  ========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Role:       $Role" -ForegroundColor White
    Write-Host "  Dist:       $DistDir"
    Write-Host "  Plugins:    $DistDir\plugins\"
    Write-Host ""
    Write-Host "  To update later:" -ForegroundColor Cyan
    Write-Host "    .\smorch-setup.ps1 -Update"
    Write-Host "    OR"
    Write-Host "    cd $DistDir; git pull"
    Write-Host ""
}

# --- Update only ---
function Invoke-Update {
    $workspace = Get-Workspace
    $distDir = Join-Path $workspace "smorch-dist"

    Write-Host "smorch-setup - Updating skills..." -ForegroundColor White

    if (-not (Test-Path (Join-Path $distDir ".git"))) {
        Write-Fail "smorch-dist not found at $distDir. Run .\smorch-setup.ps1 -Role <role> first."
    }

    Write-Info "Pulling latest from smorch-dist..."
    git -C $distDir pull origin main 2>&1
    Step-Verify $distDir
    Write-Ok "Updated to latest. Cowork Desktop will pick up changes automatically."
}

# --- Main ---

# Prerequisites
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Fail "git is required. Install it: https://git-scm.com/downloads"
}

# Dispatch
if ($Help) { Show-Help; exit 0 }
if ($List) { Show-List; exit 0 }
if ($Update) { Invoke-Update; exit 0 }

if (-not $Role) {
    Write-Host "smorch-setup v$Version - SMOrchestra Skill Installer" -ForegroundColor White
    Write-Host ""
    Write-Host "No role specified. Pick your role:" -ForegroundColor Red
    Write-Host ""
    Write-Host "  .\smorch-setup.ps1 -Role gtm-eo       GTM-EO team" -ForegroundColor Green
    Write-Host "  .\smorch-setup.ps1 -Role gtm-smo      GTM-SMO team" -ForegroundColor Green
    Write-Host "  .\smorch-setup.ps1 -Role dev           Developer" -ForegroundColor Green
    Write-Host "  .\smorch-setup.ps1 -Role eo-student    EO student" -ForegroundColor Green
    Write-Host ""
    Write-Host "  .\smorch-setup.ps1 -List              See what each role gets" -ForegroundColor Cyan
    exit 1
}

# Validate role
$validRoles = @("gtm-eo", "gtm-smo", "dev", "eo-student")
if ($Role -notin $validRoles) {
    Write-Fail "Unknown role: $Role. Available: $($validRoles -join ', ')"
}

Write-Host "smorch-setup v$Version" -ForegroundColor White
Write-Host "Role: $Role" -ForegroundColor Green

# Execute steps
$workspace = Get-Workspace
$distDir = Step-Download $workspace
Step-Verify $distDir
Step-CodePlugins $Role
Step-CoworkInstructions $distDir $Role
Step-Summary $distDir $Role
