#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# WSL setup — run this INSIDE WSL on the Windows machine (fresh install).
# Sets up: systemd, openssh-server (pubkey+password, no idle timeout),
#          docker (auto-start), and the Windows portproxy + firewall.
# After running: from your Mac, `ssh-copy-id -p 2222 USER@<win-ip>` to add your key.
#
# Usage on a fresh WSL (no dotfiles yet) — fetch from the public gist:
#   curl -fsSL https://gist.githubusercontent.com/schmas/a604b0d433a836c5af8a877a3d0f37df/raw/wsl-ssh-setup.sh -o /tmp/wsl-ssh-setup.sh
#   bash /tmp/wsl-ssh-setup.sh
#
# This file is the source of truth; it is mirrored to the gist above by
# sync-bootstrap-gist.sh and the sync-bootstrap-gist GitHub Action.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
step() { echo -e "\n${GREEN}==>${NC} $1"; }
info() { echo -e "    ${CYAN}$1${NC}"; }
warn() { echo -e "    ${YELLOW}[!] $1${NC}"; }

# systemd is the canonical init when this dir exists. We need it for
# `systemctl enable` (ssh + docker auto-start on boot).
systemd_active() { [[ -d /run/systemd/system ]]; }

# ── 1. Ensure systemd is enabled in WSL ────────────────────────────────────
# Ubuntu 24.04 on WSL enables systemd by default, but make it explicit so
# docker/ssh can be real boot-time services. Takes effect after `wsl --shutdown`.
step "Ensuring systemd is enabled (/etc/wsl.conf)..."
WSL_CONF=/etc/wsl.conf
if ! grep -qE '^\s*systemd\s*=\s*true' "$WSL_CONF" 2>/dev/null; then
  if grep -q '\[boot\]' "$WSL_CONF" 2>/dev/null; then
    sudo sed -i '/\[boot\]/a systemd=true' "$WSL_CONF"
  else
    printf '\n[boot]\nsystemd=true\n' | sudo tee -a "$WSL_CONF" > /dev/null
  fi
  info "Enabled systemd in wsl.conf"
else
  info "systemd already enabled — skipped."
fi

# ── 2. Install openssh-server ──────────────────────────────────────────────
step "Installing openssh-server..."
sudo apt-get update -qq
sudo apt-get install -y openssh-server -qq

# ── 3. Configure sshd (auth) ───────────────────────────────────────────────
step "Configuring sshd..."
SSHD=/etc/ssh/sshd_config
sudo cp "$SSHD" "${SSHD}.bak"
sudo sed -i 's/^#*Port .*/Port 22/'                                      "$SSHD"
sudo sed -i 's/^#*PasswordAuthentication .*/PasswordAuthentication yes/' "$SSHD"
sudo sed -i 's/^#*PubkeyAuthentication .*/PubkeyAuthentication yes/'      "$SSHD"
grep -q "^ListenAddress" "$SSHD" || echo "ListenAddress 0.0.0.0" | sudo tee -a "$SSHD" > /dev/null

# ── 4. Keep idle SSH sessions alive forever ────────────────────────────────
# Server sends keepalive probes (NAT/port-proxy friendly) and never gives up,
# so an idle session is never dropped. Drop-in is read via the default
# `Include /etc/ssh/sshd_config.d/*.conf` in Ubuntu's sshd_config.
step "Disabling SSH idle timeout (keepalive drop-in)..."
sudo mkdir -p /etc/ssh/sshd_config.d
sudo tee /etc/ssh/sshd_config.d/99-keepalive.conf > /dev/null << 'EOF'
# Never drop an idle SSH session: probe every 30s, effectively never time out.
ClientAliveInterval 30
ClientAliveCountMax 1000000
TCPKeepAlive yes
EOF
info "Wrote /etc/ssh/sshd_config.d/99-keepalive.conf"

# ── 5. Prepare ~/.ssh for authorized_keys ──────────────────────────────────
step "Preparing ~/.ssh directory..."
mkdir -p ~/.ssh && chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
info "Ready — run ssh-copy-id from your Mac after this finishes."

# ── 6. Enable + start SSH ──────────────────────────────────────────────────
step "Enabling SSH service..."
if systemd_active; then
  sudo systemctl enable --now ssh
  sudo systemctl restart ssh
  info "SSH enabled on boot + running (systemd) on port 22."
else
  sudo service ssh restart
  warn "systemd not active yet. It was just enabled in wsl.conf — run"
  warn "'wsl --shutdown' on Windows, reopen WSL, then re-run this script so"
  warn "'systemctl enable ssh docker' can register boot autostart."
fi

# ── 7. Install Docker + enable on boot ─────────────────────────────────────
step "Installing Docker..."
if command -v docker &>/dev/null; then
  info "Docker already installed — skipping install."
else
  curl -fsSL https://get.docker.com | sh
fi

# Run docker without sudo. (No `newgrp` — it would spawn a blocking subshell in
# a script. The group takes effect after you re-login / `wsl --shutdown`.)
sudo groupadd -f docker
sudo usermod -aG docker "$USER"

if systemd_active; then
  sudo systemctl enable --now docker.service
  info "Docker enabled on boot + running."
else
  warn "Docker installed but systemd isn't active — it won't auto-start until"
  warn "you 'wsl --shutdown', reopen WSL, then run: sudo systemctl enable --now docker"
fi
warn "Log out/in (or 'wsl --shutdown') for docker-group membership to apply."

# ── 8. Write 1Password SSH agent.toml for Windows ─────────────────────────
# Windows 1Password SSH agent reads vault config from %LOCALAPPDATA%\1Password\config\ssh\agent.toml.
# Without this, the agent only serves keys from the Private vault.
step "Writing 1Password SSH agent.toml for Windows..."
# cmd.exe/powershell.exe return empty over SSH; find the real user dir via glob
# (excludes Default, Public, and "All Users" which are not real user profiles).
WIN_USER=$(find /mnt/c/Users -maxdepth 1 -mindepth 1 -type d \
  ! -name 'Default' ! -name 'Default User' ! -name 'Public' ! -name 'All Users' \
  -printf '%f\n' 2>/dev/null | head -1)
AGENT_TOML_DIR="/mnt/c/Users/${WIN_USER}/AppData/Local/1Password/config/ssh"
mkdir -p "$AGENT_TOML_DIR"
cat > "$AGENT_TOML_DIR/agent.toml" << 'AGENTEOF'
[[ssh-keys]]
vault = "Private"

[[ssh-keys]]
vault = "Dotfiles"

[[ssh-keys]]
vault = "AAA"
AGENTEOF
info "Written to %LOCALAPPDATA%\\1Password\\config\\ssh\\agent.toml"
info "Restart 1Password on Windows for the change to take effect."

# ── 9. Write Windows PowerShell setup script ───────────────────────────────
# Stable portproxy: Windows 2222 -> 127.0.0.1:22. WSL2 mirrors localhost into
# the VM, so 127.0.0.1 always reaches sshd and NEVER needs a per-boot refresh
# (the old dynamic-WSL-IP approach did — that scheduled task is gone).
step "Writing Windows portproxy setup script..."
PS1_PATH="/mnt/c/Windows/Temp/wsl-ssh-setup.ps1"
cat > "$PS1_PATH" << 'PSEOF'
# ── WSL SSH — Windows portproxy + firewall (run as Administrator) ──────────
$wslUser = "##WSL_USER##"

Write-Host "Configuring portproxy: Windows 0.0.0.0:2222 -> 127.0.0.1:22" -ForegroundColor Cyan

# Stable: connect to 127.0.0.1 (WSL2 localhost mirror). Persists across reboots.
netsh interface portproxy delete v4tov4 listenport=2222 listenaddress=0.0.0.0 2>$null
netsh interface portproxy add    v4tov4 listenport=2222 listenaddress=0.0.0.0 connectport=22 connectaddress=127.0.0.1

# Firewall: allow inbound 2222.
netsh advfirewall firewall delete rule name="WSL SSH" 2>$null
netsh advfirewall firewall add    rule name="WSL SSH" dir=in action=allow protocol=TCP localport=2222

# Windows LAN IP (for the Mac's ssh config HostName).
$winIp = (Get-NetIPAddress -AddressFamily IPv4 |
  Where-Object { $_.InterfaceAlias -notlike '*Loopback*' -and
                 $_.InterfaceAlias -notlike '*WSL*'      -and
                 $_.IPAddress      -notlike '169.*' } |
  Select-Object -First 1).IPAddress

Write-Host ""
Write-Host "Done! Current portproxy table:" -ForegroundColor Green
netsh interface portproxy show all
Write-Host ""
Write-Host "Add this to ~/.ssh/config on your Mac:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Host win-dev"
Write-Host "  HostName $winIp"
Write-Host "  Port 2222"
Write-Host "  User $wslUser"
Write-Host "  ServerAliveInterval 30"
Write-Host "  ServerAliveCountMax 1000000"
Write-Host "  TCPKeepAlive yes"
Write-Host "  LocalForward 5432 localhost:5432"
Write-Host "  LocalForward 6379 localhost:6379"
Write-Host "  LocalForward 4566 localhost:4566"
Write-Host ""
Write-Host "Then from Mac:  ssh-copy-id win-dev   (once)   ->   ssh win-dev" -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to close"
PSEOF

sed -i "s|##WSL_USER##|$USER|g" "$PS1_PATH"
info "Written to C:\\Windows\\Temp\\wsl-ssh-setup.ps1"

# ── 9. Launch Windows PowerShell as admin ──────────────────────────────────
step "Launching Windows PowerShell (Admin)..."
powershell.exe -NoProfile -Command \
  "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit','-ExecutionPolicy','Bypass','-File','C:\Windows\Temp\wsl-ssh-setup.ps1'" \
  2>/dev/null || warn "Auto-launch failed — run the script manually (see below)."

echo ""
echo -e "${GREEN}✓ WSL side complete.${NC}"
echo ""
echo "  A PowerShell (Admin) window should have opened on Windows. If not,"
echo "  open PowerShell as Administrator and run:"
echo -e "  ${YELLOW}powershell -ExecutionPolicy Bypass -File C:\\Windows\\Temp\\wsl-ssh-setup.ps1${NC}"
echo ""
echo "  From your Mac:"
echo -e "  ${CYAN}ssh-copy-id -p 2222 $USER@<windows-lan-ip>${NC}   (once, to install your key)"
echo -e "  ${CYAN}ssh win-dev${NC}"
