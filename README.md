# Dotfiles

![License](https://img.shields.io/github/license/schmas/dotfiles)
![Last Commit](https://img.shields.io/github/last-commit/schmas/dotfiles)

Personal dotfiles repository managed by **chezmoi** for cross-platform shell configuration, development tools, and system setup across macOS and Linux machines.

## Quick Links

- **Getting Started:** [Deployment & Installation Guide](./docs/deployment-guide.md)
- **Project Overview:** [Project Overview & PDR](./docs/project-overview-pdr.md)
- **Architecture:** [System Architecture](./docs/system-architecture.md)
- **Code Standards:** [Development Guidelines](./docs/code-standards.md)
- **Roadmap:** [Project Roadmap & Status](./docs/project-roadmap.md)
- **Codebase:** [Codebase Summary](./docs/codebase-summary.md)
- **Aliases & Functions:** [Shell Reference](SHELL-REFERENCE.md)

## What are Dotfiles?

Dotfiles are configuration files in Unix-like systems that begin with a dot (.) and control the behavior of various applications and system components. This repository maintains:

- **Multi-shell configuration** (Fish, Zsh, Bash) with unified aliases
- **Terminal environment** (Starship prompt, Tmux, Zellij multiplexers)
- **Developer tools** (Git with SSH signing, Atuin history, FZF completions)
- **Editor configurations** (IdeaVim, Zed, LunarVim, Vim)
- **1Password integration** for secure secrets management
- **Chezmoi profile system** for per-machine customization

## Repository Structure

```
home/                          # Chezmoi source root
├── private_fish/             # Fish shell configuration
├── private_zsh/              # Zsh shell configuration
├── private_bash/             # Bash shell configuration
├── dot_config/               # Application configs
│   ├── git/, tmux/, zellij/, atuin/, yazi/, lazygit/
│   ├── starship.toml, mise/, karabiner/, editors/
│   └── ghostty/, wezterm/, readline, ssh, gpg-agent configs
├── bin/                       # Custom utility scripts
├── .chezmoiscripts/           # Installation scripts
│   ├── 00-run-before/        # Pre-apply setup (1Password)
│   └── 01-common/            # Post-apply setup (tools)
└── .chezmoiignore            # OS-specific excludes
```

For detailed structure, see [Codebase Summary](./docs/codebase-summary.md).

## Getting Started (5 minutes)

### Fresh Machine Install (macOS)

```bash
# Single command - script will pause for 1Password SSH setup, then continue
curl -fsSL https://gist.githubusercontent.com/schmas/a604b0d433a836c5af8a877a3d0f37df/raw/bootstrap-chezmoi.sh | bash
```

The script will:
1. Install Xcode CLI tools, Homebrew, 1Password app + CLI
2. Open 1Password and wait for you to enable SSH Agent (Settings → Developer)
3. Verify SSH access to GitHub
4. Run `chezmoi init --apply` automatically

### Fresh Machine Install (WSL / Ubuntu)

1Password runs as the Windows desktop app — the Linux `op` binary can't reach it,
so secrets, git SSH auth, and commit signing all bridge to Windows via WSL interop
(`op.exe` / `ssh.exe` / `op-ssh-sign`).

On **Windows** first (PowerShell as Administrator):

```powershell
# Install WSL kernel (no distro yet)
wsl --install --no-distribution

# Reboot, then install Ubuntu 24.04
wsl --install -d Ubuntu-24.04

# Install 1Password CLI
winget install 1Password.CLI
```

Then in the 1Password desktop app: **Settings → Developer** → enable *Integrate with
1Password CLI* and *Use the SSH agent*; **Settings → Security** → enable Windows Hello.

> **Vault access:** The CLI only sees vaults you authorize. If chezmoi reads from a non-default vault (e.g. `Dotfiles`), open that vault in the desktop app, click its name → **Manage** and confirm CLI access is on. Verify with `op vault list` in WSL — all required vaults must appear before running the bootstrap. 1Password must also be **unlocked** whenever chezmoi runs.

In **WSL** (download-then-run so the profile prompt stays interactive):

```bash
curl -fsSL https://gist.githubusercontent.com/schmas/a604b0d433a836c5af8a877a3d0f37df/raw/bootstrap-wsl.sh -o /tmp/bootstrap-wsl.sh
bash /tmp/bootstrap-wsl.sh
```

The script will:
1. Install apt prerequisites (curl, git, gnupg, build-essential)
2. Drop the `op` / `op-ssh-sign` bridges into `~/.local/bin`
3. Verify 1Password is reachable (Windows Hello prompt)
4. Install chezmoi and run `chezmoi init --apply`

> Tip: to avoid repeated sudo prompts during apply, set up temporary passwordless
> sudo first (`/etc/sudoers.d/`) and remove it afterward.

### WSL SSH Setup (run inside WSL on Windows host)

Configures openssh-server, systemd, Docker, and the Windows portproxy so you can `ssh win-dev` from your Mac.

```bash
curl -fsSL https://gist.githubusercontent.com/schmas/a604b0d433a836c5af8a877a3d0f37df/raw/wsl-ssh-setup.sh -o /tmp/wsl-ssh-setup.sh
bash /tmp/wsl-ssh-setup.sh
```

The script will:
1. Enable systemd in `/etc/wsl.conf`
2. Install and configure `openssh-server` (pubkey + password auth, no idle timeout)
3. Install Docker and enable both services on boot
4. Write and launch a PowerShell (Admin) script that sets up `netsh portproxy` (Windows 2222 → WSL 22) and a firewall rule

After it finishes, run `ssh-copy-id -p 2222 <user>@<windows-lan-ip>` once from your Mac to install your key.

### Existing Machine (chezmoi already installed)

```bash
chezmoi init --apply https://github.com/schmas/dotfiles.git
```

### Initial Setup Prompts

During `chezmoi init`, you'll answer prompts owned by `home/.chezmoi.yaml.tmpl`:
1. **Profile** - default (full dev setup) or server (minimal)
2. **NIX-CONFIG** - whether this machine also uses the (deprecated) nix-config
3. **Editor** - nvim (default), zed, code, or none

### What Gets Installed

Automatic scripts handle:
- **Homebrew packages** - CLI tools and macOS apps via `~/.config/etc/Brewfile`
- **macOS defaults** - System preferences, Dock configuration, Touch ID sudo
- **Linux setup** - Native packages, Homebrew on Linux, WSL integration
- **1Password CLI** - Setup and account configuration
- **Mise** - Dev runtime installation (Node, Python, etc.)
- **Shell plugins** - Fisher (Fish), Sheldon (Zsh/Bash)

For detailed setup instructions, see **[Deployment & Installation Guide](./docs/deployment-guide.md)**

## Key Features

- **Multi-shell support** - Fish, Zsh, Bash with consistent aliases (~230 abbreviations)
- **1Password integration** - Secure secrets for git signing, SSH, GPG, API tokens
- **Profile system** - Specialized setups (default, server, ct, aaa)
- **Modern tools** - Starship prompt, Tmux, Atuin history, FZF completions, Yazi file manager
- **Version management** - Mise for Node, Python, Go, Java, Rust, and more
- **Editor setup** - IdeaVim, Zed, LunarVim configurations pre-configured
- **Cross-platform** - Works on macOS and Linux with OS-specific configurations

## Documentation

Comprehensive documentation organized by topic:

| Document | Purpose |
|----------|---------|
| [Deployment Guide](./docs/deployment-guide.md) | Installation, setup, and troubleshooting |
| [Project Overview](./docs/project-overview-pdr.md) | Goals, features, design principles, PDR |
| [Code Standards](./docs/code-standards.md) | Naming conventions, templates, patterns |
| [System Architecture](./docs/system-architecture.md) | Technical design, data flow, plugins |
| [Project Roadmap](./docs/project-roadmap.md) | Current status, planned improvements |
| [Codebase Summary](./docs/codebase-summary.md) | Navigation map: concern → location |
| [Shell Reference](SHELL-REFERENCE.md) | All aliases, functions, abbreviations |
| [Shortcuts Reference](SHORTCUTS-REFERENCE.md) | Terminal keyboard shortcuts by tool |

## Customization & Maintenance

### Local Customizations (Don't Edit Repo)

Each shell supports local overrides without modifying repo files:

```bash
# Fish
~/.config/fish/config_local.fish

# Zsh
~/.config/zsh/zshrc_local

# Bash
~/.config/bash/bashrc_local
```

### Template System

Files with `.tmpl` suffix use Go text/template syntax:
- Variables: `{{ .profile }}`, `{{ .chezmoi.os }}`
- Secrets: `{{ onepasswordRead "op://vault/item/field" }}`
- Conditions: `{{ if eq .chezmoi.os "darwin" }} ... {{ end }}`

### Updating Configuration

```bash
# Preview changes
chezmoi status

# Pull latest changes
chezmoi pull

# Apply updates
chezmoi apply

# Update all tools
upall
```

## Unresolved Questions

See **[Project Roadmap](./docs/project-roadmap.md)** for:
- Atuin sync status across machines
- Zellij vs Tmux multiplexer selection
- Profile purposes (ct, aaa clarification)
- Custom plugin fork maintenance strategy

## Related Repositories

- **[nvim_lazy](https://github.com/schmas/nvim_lazy)** - Neovim lazy.nvim configuration
- **[fifc](https://github.com/schmas/fifc)** - Custom Fish tab completion fork
- **[dircolors-neutral](https://github.com/schmas/dircolors-neutral)** - Custom ls colors
- **[nix-config](https://github.com/schmas/nix-config)** - ⚠️ Deprecated (migrated to Homebrew)

## License

This project is open source and available under the [MIT License](LICENSE).
