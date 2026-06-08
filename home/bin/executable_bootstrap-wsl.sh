#!/usr/bin/env bash
#
# Bootstrap these chezmoi dotfiles on WSL (Ubuntu/Debian).
#
# 1Password runs as the Windows desktop app; the Linux op binary cannot reach
# it, so secrets, SSH auth, and commit signing all go through Windows via WSL
# interop (op.exe / ssh.exe / op-ssh-sign). This script installs the
# prerequisites, drops the op bridge that chezmoi calls during apply, then runs
# chezmoi init --apply.
#
# Usage (inside WSL) — download-then-run so chezmoi's profile prompt stays interactive:
#   curl -fsSL https://gist.githubusercontent.com/schmas/a604b0d433a836c5af8a877a3d0f37df/raw/bootstrap-wsl.sh -o /tmp/bootstrap-wsl.sh
#   bash /tmp/bootstrap-wsl.sh
#
# This file is the source of truth; it is mirrored to the public gist above by
# sync-bootstrap-gist.sh and the sync-bootstrap-gist GitHub Action.
#
# Prerequisites on the WINDOWS side (do these first):
#   1. Install the 1Password desktop app and the CLI:  winget install 1Password.CLI
#   2. 1Password app > Settings > Developer  > enable "Integrate with 1Password CLI"
#   3. 1Password app > Settings > Developer  > enable "Use the SSH agent"
#   4. 1Password app > Settings > Security   > enable Windows Hello

set -euo pipefail

REPO="https://github.com/schmas/dotfiles.git"   # HTTPS — no GitHub SSH key exists yet
BIN_DIR="$HOME/.local/bin"

c_blue=$'\033[1;34m'; c_red=$'\033[1;31m'; c_yellow=$'\033[1;33m'; c_reset=$'\033[0m'
log()  { printf '\n%s>> %s%s\n' "$c_blue"  "$*" "$c_reset"; }
warn() { printf '\n%s!! %s%s\n' "$c_yellow" "$*" "$c_reset"; }
die()  { printf '\n%s!! %s%s\n' "$c_red"  "$*" "$c_reset" >&2; exit 1; }

# ---------------------------------------------------------------------------
# 0. Sanity checks
# ---------------------------------------------------------------------------
grep -qi microsoft /proc/version 2>/dev/null \
  || die "Not running under WSL. On native Linux just use: chezmoi init --apply $REPO"
command -v apt >/dev/null 2>&1 \
  || die "apt not found. This bootstrap targets Ubuntu/Debian WSL."

# ---------------------------------------------------------------------------
# 1. APT prerequisites (sudo prompts unless you set up passwordless sudo)
# ---------------------------------------------------------------------------
log "Installing apt prerequisites..."
sudo apt update
sudo apt install -y curl git gnupg build-essential ca-certificates

# ---------------------------------------------------------------------------
# 2. Drop the op bridge (chezmoi calls this to read 1Password secrets)
# ---------------------------------------------------------------------------
# Resolves op.exe from PATH first, then the WinGet package dir, then Program
# Files. Forwards OP_* env vars into the Windows process. When stdout is a TTY
# (interactive use) it execs through transparently; when captured (chezmoi) it
# strips the carriage returns op.exe appends, which would otherwise corrupt
# rendered secrets such as the SSH signing key.
mkdir -p "$BIN_DIR"

cat > "$BIN_DIR/op" <<'BRIDGE'
#!/usr/bin/env bash
# 1Password CLI bridge: Linux op -> Windows op.exe (WSL interop).
set -uo pipefail

find_op_exe() {
  local p
  p="$(command -v op.exe 2>/dev/null || true)"; [ -n "$p" ] && { printf '%s' "$p"; return; }
  # Glob WinGet package dirs across all Windows users, then Program Files.
  # No cmd.exe dependency, so this works even over SSH where the Windows PATH
  # is not appended to the WSL login shell.
  for p in /mnt/c/Users/*/AppData/Local/Microsoft/WinGet/Packages/AgileBits.1Password.CLI*/op.exe \
           "/mnt/c/Program Files/1Password CLI/op.exe" \
           "/mnt/c/Program Files (x86)/1Password CLI/op.exe"; do
    [ -x "$p" ] && { printf '%s' "$p"; return; }
  done
}

OP_EXE="$(find_op_exe)"
[ -n "$OP_EXE" ] && [ -x "$OP_EXE" ] \
  || { echo "op bridge: op.exe not found. Install on Windows: winget install 1Password.CLI" >&2; exit 1; }

# Forward any OP_* vars into the Windows process
op_vars="$(env | sed -n 's/^\(OP_[A-Za-z0-9_]*\)=.*/\1/p' | paste -sd: -)"
[ -n "$op_vars" ] && export WSLENV="${WSLENV:-}:${op_vars}"

if [ -t 1 ]; then
  exec "$OP_EXE" "$@"                 # interactive: transparent passthrough
else
  "$OP_EXE" "$@" | tr -d '\r'         # captured (chezmoi): strip CR
  exit "${PIPESTATUS[0]}"
fi
BRIDGE
chmod +x "$BIN_DIR/op"

# op-ssh-sign bridge for git commit signing on WSL
cat > "$BIN_DIR/op-ssh-sign" <<'SIGNER'
#!/usr/bin/env bash
# git SSH commit signing bridge: -> Windows op-ssh-sign (WSL path aware first).
set -uo pipefail

find_signer() {
  local p
  for p in op-ssh-sign-wsl.exe op-ssh-sign.exe; do
    p="$(command -v "$p" 2>/dev/null || true)"; [ -n "$p" ] && { printf '%s' "$p"; return; }
  done
  # op-ssh-sign ships with the 1Password desktop app and/or the CLI package.
  # Glob both across all Windows users (WSL-path-aware variant preferred).
  for p in /mnt/c/Users/*/AppData/Local/Microsoft/WinGet/Packages/AgileBits.1Password.CLI*/op-ssh-sign-wsl.exe \
           /mnt/c/Users/*/AppData/Local/Microsoft/WinGet/Packages/AgileBits.1Password.CLI*/op-ssh-sign.exe \
           /mnt/c/Users/*/AppData/Local/1Password/app/*/op-ssh-sign-wsl.exe \
           /mnt/c/Users/*/AppData/Local/1Password/app/*/op-ssh-sign.exe \
           "/mnt/c/Program Files/1Password CLI/op-ssh-sign.exe"; do
    [ -x "$p" ] && { printf '%s' "$p"; return; }
  done
}

SIGNER_EXE="$(find_signer)"
[ -n "$SIGNER_EXE" ] && [ -x "$SIGNER_EXE" ] \
  || { echo "op-ssh-sign bridge: signer not found. Install on Windows: winget install 1Password.CLI" >&2; exit 1; }
exec "$SIGNER_EXE" "$@"
SIGNER
chmod +x "$BIN_DIR/op-ssh-sign"

export PATH="$BIN_DIR:$PATH"

# ---------------------------------------------------------------------------
# 3. Verify the Windows 1Password integration is reachable
# ---------------------------------------------------------------------------
log "Verifying op bridge can reach 1Password (Windows Hello may pop up)..."
if ! "$BIN_DIR/op" vault list >/dev/null 2>&1; then
  die "op bridge cannot reach 1Password. On Windows: install 'winget install 1Password.CLI', then in the desktop app enable Settings > Developer > 'Integrate with 1Password CLI' + Windows Hello. Re-run this script."
fi
log "1Password integration OK."

# ---------------------------------------------------------------------------
# 4. chezmoi
# ---------------------------------------------------------------------------
if ! command -v chezmoi >/dev/null 2>&1 && [ ! -x "$BIN_DIR/chezmoi" ]; then
  log "Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$BIN_DIR"
fi

# ---------------------------------------------------------------------------
# 5. Apply
# ---------------------------------------------------------------------------
log "Running chezmoi init --apply (answer the profile / editor prompts)..."
"${BIN_DIR}/chezmoi" init --apply "$REPO"

log "Done."
cat <<EOF

Next steps (a few logins are interactive):
  - Open a new shell (fish is now the default).
  - gh auth login            # GitHub CLI
  - atuin login && atuin sync -f
  - Commit signing: if commits fail, open the key in the 1Password app and use
    "Configure Commit Signing" > check the WSL box to confirm the signer path.
EOF
