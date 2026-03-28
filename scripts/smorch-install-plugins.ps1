# smorch-install-plugins.ps1 — Install plugins for your role (Windows)
# Works on: Windows PowerShell 5.1+, PowerShell Core 7+
# Usage: .\scripts\smorch-install-plugins.ps1 --role <role>
#   OR:  powershell -File scripts\smorch-install-plugins.ps1 --role <role>

param(
    [string]$Role,
    [switch]$List,
    [switch]$Help
)

$ErrorActionPreference = "Continue"

function Show-Help {
    Write-Host "smorch-install-plugins — Install plugins for your role" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USAGE: .\smorch-install-plugins.ps1 -Role <role>"
    Write-Host ""
    Write-Host "ROLES:"
    Write-Host "  -Role gtm-eo       GTM-EO team (Cowork only, no Code plugins)"
    Write-Host "  -Role gtm-smo      GTM-SMO team (Cowork only, no Code plugins)"
    Write-Host "  -Role dev          Dev team (Cowork + 7 Code dev tools)"
    Write-Host "  -Role eo-student   EO student (Cowork + 7 Code dev tools)"
    Write-Host "  -Role mamoun       Everything"
    Write-Host ""
    Write-Host "  -List              Show what each role gets"
}

function Install-CodePlugins {
    Write-Host "Installing 7 Claude Code Dev Tools" -ForegroundColor Cyan
    Write-Host "(NOT available in Cowork — Code only)" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "  Language Servers:" -ForegroundColor Blue
    foreach ($p in @("typescript-lsp", "pyright-lsp", "rust-analyzer-lsp", "gopls-lsp")) {
        Write-Host "  Installing ${p}@claude-plugins-official..." -ForegroundColor Blue
        $null = claude /plugin install "${p}@claude-plugins-official" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    OK" -ForegroundColor Green
        } else {
            Write-Host "    SKIP (already installed)" -ForegroundColor Yellow
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
            Write-Host "    SKIP (already installed)" -ForegroundColor Yellow
        }
    }
}

function Show-CoworkInstructions {
    param([string[]]$Plugins)
    Write-Host ""
    Write-Host "Load plugins into Cowork Desktop:" -ForegroundColor Cyan
    Write-Host "  1. Open Claude Desktop (Cowork)"
    Write-Host "  2. Go to Customize > Workspace"
    Write-Host "  3. Point workspace to your smorch-dist directory"
    Write-Host "  4. Cowork scans and discovers all plugins automatically"
    Write-Host "  5. Click Save -- plugins are now active"
    Write-Host ""
    Write-Host "Your role gets these $($Plugins.Count) plugins:" -ForegroundColor Cyan
    foreach ($p in $Plugins) {
        Write-Host "  - $p"
    }
}

function Show-List {
    Write-Host "=== What Each Role Gets ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "GTM-EO Team:" -ForegroundColor Green
    Write-Host "  Cowork (7): smorch-context-brain, smorch-gtm-tools, smorch-gtm-engine,"
    Write-Host "              smorch-design, mamoun-personal-branding, smorch-gtm-scoring,"
    Write-Host "              eo-microsaas-os"
    Write-Host "  Code:       None"
    Write-Host ""
    Write-Host "GTM-SMO Team:" -ForegroundColor Green
    Write-Host "  Cowork (6): smorch-context-brain, smorch-gtm-tools, smorch-gtm-engine,"
    Write-Host "              smorch-design, mamoun-personal-branding, smorch-gtm-scoring"
    Write-Host "  Code:       None"
    Write-Host ""
    Write-Host "Dev Team:" -ForegroundColor Green
    Write-Host "  Cowork (2): smorch-dev, smorch-dev-scoring"
    Write-Host "  Code (7):   typescript-lsp, pyright-lsp, rust-analyzer-lsp, gopls-lsp,"
    Write-Host "              code-review, frontend-design, github"
    Write-Host ""
    Write-Host "EO Student:" -ForegroundColor Green
    Write-Host "  Cowork (3): eo-microsaas-os, smorch-dev, smorch-dev-scoring"
    Write-Host "  Code (7):   typescript-lsp, pyright-lsp, rust-analyzer-lsp, gopls-lsp,"
    Write-Host "              code-review, frontend-design, github"
}

# Main
if ($Help) { Show-Help; exit 0 }
if ($List) { Show-List; exit 0 }

if (-not $Role) {
    Write-Host "ERROR: No role specified. Use -Role <name>" -ForegroundColor Red
    Show-Help
    exit 1
}

switch ($Role) {
    "gtm-eo" {
        Write-Host "=== GTM-EO Team Setup ===" -ForegroundColor Green
        Write-Host ""
        Write-Host "No Claude Code plugins needed for GTM roles." -ForegroundColor Yellow
        Show-CoworkInstructions @(
            "smorch-context-brain", "smorch-gtm-tools", "smorch-gtm-engine",
            "smorch-design", "mamoun-personal-branding", "smorch-gtm-scoring",
            "eo-microsaas-os"
        )
    }
    "gtm-smo" {
        Write-Host "=== GTM-SMO Team Setup ===" -ForegroundColor Green
        Write-Host ""
        Write-Host "No Claude Code plugins needed for GTM roles." -ForegroundColor Yellow
        Show-CoworkInstructions @(
            "smorch-context-brain", "smorch-gtm-tools", "smorch-gtm-engine",
            "smorch-design", "mamoun-personal-branding", "smorch-gtm-scoring"
        )
    }
    "dev" {
        Write-Host "=== Dev Team Setup ===" -ForegroundColor Green
        Write-Host ""
        Install-CodePlugins
        Show-CoworkInstructions @("smorch-dev", "smorch-dev-scoring")
    }
    "eo-student" {
        Write-Host "=== EO Student Setup ===" -ForegroundColor Green
        Write-Host ""
        Install-CodePlugins
        Show-CoworkInstructions @("eo-microsaas-os", "smorch-dev", "smorch-dev-scoring")
    }
    "mamoun" {
        Write-Host "=== Mamoun (All Access) ===" -ForegroundColor Green
        Write-Host ""
        Install-CodePlugins
        Write-Host ""
        Write-Host "All Cowork plugins should already be installed." -ForegroundColor Cyan
    }
    default {
        Write-Host "Unknown role: $Role" -ForegroundColor Red
        Write-Host "Available: gtm-eo, gtm-smo, dev, eo-student, mamoun"
        exit 1
    }
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
