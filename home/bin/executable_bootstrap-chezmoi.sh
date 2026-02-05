#!/usr/bin/env bash
# Bootstrap script for chezmoi dotfiles (private repo)
# Run: curl -fsSL https://gist.githubusercontent.com/schmas/a604b0d433a836c5af8a877a3d0f37df/raw/bootstrap-chezmoi.sh | bash
#
# Installs prerequisites before `chezmoi init --apply`:
# - Xcode CLI Tools (macOS)
# - Homebrew
# - 1Password app (macOS) - required for SSH agent to access private repo
# - 1Password CLI

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

# --- macOS: 1Password App (for SSH agent) ---
if [[ "$OS" == "Darwin" ]]; then
  if [[ ! -d "/Applications/1Password.app" ]]; then
    echo "==> Installing 1Password app..."
    brew install --cask 1password
  else
    echo "==> 1Password app: already installed"
  fi
fi

# --- 1Password CLI ---
if ! command -v op &> /dev/null; then
  echo "==> Installing 1Password CLI..."
  if [[ "$OS" == "Darwin" ]]; then
    brew install --cask 1password-cli
  else
    brew install 1password-cli
  fi
else
  echo "==> 1Password CLI: already installed"
fi

echo ""
echo "=========================================="
echo "  Prerequisites installed successfully!"
echo "=========================================="

if [[ "$OS" == "Darwin" ]]; then
  echo ""
  echo "ACTION REQUIRED: Configure 1Password SSH Agent"
  echo ""
  echo "  1. Open 1Password app (launching now...)"
  open -a "1Password"
  echo ""
  echo "  2. Sign in to your 1Password account"
  echo ""
  echo "  3. Enable SSH Agent:"
  echo "     Settings → Developer → Enable SSH Agent"
  echo ""
  read -p "Press ENTER when 1Password SSH Agent is configured..."

  echo ""
  echo "Verifying SSH access to GitHub..."
  if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "✓ SSH authentication successful!"
  else
    echo "⚠ SSH test returned unexpected result (this may be OK)"
    echo "  Continuing anyway - chezmoi will fail if SSH isn't working"
  fi

  echo ""
  echo "==> Installing chezmoi and applying dotfiles..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply schmas
else
  echo ""
  echo "Next steps (Linux):"
  echo "  1. Sign in to 1Password: op signin"
  echo "  2. Run: sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- init --apply schmas"
  echo ""
fi
