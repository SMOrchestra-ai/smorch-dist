# SMOrchestra Team Setup — macOS

## Prerequisites

| Tool | How to install | Verify |
|------|---------------|--------|
| Git | `xcode-select --install` or [git-scm.com](https://git-scm.com/downloads) | `git --version` |
| GitHub CLI | `brew install gh` | `gh --version` |
| Claude Desktop (Cowork) | Download from [claude.ai](https://claude.ai/download) | Open app |

## Step 1: Authenticate with GitHub

```bash
gh auth login
```

Select: **GitHub.com** → **HTTPS** → **Login with a web browser**

Verify:

```bash
gh auth status
```

## Step 2: Clone the repositories

```bash
cd ~/Desktop/cowork-workspace

# Clone distribution repo (everyone needs this)
gh repo clone SMOrchestra-ai/smorch-dist

# Clone context repo (if your role requires it)
gh repo clone SMOrchestra-ai/smorch-context
```

> **Custom workspace location?** Set `SMORCH_WORKSPACE` in your `~/.zshrc`:
> ```bash
> export SMORCH_WORKSPACE="$HOME/my-custom-path"
> ```

## Step 3: Make scripts executable

```bash
chmod +x ~/Desktop/cowork-workspace/smorch-dist/scripts/*
```

## Step 4: Install plugins for your role

```bash
bash ~/Desktop/cowork-workspace/smorch-dist/scripts/smorch-install-plugins --role <your-role>
```

Roles: `gtm-eo`, `gtm-smo`, `dev`, `eo-student`

Not sure? Run:

```bash
bash ~/Desktop/cowork-workspace/smorch-dist/scripts/smorch-install-plugins --list
```

## Step 5: Connect Cowork Desktop to plugins

1. Open **Claude Desktop** (Cowork)
2. Go to **Customize > Workspace**
3. Point workspace to: `~/Desktop/cowork-workspace/smorch-dist`
4. Cowork scans and discovers all plugins automatically
5. Click **Save**

## Step 6: First sync

```bash
bash ~/Desktop/cowork-workspace/smorch-dist/scripts/smorch init --profile <your-role>
```

## Daily workflow

Pull latest updates across all repos:

```bash
bash ~/Desktop/cowork-workspace/smorch-dist/scripts/smorch-sync
```

Or sync just the distribution repo:

```bash
bash ~/Desktop/cowork-workspace/smorch-dist/scripts/smorch pull
```

## Optional: Add to PATH

Add to `~/.zshrc` for quick access:

```bash
export PATH="$HOME/Desktop/cowork-workspace/smorch-dist/scripts:$PATH"
```

Then run commands directly: `smorch status`, `smorch-sync`, etc.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `Permission denied` on scripts | `chmod +x ~/Desktop/cowork-workspace/smorch-dist/scripts/*` |
| `git: command not found` | `xcode-select --install` |
| `gh: command not found` | `brew install gh` |
| Auth fails on `git pull` | `gh auth refresh` then retry |
| Plugins not showing in Cowork | Verify workspace path points to `smorch-dist`, click Save again |
| Custom workspace path | Set `SMORCH_WORKSPACE` env var in `~/.zshrc` |

## Cleanup (if needed)

Remove duplicate skills from a previous manual install:

```bash
bash ~/Desktop/cowork-workspace/smorch-dist/scripts/smorch-cleanup --dry-run
# If it looks right:
bash ~/Desktop/cowork-workspace/smorch-dist/scripts/smorch-cleanup
```
