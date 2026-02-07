#!/usr/bin/env bash
# Bootstrap script for chezmoi dotfiles (private repo)
# Run: curl -fsSL https://gist.githubusercontent.com/schmas/a604b0d433a836c5af8a877a3d0f37df/raw/bootstrap-chezmoi.sh | bash
#
# Installs prerequisites before `chezmoi init --apply`:
# - Xcode CLI Tools (macOS)
# - Homebrew
# - 1Password app (macOS) - required for SSH agent to access private repo
# - 1Password CLI

echo "==> Chezmoi Bootstrap Script"
echo "    Installing prerequisites..."
echo ""

OS="$(uname -s)"

# Detect brew from known paths (it may not be in PATH yet)
_find_brew() {
  if command -v brew &> /dev/null; then
    return 0
  fi
  local brew_paths=(
    /opt/homebrew/bin/brew
    /usr/local/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew
  )
  for p in "${brew_paths[@]}"; do
    if [[ -x "$p" ]]; then
      eval "$("$p" shellenv)"
      return 0
    fi
  done
  return 1
}

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
if ! _find_brew; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
  # Re-detect brew after install
  if ! _find_brew; then
    echo "!! Homebrew installation failed. Please install manually and re-run."
    exit 1
  fi
else
  echo "==> Homebrew: already installed"
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
    # Linux: install from 1Password's official package repository
    if command -v apt-get &> /dev/null; then
      curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
        sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" | \
        sudo tee /etc/apt/sources.list.d/1password.list
      sudo apt-get update && sudo apt-get install -y 1password-cli
    elif command -v dnf &> /dev/null; then
      sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
      sudo sh -c 'echo -e "[1password]\nname=1Password\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://downloads.1password.com/linux/keys/1password.asc" > /etc/yum.repos.d/1password.repo'
      sudo dnf install -y 1password-cli
    else
      echo "!! Unsupported package manager. Please install 1Password CLI manually:"
      echo "   https://developer.1password.com/docs/cli/get-started/"
      exit 1
    fi
  fi
else
  echo "==> 1Password CLI: already installed"
fi

echo ""
echo "=========================================="
echo "  Prerequisites installed successfully!"
echo "=========================================="

# --- 1Password SSH Agent Config (all vaults) ---
OP_SSH_DIR="${HOME}/.config/1Password/ssh"
OP_SSH_CFG="${OP_SSH_DIR}/agent.toml"
if [ ! -f "$OP_SSH_CFG" ]; then
  echo "==> Creating 1Password SSH agent config..."
  mkdir -p "$OP_SSH_DIR"
  chmod 700 "$OP_SSH_DIR"
  cat > "$OP_SSH_CFG" << 'TOML'
[[ssh-keys]]
vault = "Private"

[[ssh-keys]]
vault = "Dotfiles"

[[ssh-keys]]
vault = "AAA"
TOML
  chmod 600 "$OP_SSH_CFG"
else
  echo "==> 1Password SSH agent config: already exists"
fi

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
