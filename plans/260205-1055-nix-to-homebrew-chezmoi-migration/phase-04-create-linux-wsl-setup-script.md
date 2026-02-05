# Phase 04: Create Linux/WSL Setup Script

## Status: pending

## Overview

Create chezmoi script for Linux and WSL package installation. Strategy:
1. Use native package manager for system packages
2. Use Homebrew on Linux for CLI tools (consistent versions with macOS)
3. Use mise for dev runtimes (already in place)

## Package Strategy

### Via Native Package Manager (apt/dnf)
Essential system packages that work better from distro repos:
- build-essential, git, curl, wget (bootstrap)
- fish (set as default shell)

### Via Homebrew on Linux
CLI tools for version consistency with macOS:
- All tools from Brewfile (bat, eza, fd, fzf, ripgrep, etc.)
- Homebrew handles dependencies cleanly

### Via mise
Dev runtimes (already configured):
- Node.js, Python, Ruby, Go, Rust

## Target File

Create `home/.chezmoiscripts/01-common/run_once_after_00-linux-system-setup.sh.tmpl`:

```bash
#!/usr/bin/env bash
{{ if eq .chezmoi.os "darwin" }}
# Skip on macOS
exit 0
{{ end }}

set -e

echo "Setting up Linux environment..."

# =============================================================================
# Detect package manager
# =============================================================================

if command -v apt &> /dev/null; then
  PKG_MGR="apt"
  INSTALL="sudo apt install -y"
  UPDATE="sudo apt update"
elif command -v dnf &> /dev/null; then
  PKG_MGR="dnf"
  INSTALL="sudo dnf install -y"
  UPDATE="sudo dnf check-update || true"
elif command -v pacman &> /dev/null; then
  PKG_MGR="pacman"
  INSTALL="sudo pacman -S --noconfirm"
  UPDATE="sudo pacman -Sy"
else
  echo "Unsupported package manager"
  exit 1
fi

echo "Detected package manager: $PKG_MGR"

# =============================================================================
# Install essential system packages
# =============================================================================

echo "Installing essential packages..."
$UPDATE

case $PKG_MGR in
  apt)
    $INSTALL \
      build-essential \
      curl \
      wget \
      git \
      fish \
      procps \
      file
    ;;
  dnf)
    $INSTALL \
      @development-tools \
      curl \
      wget \
      git \
      fish \
      procps-ng \
      file
    ;;
  pacman)
    $INSTALL \
      base-devel \
      curl \
      wget \
      git \
      fish \
      procps-ng \
      file
    ;;
esac

# =============================================================================
# Set fish as default shell
# =============================================================================

FISH_PATH=$(which fish)
if [[ -n "$FISH_PATH" ]]; then
  if ! grep -q "$FISH_PATH" /etc/shells; then
    echo "Adding fish to /etc/shells..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells
  fi

  if [[ "$SHELL" != "$FISH_PATH" ]]; then
    echo "Setting fish as default shell..."
    chsh -s "$FISH_PATH"
  fi
fi

# =============================================================================
# Install Homebrew (Linux)
# =============================================================================

if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew for Linux..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add to current session
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# =============================================================================
# Install packages via Homebrew
# =============================================================================

BREWFILE="$HOME/Brewfile"
if [[ -f "$BREWFILE" ]]; then
  echo "Installing packages from Brewfile..."
  # On Linux, casks are ignored automatically
  brew bundle --file="$BREWFILE" --no-lock
else
  echo "Warning: Brewfile not found at $BREWFILE"
fi

# =============================================================================
# WSL-specific setup
# =============================================================================

if grep -qi microsoft /proc/version 2>/dev/null; then
  echo "WSL detected, applying WSL-specific configuration..."

  # Create symlink to Windows home if it exists
  WIN_HOME="/mnt/c/Users/$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')"
  if [[ -d "$WIN_HOME" ]] && [[ ! -L "$HOME/winhome" ]]; then
    ln -sf "$WIN_HOME" "$HOME/winhome"
    echo "Created symlink: ~/winhome -> $WIN_HOME"
  fi

  # Configure Git to use Windows credential manager
  git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe" 2>/dev/null || true
fi

echo "Linux setup complete!"
```

## Notes

- Script runs only on Linux (template guard)
- Homebrew on Linux installs to `/home/linuxbrew/.linuxbrew`
- Casks in Brewfile are automatically ignored on Linux
- WSL detection via `/proc/version` check
- Fish shell set as default

## Dependencies

- Internet connection for Homebrew install
- sudo access for system packages

## Success Criteria

- [ ] Script created at correct location
- [ ] Script only runs on Linux
- [ ] Package manager detection works (apt/dnf/pacman)
- [ ] Homebrew installs on Linux
- [ ] Brewfile packages install correctly
- [ ] WSL-specific setup runs when applicable
