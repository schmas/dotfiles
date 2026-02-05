# Phase 05: Add Homebrew + Pre-Chezmoi Bootstrap Scripts

## Status: completed

## Overview

Create:
1. **Standalone bootstrap script** - Run before `chezmoi init` to install prerequisites
2. **Chezmoi `run_before_` scripts** - Install Homebrew and packages during `chezmoi apply`

## Target Files

### Standalone Pre-Chezmoi Bootstrap

**Public Gist:** https://gist.github.com/schmas/a604b0d433a836c5af8a877a3d0f37df

Create `bin/bootstrap-chezmoi.sh` (also hosted as public gist for private repo access):

```bash
#!/usr/bin/env bash
# Run BEFORE chezmoi init to install required prerequisites
# Usage: curl -fsSL https://gist.githubusercontent.com/schmas/a604b0d433a836c5af8a877a3d0f37df/raw/bootstrap-chezmoi.sh | bash

set -e

echo "==> Chezmoi Bootstrap Script"
echo "    Installing prerequisites before chezmoi init..."

OS="$(uname -s)"

# Install Xcode CLI Tools (macOS)
if [[ "$OS" == "Darwin" ]]; then
  if ! xcode-select -p &> /dev/null; then
    echo "==> Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "    Waiting for Xcode CLI tools installation..."
    until xcode-select -p &> /dev/null; do
      sleep 5
    done
  else
    echo "    Xcode CLI tools already installed"
  fi
fi

# Install Homebrew
if ! command -v brew &> /dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add to current session
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
else
  echo "    Homebrew already installed"
fi

# Install 1Password CLI (required for chezmoi secrets)
if ! command -v op &> /dev/null; then
  echo "==> Installing 1Password CLI..."
  if [[ "$OS" == "Darwin" ]]; then
    brew install --cask 1password-cli
  else
    # Linux: use Homebrew version (simpler)
    brew install 1password-cli
  fi
else
  echo "    1Password CLI already installed"
fi

echo ""
echo "==> Prerequisites installed!"
echo "    Next steps:"
echo "    1. Sign in to 1Password: op signin"
echo "    2. Run chezmoi: sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- init --apply schmas"
echo ""
```

This script:
- Installs Xcode CLI tools (macOS only)
- Installs Homebrew (macOS/Linux)
- Installs 1Password CLI (required for secrets in templates)

### macOS Bootstrap

Create `home/.chezmoiscripts/00-run-before/run_before_01-install-homebrew-on-macos.sh.tmpl`:

```bash
#!/usr/bin/env bash
{{ if ne .chezmoi.os "darwin" }}
exit 0
{{ end }}

set -e

if command -v brew &> /dev/null; then
  echo "Homebrew already installed"
  exit 0
fi

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to current session (for Apple Silicon)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

echo "Homebrew installed successfully!"
```

### Package Installation

Create `home/.chezmoiscripts/00-run-before/run_before_02-install-packages-from-brewfile.sh.tmpl`:

```bash
#!/usr/bin/env bash
{{ if ne .chezmoi.os "darwin" }}
# Linux uses the linux-system-setup script instead
exit 0
{{ end }}

set -e

# Ensure brew is in PATH
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v brew &> /dev/null; then
  echo "Error: Homebrew not found"
  exit 1
fi

# Brewfile location (chezmoi applies it to home)
BREWFILE="{{ .chezmoi.homeDir }}/Brewfile"

if [[ ! -f "$BREWFILE" ]]; then
  echo "Warning: Brewfile not found at $BREWFILE"
  echo "Skipping package installation"
  exit 0
fi

echo "Installing packages from Brewfile..."
brew bundle --file="$BREWFILE" --no-lock

echo "Packages installed successfully!"
```

## Script Execution Order

Chezmoi runs scripts in this order:
1. `run_before_*` - Before applying files
2. Files are applied
3. `run_after_*` / `run_once_after_*` - After applying files

Current execution flow:
```
00-run-before/
├── run_before_00_configure_1password.sh    # Existing - 1Password setup
├── run_before_01-install-homebrew-on-macos.sh.tmpl  # NEW - Install brew
└── run_before_02-install-packages-from-brewfile.sh.tmpl  # NEW - Install packages

01-common/
├── run_once_after_00-darwin-system-defaults.sh.tmpl  # NEW - macOS settings
├── run_once_after_00-darwin-touch-id-sudo.sh.tmpl    # NEW - Touch ID
├── run_once_after_00-linux-system-setup.sh.tmpl      # NEW - Linux setup
├── run_once_after_01-mise-install.sh.tmpl            # Existing
├── run_once_after_02-install-fisher.fish.tmpl        # Existing
└── ...
```

## Why run_before for packages?

The Brewfile installs tools that other scripts depend on:
- `dockutil` needed by macOS defaults script
- `fish` needed for Fisher install
- `mise` needed for runtime setup

## Notes

- `run_before_` scripts run before files are copied
- Using hash in filename for `run_onchange_` would re-run on Brewfile changes
- `--no-lock` prevents Brewfile.lock creation

## Gist Auto-Sync

The bootstrap script is hosted as a public gist (private repo workaround). Two sync options:

**1. GitHub Action (automatic)**
- File: `.github/workflows/sync-bootstrap-gist.yml`
- Triggers on push to `main` when `home/bin/bootstrap-chezmoi.sh` changes
- Requires `GIST_PAT` secret (PAT with `gist` scope)
- Create token: https://github.com/settings/tokens/new?scopes=gist
- Add to repo: Settings → Secrets → Actions → New repository secret

**2. Manual script**
- Run: `sync-bootstrap-gist.sh` (or `~/bin/sync-bootstrap-gist.sh`)
- Requires `gh` CLI authenticated

## Success Criteria

- [ ] `bin/bootstrap-chezmoi.sh` installs Xcode CLI, Homebrew, 1Password CLI
- [ ] Homebrew installs on fresh macOS via chezmoi scripts
- [ ] Brewfile packages install before other scripts run
- [ ] Scripts work on both Intel and Apple Silicon Macs
- [ ] Linux is handled separately (exits early)
- [ ] Bootstrap script accessible via public gist URL
