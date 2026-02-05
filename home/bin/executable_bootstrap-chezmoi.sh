#!/usr/bin/env bash
# Bootstrap script for chezmoi dotfiles (private repo)
# Run: curl -fsSL https://gist.githubusercontent.com/schmas/a604b0d433a836c5af8a877a3d0f37df/raw/bootstrap-chezmoi.sh | bash
#
# Installs prerequisites before `chezmoi init --apply`:
# - Xcode CLI Tools (macOS)
# - Homebrew
# - 1Password CLI (required for secrets in templates)

set -e

echo "==> Chezmoi Bootstrap Script"
echo "    Installing prerequisites..."
echo ""

OS="$(uname -s)"

# --- Xcode CLI Tools (macOS only) ---
if [[ "$OS" == "Darwin" ]]; then
  if ! xcode-select -p &> /dev/null; then
    echo "==> Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "    Waiting for installation to complete..."
    echo "    (Click 'Install' in the dialog that appeared)"
    until xcode-select -p &> /dev/null; do
      sleep 5
    done
    echo "    Xcode CLI tools installed!"
  else
    echo "==> Xcode CLI tools: already installed"
  fi
fi

# --- Homebrew ---
if ! command -v brew &> /dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "==> Homebrew: already installed"
fi

# Add brew to current session PATH
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# --- 1Password CLI ---
if ! command -v op &> /dev/null; then
  echo "==> Installing 1Password CLI..."
  if [[ "$OS" == "Darwin" ]]; then
    brew install --cask 1password-cli
  else
    # Linux: Homebrew version
    brew install 1password-cli
  fi
else
  echo "==> 1Password CLI: already installed"
fi

echo ""
echo "=========================================="
echo "  Prerequisites installed successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "  1. Sign in to 1Password:"
echo "     op signin"
echo ""
echo "  2. Run chezmoi:"
echo "     sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- init --apply schmas"
echo ""
