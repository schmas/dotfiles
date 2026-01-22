# Project Overview & Product Development Requirements

## Project Purpose

This is a personal dotfiles repository managed by **chezmoi** for centralized shell configuration, tool setup, and development environment management across multiple machines (macOS and Linux).

**Core Goal:** Maintain consistent, reproducible development environments with minimal manual setup across desktop/laptop systems.

## Target Users & Machines

- **Primary User:** Schmas (repository owner)
- **Machine Types Supported:**
  - macOS (Darwin) - primary development machine
  - Linux (Ubuntu, Debian, Arch, RHEL variants)
  - Server environments (headless, minimal tools)
  - Remote access targets (RDP via 1Password SSH)

**Profiles:**
- `default` - General-purpose development environment
- `server` - Minimal, server-focused setup
- `ct` - Custom profile (purpose TBD)
- `aaa` - Alternative account/identity configuration

## Key Features & Capabilities

### 1. Multi-Shell Support
- **Fish** - Primary interactive shell (Fisher plugins, custom functions)
- **Zsh** - Alternative with comprehensive Sheldon plugins (27 total)
- **Bash** - Minimal compatible shell with Sheldon
- All shells share consistent aliases, abbreviations, and tool integrations

### 2. Terminal Environment
- **Prompt:** Starship (cross-shell, unified appearance)
- **Multiplexer:** Tmux (Oh my tmux! framework) + Zellij alternative
- **Terminal Emulator:** Ghostty (with custom font and theme)

### 3. Developer Tools Integration
- **Runtime Manager:** Mise (manages Node, Python, Go, Java, Rust, Bun, Maven, Cargo tools)
- **History System:** Atuin (shell history with sync, secret filtering)
- **Fuzzy Finding:** FZF with custom fifc fork (tab completion)
- **File Manager:** Yazi (with Catppuccin Mocha theme)
- **Git UI:** Lazygit (with AI commit suggestions via aicommit2)

### 4. Editor Configurations
- **IdeaVim** - IntelliJ IDEA vim emulation (357 LOC, comprehensive keymaps)
- **LunarVim** - Neovim distribution (minimal 20 LOC config)
- **Zed Editor** - Modern editor (macOS Dark2 theme, JetBrains keybindings)
- **Vim** - Basic fallback (5 LOC)

### 5. Secret Management
- **1Password Integration** - All sensitive data (tokens, SSH keys, GPG keys)
- **GPG Key Backup/Restore** - Encrypted keys stored in 1Password vault
- **SSH Key Management** - Multiple identities (GitHub, Bitbucket, Bitbucket AAA)
- **Secrets Filtering** - Atuin filters AWS keys, GitHub PAT, Slack tokens, Stripe keys

### 6. System Administration
- **Update Orchestration** - Master `upall` script coordinates OS, Brew, Mise, Rust, Chezmoi updates
- **Cross-Platform Updates** - Conditional scripts for macOS (MAS), Linux distros (apt, dnf, pacman)
- **File Descriptor Tuning** - macOS LaunchDaemon for increased file limits
- **Keyboard Customization** - Karabiner (macOS) with device-specific remapping

### 7. Code Formatting & Standards
- **Difftastic** - Structural diff tool
- **diff-so-fancy** - Git diff pager enhancement
- **EditorConfig** - Unified editor settings (2 spaces, LF line endings)
- **Prettier** - Code formatter (installed globally via Mise)

## Design Principles

### 1. Modularity
- Shell configurations split by concern (env, path, aliases, completions)
- Separate directories for different tools (Fish, Zsh, Bash, Tmux, Git, etc.)
- Naming conventions clearly indicate load order (00-installer, 10-common, 20-os, 99-aliases)

### 2. Template-Driven Configuration
- Chezmoi templating with Go text/template syntax
- Conditional logic for OS detection, profile selection, feature flags
- Secrets injected via 1Password at apply time
- Local user overrides via `*_local` template files

### 3. Cross-Platform Compatibility
- OS-specific configs in separate files (`darwin`, `linux` suffixes)
- Tool availability checks before initialization
- Fallback mechanisms when tools unavailable

### 4. Security-First
- All secrets managed by 1Password, never hardcoded
- Signed commits enforced (SSH signing on macOS, OpenPGP on others)
- GPG key protection with temporary file cleanup
- Strict file permissions (600 for private, 644 for public)

### 5. Minimal User Burden
- Auto-installation of package managers (Fisher, Sheldon)
- Pre-initialization scripts handle 1Password setup
- Post-apply scripts generate local configs and install tools
- Single chezmoi apply command bootstraps entire environment

## Architecture Overview

### Chezmoi Structure
```
home/                          # Source root (.chezmoiroot)
├── .chezmoi.yaml.tmpl        # Interactive init, selects profile
├── .chezmoiscripts/
│   ├── 00-run-before/        # Pre-apply scripts (1Password setup)
│   └── 01-common/            # Post-apply scripts (tool install)
├── private_fish/             # Fish shell config
├── private_zsh/              # Zsh shell config
├── private_bash/             # Bash shell config
├── dot_config/               # ~/.config/ files (editors, tools)
├── bin/                       # Custom scripts
├── private_dot_ssh/          # SSH config
├── private_Library/          # macOS ~/Library/
└── dot_ideavimrc, dot_vimrc  # Root dotfiles
```

### Plugin Management
- **Fish:** Fisher (13 plugins, custom fifc fork)
- **Zsh:** Sheldon (27 plugins, oh-my-zsh integration)
- **Bash:** Sheldon (6 plugins, minimal)

### Tool Stack
- **Package Managers:** Homebrew (macOS), apt/dnf/pacman (Linux)
- **Version Managers:** Mise (primary), asdf (legacy in plugins)
- **Package Managers:** Fisher (Fish), Sheldon (Zsh/Bash)
- **Secret Storage:** 1Password CLI
- **Git:** Multiple identities, SSH signing

## Success Metrics

1. **Setup Time:** New machine bootstrapped in < 5 minutes with `chezmoi init && chezmoi apply`
2. **Consistency:** Identical shell environment across Fish, Zsh, Bash
3. **Portability:** Same config works on macOS and Linux without manual changes
4. **Maintenance:** Updates propagate to all machines via chezmoi pull
5. **Security:** 100% of secrets managed by 1Password, zero hardcoded credentials

## Non-Functional Requirements

- **Storage:** ~9K LOC across 100+ config files
- **Performance:** Shell startup < 2s (Fish and Zsh)
- **Compatibility:** macOS 11+, Ubuntu 20.04+, other major Linux distros
- **Backups:** GPG keys backed up in 1Password, configs versioned in git
- **Logging:** Update scripts log to stdout (no persistent logs)

## Current State Summary

### Implemented
- Multi-shell configuration (Fish, Zsh, Bash) with unified aliases
- Chezmoi-based dotfile management with profiles
- 1Password integration for secrets
- Comprehensive tool configurations (Git, Tmux, Zellij, Atuin, Yazi, Lazygit)
- IDE configurations (IdeaVim, Zed, LunarVim)
- Update automation orchestration
- GPG key backup/restore workflow

### In Progress / Partially Implemented
- Mise integration (tools configured, auto-install in post-apply)
- Zellij vs Tmux selection (both configured, unclear which is primary)
- Atuin sync (configured but unclear if actively used across machines)

### Not Yet Implemented
- Comprehensive documentation (this project)
- Automated testing of dotfile application
- Migration paths for legacy tools (asdf → Mise)

## Unresolved Questions

1. **Atuin Sync:** Is Atuin actively syncing across machines, or is it shell-local only?
2. **Zellij vs Tmux:** Which is the primary multiplexer? Both are fully configured.
3. **Sheldon vs Fisher:** Is there a plan to unify on Sheldon for all shells, or keep Fisher for Fish?
4. **AAA Account:** What distinguishes the AAA profile? Different git identity and SSH host?
5. **Nix Integration:** Is Nix used actively (using_nix flag in config)? What's managed by Nix?
6. **Mise Configuration:** What tools are actually pinned/installed? Config.toml shows versions but are they enforced?
7. **p10k in Zsh:** Sheldon loads p10k instant prompt, but Starship is primary prompt. Is p10k still in use?
8. **Custom Forks:** What enhancements are in schmas/fifc and schmas/dircolors-neutral? Are they maintained upstream?
