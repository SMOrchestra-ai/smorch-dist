# SMOrchestra Team Setup — Linux

## Prerequisites

| Tool | How to install | Verify |
|------|---------------|--------|
| Git | `sudo apt install git` (Debian/Ubuntu) or `sudo dnf install git` (Fedora) | `git --version` |
| GitHub CLI | See [cli.github.com/manual/installation](https://cli.github.com/manual/installation) | `gh --version` |
| Claude Desktop (Cowork) | Download from [claude.ai](https://claude.ai/download) | Open app |

### GitHub CLI install (Ubuntu/Debian):

```bash
(type -p wget >/dev/null || sudo apt install wget -y) \
  && sudo mkdir -p -m 755 /etc/apt/keyrings \
  && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y
```

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
mkdir -p ~/Desktop/cowork-workspace && cd ~/Desktop/cowork-workspace

# Clone distribution repo (everyone needs this)
gh repo clone SMOrchestra-ai/smorch-dist

# Clone context repo (if your role requires it)
gh repo clone SMOrchestra-ai/smorch-context
```

> **No Desktop directory?** Use `~/smorch-workspace` instead — the scripts auto-detect it.
> Or set a custom path:
> ```bash
> export SMORCH_WORKSPACE="$HOME/my-custom-path"
> ```
> Add to `~/.bashrc` to persist.

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

Add to `~/.bashrc`:

```bash
export PATH="$HOME/Desktop/cowork-workspace/smorch-dist/scripts:$PATH"
```

Then reload: `source ~/.bashrc`

Now run commands directly: `smorch status`, `smorch-sync`, etc.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `Permission denied` on scripts | `chmod +x ~/Desktop/cowork-workspace/smorch-dist/scripts/*` |
| `git: command not found` | `sudo apt install git` (Debian/Ubuntu) or `sudo dnf install git` (Fedora) |
| `gh: command not found` | Follow install instructions above for your distro |
| Auth fails on `git pull` | `gh auth refresh` then retry |
| Plugins not showing in Cowork | Verify workspace path points to `smorch-dist`, click Save again |
| No `~/Desktop` directory | Use `~/smorch-workspace` or set `SMORCH_WORKSPACE` env var |
| `sha256sum` not found | `sudo apt install coreutils` (extremely rare — usually pre-installed) |

## Cleanup (if needed)

Remove duplicate skills from a previous manual install:

```bash
bash ~/Desktop/cowork-workspace/smorch-dist/scripts/smorch-cleanup --dry-run
# If it looks right:
bash ~/Desktop/cowork-workspace/smorch-dist/scripts/smorch-cleanup
```
