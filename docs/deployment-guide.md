# Deployment & Installation Guide

## Quick Start (5 minutes)

### Prerequisites

- **macOS 11+** or **Linux** (Ubuntu 20.04+, Arch, Fedora, Debian)
- **1Password** account (required for secret management)
- Internet connection

### Fresh Machine Install (macOS)

```bash
# Single interactive command
curl -fsSL https://gist.githubusercontent.com/schmas/a604b0d433a836c5af8a877a3d0f37df/raw/bootstrap-chezmoi.sh | bash
```

The script pauses after installing 1Password to let you enable SSH Agent (Settings → Developer), then automatically runs chezmoi.

This workflow:
- Installs Xcode CLI tools
- Installs Homebrew
- Installs 1Password app (provides SSH agent for private repo)
- Installs 1Password CLI (for secrets in templates)
- Installs all packages from `~/Brewfile`
- Applies macOS system defaults (Dark mode, Dock, Finder, keyboard)
- Configures Touch ID for sudo
- Sets up Fish as default shell
- Installs mise runtimes and shell plugins

### Existing Machine (chezmoi installed)

```bash
chezmoi init https://github.com/schmas/dotfiles.git
```

**Interactive prompts:**
- Select profile (default, server, ct, aaa)
- Choose default editor (nvim, zed, none, code)

#### 2. Preview Changes

```bash
chezmoi apply --dry-run --verbose
```

Review the files that will be created/modified. This is safe to run.

#### 3. Apply Configuration

```bash
chezmoi apply
```

This will:
- Prompt for 1Password account setup (if not already logged in)
- Create all dotfiles
- Run installation scripts for tools
- Set up shell configurations
- Install plugins (Fisher, Sheldon)

#### 4. Verify Installation

```bash
# Test Fish shell
fish --version
source ~/.config/fish/config.fish

# Test Zsh shell
zsh --version
source ~/.config/zsh/zshrc

# Test key tools
git --version
starship --version
atuin --version
```

#### 5. Post-Installation Setup (Manual)

```bash
# Login to Atuin (if not auto-synced)
atuin login

# Configure Git (if templates need user input)
git config --global user.email "your.email@example.com"
git config --global user.name "Your Name"

# Import GPG keys (if needed)
~/.local/share/chezmoi/home/bin/gpg-restore-backup
```

---

## Detailed Installation

### 1. Environment Preparation

The bootstrap script handles all prerequisites automatically. If you prefer manual setup:

#### macOS (Manual)

```bash
# Install Xcode CLI tools
xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install 1Password CLI
brew install --cask 1password-cli

# Install Chezmoi
brew install chezmoi
```

#### Linux (Manual)

```bash
# Install essentials
sudo apt update && sudo apt install -y build-essential curl wget git fish

# Install Homebrew for Linux
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install 1Password CLI (Debian/Ubuntu)
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
  sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" | \
  sudo tee /etc/apt/sources.list.d/1password.list
sudo apt update && sudo apt install -y 1password-cli

# Install Chezmoi
sh -c "$(curl -fsLS chezmoi.io/get)"
```

### 2. Chezmoi Initialization

```bash
# Initialize with dotfiles repo
chezmoi init https://github.com/schmas/dotfiles.git

# Or from existing local directory
chezmoi init /path/to/dotfiles
```

**When prompted:**

1. **Profile Selection**
   - `1` (default) - Full development environment (recommended)
   - `2` (server) - Minimal server setup
   - `3` (ct) - Custom profile
   - `4` (aaa) - Alternative account

2. **Editor Choice**
   - `1` (none) - No editor integration
   - `2` (nvim) - Neovim (default, recommended)
   - `3` (zed) - Zed editor
   - `4` (code) - VS Code

Configuration is saved to `~/.config/chezmoi/chezmoi.toml`

### 3. Review & Apply

```bash
# Dry run to see what will change
chezmoi apply --dry-run --verbose

# Apply configuration
chezmoi apply

# If needed, force refresh
chezmoi apply --force
```

### 4. Shell Configuration

After applying, choose your primary shell:

#### Switch to Fish

```bash
chsh -s /usr/local/bin/fish  # macOS
chsh -s /usr/bin/fish        # Linux
```

#### Switch to Zsh

```bash
chsh -s /usr/local/bin/zsh   # macOS
chsh -s /usr/bin/zsh         # Linux
```

#### Stay with Bash

No action needed; configuration applied automatically.

### 5. Tool Setup

Some tools require additional setup:

#### 1Password CLI Setup

```bash
# Login (one-time)
op account add --address my.1password.com

# Verify
op account list
```

#### Atuin History Setup

```bash
# Create account (one-time)
atuin register

# Login
atuin login

# Sync history (optional)
atuin sync
```

#### Claude Code Setup

```bash
# Run setup (installs CLI, clones config repo, runs initialization)
setup-claude-code

# After setup completes, open Claude Code and run:
/install claude-plugins-official
/install mgrep
```

#### GPG Key Setup

```bash
# If restoring from backup
~/.local/share/chezmoi/home/bin/gpg-restore-backup

# If setting up new
gpg --gen-key

# Backup keys
~/.local/share/chezmoi/home/bin/gpg-backup
```

#### Mise Runtime Setup

```bash
# Install managed tools
mise install

# Verify
mise ls
```

---

## Profile Descriptions

### Profile: `default`
**Use Case:** General-purpose development on macOS/Linux

**Includes:**
- All shells (Fish, Zsh, Bash)
- Full plugin suite (Fisher, Sheldon)
- All editors (IdeaVim, Zed, LunarVim, Vim)
- Development tools (Git, tmux, Atuin, Yazi, Lazygit)
- Mise version manager

**Not Included:**
- Server-specific optimizations
- Minimal configurations

**Recommended For:** Desktop development, daily use

### Profile: `server`
**Use Case:** Minimal server environment

**Includes:**
- Bash primary shell
- Essential tools only (Git, SSH)
- No GUI tools (no Yazi, Zellij)
- Minimal plugins
- Update scripts

**Not Included:**
- IDE configurations
- Completion systems
- Shell multiplexers

**Recommended For:** Headless servers, CI/CD runners

### Profile: `ct`
**Use Case:** [Purpose TBD - see roadmap]

**Status:** Custom profile (purpose unclear)

**To Use:**
1. Select during chezmoi init
2. Review which configs are profile-specific

### Profile: `aaa`
**Use Case:** Alternative account configuration

**Includes:**
- Separate Git identity
- Alternative SSH keys
- Different signing method (OpenPGP vs SSH)

**Status:** Currently unclear; see roadmap for clarification

---

## Machine-Specific Configuration

### Local User Overrides

After installation, customize locally without modifying repo:

#### Fish Shell

Create `~/.config/fish/config_local.fish`:
```fish
# Local machine customizations
abbr myalias 'my command'
set -gx MY_CUSTOM_VAR value
```

#### Zsh Shell

Create `~/.config/zsh/zshrc_local`:
```bash
# Local machine customizations
alias myalias='my command'
export MY_CUSTOM_VAR=value
```

#### Bash Shell

Create `~/.config/bash/bashrc_local`:
```bash
# Local machine customizations
alias myalias='my command'
export MY_CUSTOM_VAR=value
```

#### Git Configuration

Create `~/.config/git/config.local`:
```ini
[user]
    name = Your Name
    email = your.email@example.com

[includeIf "gitdir:~/work/"]
    path = ~/.config/git/work-config
```

### Per-Machine Secrets

Secrets can be stored per-machine without repo:

```bash
# Create local template
cp ~/.config/git/config.template ~/.config/git/config.local

# Edit with machine-specific values
nano ~/.config/git/config.local

# Git will auto-include local config
```

---

## Verification Checklist

After installation, verify everything works:

### Shell Configuration
- [ ] Fish shell starts (`fish --version`)
- [ ] Aliases work (`g --version` for git)
- [ ] Abbreviations expand (Fish: type `g` + space)
- [ ] Completions work (Tab with FZF)
- [ ] Prompt shows (Starship rendering)

### Tools
- [ ] Git configured (`git config user.name`)
- [ ] SSH keys available (`ssh -T git@github.com`)
- [ ] GPG signing works (`git commit --allow-empty -m "test" && git log`)
- [ ] 1Password CLI works (`op account list`)
- [ ] Atuin history works (`history` or Alt-R search)

### Editors
- [ ] Vim/Neovim (`nvim --version`)
- [ ] IdeaVim configured (open IntelliJ IDEA)
- [ ] Zed configured (`zed --version`)

### Development Tools
- [ ] Node.js available (`node --version`)
- [ ] Python available (`python --version`)
- [ ] Go available (`go version`)
- [ ] Rust available (`rustc --version`)

### System Integration
- [ ] Tmux works (`tmux list-sessions`)
- [ ] Starship prompt (`starship check`)
- [ ] FZF finder works (`fzf`)
- [ ] Yazi file manager (`yazi`)
- [ ] Lazygit UI (`lazygit`)

---

## Troubleshooting

### 1Password CLI Not Found

**Error:** `onepasswordRead: command not found`

**Solution:**
```bash
# macOS: Install 1Password CLI
brew install --cask 1password-cli

# Or download from
# https://1password.com/downloads/command-line/

# Login
op account add --address my.1password.com
```

### Shell Not Loading Configuration

**Error:** Aliases/abbreviations not working

**Solution:**
```bash
# Check if config files exist
ls -la ~/.config/fish/config.fish
ls -la ~/.config/zsh/zshrc

# Re-apply configuration
chezmoi apply --force

# Reload shell
exec $SHELL
```

### File Permissions Issues

**Error:** `compaudit` warnings about insecure directories

**Solution:**
```bash
# Fix Zsh permissions
~/.local/share/chezmoi/home/bin/fix-zsh-insecure

# Or manually
compaudit | xargs chmod go-w
```

### Git Signing Not Working

**Error:** `error: gpg failed to sign the data`

**Solution:**
```bash
# Verify GPG setup
gpg --list-secret-keys

# Get key ID
gpg --list-secret-keys --keyid-format LONG

# Configure Git
git config --global user.signingKey <KEY_ID>

# Test
git commit --allow-empty -m "test"
```

### Atuin Sync Issues

**Error:** History not syncing across machines

**Solution:**
```bash
# Check Atuin status
atuin status

# Logout and login
atuin logout
atuin login

# Manual sync
atuin sync

# Check history
atuin history
```

### Mise Tools Not Installing

**Error:** `mise install` fails

**Solution:**
```bash
# Check Mise setup
mise doctor

# Install manually
mise install node@lts
mise install python@3.11

# List what's installed
mise ls
```

---

## Updating Configuration

### Pull Latest Changes

```bash
# Fetch and preview changes
chezmoi status
chezmoi diff

# Apply updates
chezmoi apply

# Update all tools
~/.local/share/chezmoi/home/bin/upall
```

### Update Plugins

```bash
# Fish
fisher update

# Zsh/Bash
sheldon update
```

### Update System

```bash
# Master update script (all tools)
upall

# Or individual commands
brewup           # Homebrew
mise install     # Mise tools
fisher update    # Fisher plugins
```

---

## Uninstall / Rollback

### Remove Dotfiles

```bash
# Remove chezmoi managed files
chezmoi remove-target ~/.config/fish ~/.config/zsh ...

# Or complete cleanup
chezmoi forget --all
```

### Restore Previous Shell

```bash
# Switch back to default shell
chsh -s /bin/bash

# Or system default
chsh -s /bin/sh
```

### Keep Chezmoi Config

If you want to keep some customizations:

```bash
# Export current config
chezmoi dump > my-config.json

# Later, reimport
chezmoi import my-config.json
```

---

## Post-Installation Recommendations

1. **Review SHELL-REFERENCE.md** for all available aliases/functions
2. **Customize local configs** via `*_local` template files
3. **Set up GPG backup** with `gpg-backup` script
4. **Enable Atuin sync** for cross-machine history
5. **Subscribe to updates** via `chezmoi pull` automation
6. **Review security** - ensure 1Password secrets are backed up

---

## Getting Help

- **Documentation:** See `/docs` directory
- **Troubleshooting:** Review `/docs/code-standards.md` and `/docs/system-architecture.md`
- **Aliases & Functions:** Read `SHELL-REFERENCE.md`
- **Repository Issues:** Check GitHub issues/discussions
- **Dry run testing:** Always use `chezmoi apply --dry-run` before applying changes

---

**Last Updated:** Jan 22, 2026
**Status:** Production-Ready
