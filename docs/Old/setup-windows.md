# SMOrchestra Team Setup — Windows

## Prerequisites

| Tool | How to install | Verify |
|------|---------------|--------|
| Git for Windows | [git-scm.com/download/win](https://git-scm.com/download/win) — includes Git Bash | Open **Git Bash**, type `git --version` |
| GitHub CLI | `winget install GitHub.cli` or download from [cli.github.com](https://cli.github.com) | `gh --version` |
| Claude Desktop (Cowork) | Download from [claude.ai](https://claude.ai/download) | Open app |

> **Important:** You have two options for running scripts:
> - **Git Bash** (recommended) — runs the bash `.sh` scripts
> - **PowerShell** — runs the `.ps1` scripts (Windows-native)
>
> Both work. Choose one and use it consistently.

## Step 1: Authenticate with GitHub

### Git Bash:
```bash
gh auth login
```

### PowerShell:
```powershell
gh auth login
```

Select: **GitHub.com** → **HTTPS** → **Login with a web browser**

Verify: `gh auth status`

## Step 2: Clone the repositories

### Git Bash:
```bash
cd ~/Desktop/cowork-workspace
# If directory doesn't exist:
mkdir -p ~/Desktop/cowork-workspace && cd ~/Desktop/cowork-workspace

gh repo clone SMOrchestra-ai/smorch-dist
gh repo clone SMOrchestra-ai/smorch-context
```

### PowerShell:
```powershell
cd "$env:USERPROFILE\Desktop\cowork-workspace"
# If directory doesn't exist:
New-Item -ItemType Directory -Path "$env:USERPROFILE\Desktop\cowork-workspace" -Force
cd "$env:USERPROFILE\Desktop\cowork-workspace"

gh repo clone SMOrchestra-ai/smorch-dist
gh repo clone SMOrchestra-ai/smorch-context
```

> **Custom workspace location?** Set `SMORCH_WORKSPACE` environment variable:
> - **System Settings** → **Environment Variables** → Add `SMORCH_WORKSPACE` = `C:\your\custom\path`
> - Or in PowerShell: `[System.Environment]::SetEnvironmentVariable("SMORCH_WORKSPACE", "C:\your\path", "User")`

## Step 3: Install plugins for your role

### Git Bash:
```bash
bash ~/Desktop/cowork-workspace/smorch-dist/scripts/smorch-install-plugins --role <your-role>
```

### PowerShell:
```powershell
& "$env:USERPROFILE\Desktop\cowork-workspace\smorch-dist\scripts\smorch-install-plugins.ps1" -Role <your-role>
```

Roles: `gtm-eo`, `gtm-smo`, `dev`, `eo-student`

Not sure? Add `--list` (bash) or `-List` (PowerShell).

## Step 4: Connect Cowork Desktop to plugins

1. Open **Claude Desktop** (Cowork)
2. Go to **Customize > Workspace**
3. Point workspace to: `C:\Users\<you>\Desktop\cowork-workspace\smorch-dist`
4. Cowork scans and discovers all plugins automatically
5. Click **Save**

## Step 5: First sync

### Git Bash:
```bash
bash ~/Desktop/cowork-workspace/smorch-dist/scripts/smorch init --profile <your-role>
```

### PowerShell:
```powershell
# PowerShell doesn't have the smorch CLI — use Git Bash for init
# Or run the sync script:
& "$env:USERPROFILE\Desktop\cowork-workspace\smorch-dist\scripts\smorch-sync.ps1"
```

## Daily workflow

### Git Bash:
```bash
# Sync all repos
bash ~/Desktop/cowork-workspace/smorch-dist/scripts/smorch-sync

# Or sync just distribution
bash ~/Desktop/cowork-workspace/smorch-dist/scripts/smorch pull
```

### PowerShell:
```powershell
# Sync all repos
& "$env:USERPROFILE\Desktop\cowork-workspace\smorch-dist\scripts\smorch-sync.ps1"
```

## Optional: Add to PATH

### Git Bash (add to `~/.bashrc`):
```bash
export PATH="$HOME/Desktop/cowork-workspace/smorch-dist/scripts:$PATH"
```

### PowerShell (add to profile):
```powershell
# Open profile:
notepad $PROFILE
# Add this line:
$env:PATH += ";$env:USERPROFILE\Desktop\cowork-workspace\smorch-dist\scripts"
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `git: command not found` (Git Bash) | Reinstall Git for Windows, ensure "Add to PATH" is checked |
| `gh: command not found` | `winget install GitHub.cli`, then restart terminal |
| PowerShell blocks `.ps1` scripts | Run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| Auth fails on `git pull` | `gh auth refresh` then retry |
| Plugins not showing in Cowork | Verify workspace path uses backslashes in Windows, click Save again |
| Custom workspace path | Set `SMORCH_WORKSPACE` environment variable (see Step 2) |
| Line ending issues | Run `git config --global core.autocrlf true` |

## Cleanup (if needed)

### Git Bash:
```bash
bash ~/Desktop/cowork-workspace/smorch-dist/scripts/smorch-cleanup --dry-run
bash ~/Desktop/cowork-workspace/smorch-dist/scripts/smorch-cleanup
```

### PowerShell:
```powershell
& "$env:USERPROFILE\Desktop\cowork-workspace\smorch-dist\scripts\smorch-cleanup.ps1" -DryRun
& "$env:USERPROFILE\Desktop\cowork-workspace\smorch-dist\scripts\smorch-cleanup.ps1"
```
