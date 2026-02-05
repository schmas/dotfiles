# Phase 05: Add Homebrew Bootstrap Script

## Status: pending

## Overview

Create a `run_before_` script to install Homebrew before other scripts run. This ensures `brew` is available for package installation.

## Target Files

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

## Success Criteria

- [ ] Homebrew installs on fresh macOS
- [ ] Brewfile packages install before other scripts run
- [ ] Scripts work on both Intel and Apple Silicon Macs
- [ ] Linux is handled separately (exits early)
