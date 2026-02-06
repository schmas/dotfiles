# System Architecture

## Overview

This dotfiles system is built on **chezmoi** (dotfile manager) with a hierarchical configuration approach:
1. **Bootstrap** - Pre-apply setup (1Password CLI)
2. **Template Processing** - Profile & OS-specific config generation
3. **Installation Scripts** - Tool and plugin setup
4. **Runtime** - Shell initialization, tool execution

## Architecture Layers

```
┌─────────────────────────────────────────────────────┐
│         Runtime Environment (User Shells)            │
│  Fish / Zsh / Bash with plugins and custom functions │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│       Shell Initialization & Configuration           │
│  conf.d/ modules loaded → plugins → aliases          │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│    Chezmoi Apply & Install Scripts                   │
│  run_before → apply files → run_after (tool setup)  │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│   Template Rendering & Secret Injection              │
│  Variables substituted, 1Password secrets injected   │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│    Chezmoi Init (Interactive Setup)                  │
│  Profile selection, editor choice, Nix integration   │
└─────────────────────────────────────────────────────┘
```

## Chezmoi Configuration System

### Profile Selection System

**Interactive Init** (`.chezmoi.yaml.tmpl`):
```
Select profile:
1. default  ← General-purpose development
2. server   ← Minimal, server-focused
3. ct       ← Custom (purpose TBD)
4. aaa      ← Alternative account configuration
```

**Profile Variables Set:**
- `{{ .profile }}` - Selected profile name
- `{{ .is_p_default }}` - Boolean flags for each profile
- `{{ .is_p_server }}`
- `{{ .is_p_ct }}`
- `{{ .is_p_aaa }}`

**Usage in Configs:**
```go
{{ if .is_p_default }}
    # Default profile setup
{{ else if .is_p_server }}
    # Server-minimal setup
{{ end }}
```

### Operating System Detection

**Chezmoi OS Variables:**
- `{{ .chezmoi.os }}` - "darwin" (macOS) or "linux"
- `{{ .chezmoi.osRelease.id }}` - Specific distro (ubuntu, arch, fedora, etc.)

**Implementation:**
- Separate config files per OS: `20-os.darwin.*` vs `20-os.linux.*`
- Conditional blocks in templates: `{{ if eq .chezmoi.os "darwin" }}`
- Ignore rules: `.chezmoiignore` excludes non-applicable files

**OS-Specific Configurations:**

| Component | macOS | Linux |
|-----------|-------|-------|
| Package Manager | Homebrew | apt/dnf/pacman/yay |
| Shell Init | Same as Linux | Same as macOS |
| Keyboard | Karabiner | None |
| Font | Monaco/JetBrains | Same |
| Pinentry | pinentry-mac | gpg-agent |
| Multiplexer | Tmux/Zellij | Tmux/Zellij |

### Template Variable System

**Available Variables:**
```go
.chezmoi.os              // "darwin", "linux"
.chezmoi.osRelease       // OS details (id, pretty_name, etc.)
.profile                 // "default", "server", "ct", "aaa"
.using_nix               // Boolean flag for Nix integration
.is_p_default            // Profile-specific booleans
.is_p_server
.is_p_ct
.is_p_aaa
.is_p_csaa               // Legacy (always false)
```

**Custom Functions:**
```go
onepasswordRead "op://vault-name/item-id/field-name"
onepasswordItemFields "item-uuid"
```

## Shell Configuration Hierarchy

### Entry Points

Each shell has a main entry point that loads configuration modules in order:

**Fish:**
```
config.fish (sources)
  ├── conf.d/*.fish (sorted alphabetically)
  ├── conf.d/*.fish.tmpl (after templating)
  ├── functions/ (auto-load)
  └── config_local.fish (user overrides)
```

**Zsh:**
```
zshrc (sources)
  ├── zshenv (sourced first)
  ├── conf.d/*.zsh (sorted alphabetically)
  ├── conf.d/*.zsh.tmpl (after templating)
  ├── functions/ (via fpath autoload)
  └── zshrc_local (user overrides)
```

**Bash:**
```
bashrc (sources)
  ├── conf.d/*.bash (sorted alphabetically)
  ├── conf.d/*.bash.tmpl (after templating)
  └── bashrc_local (user overrides)
```

### Module Load Order

| Phase | Prefix | Purpose | Example |
|-------|--------|---------|---------|
| **1. Setup** | 00-* | Install/initialize plugin managers | `00-install_fisher.fish`, `00-load-homebrew.fish` |
| **2. Common Env** | 10-* | LANG, EDITOR, PATH, common vars | `10-common.env.fish.tmpl`, `10-colors.fish` |
| **3. OS Config** | 20-* | OS-specific env/path | `20-os.darwin.env.fish.tmpl` |
| **4. Input** | 49-* | Keybindings, input mode (Zsh only) | `49-input.zsh` |
| **5. Completions** | 50-* | Tab completion setup | `50-completions.zsh` |
| **6. Tools** | 70-* | Tool-specific init (Zellij, Starship) | `70-zellij.fish`, `70-starship-init.fish` |
| **7. Plugins** | 98-* | Plugin manager init | `98-sheldon.zsh`, `98-sheldon.bash` |
| **8. Aliases** | 99-* | All aliases (always last) | `99-aliases.zsh.tmpl` |
| **9. Late Load** | zzz-* | Fish post-load | `zzz-98-mise-config.fish` |

### Configuration Phases

```
1. BOOTSTRAP (Pre-apply)
   ├── Check 1Password CLI installed
   └── Add 1Password account if needed

2. TEMPLATE PROCESSING
   ├── Read .chezmoi.yaml.tmpl
   ├── Substitute variables
   └── Inject 1Password secrets

3. FILE INSTALLATION
   ├── Copy/create dotfiles
   ├── Apply OS-specific includes/ignores
   └── Set file permissions

4. INITIALIZATION SCRIPTS (Post-apply)
   ├── Create local config files
   ├── Install Mise tools
   ├── Install Fisher plugins
   └── Clone Neovim config

5. RUNTIME
   ├── Shell startup loads conf.d/ modules
   ├── Plugin managers initialize
   ├── Custom functions loaded
   └── Aliases available for use
```

## Plugin & Package Management Architecture

### Fisher (Fish)

**Purpose:** Fish-specific plugin manager

**Manifest:** `private_fish/fish_plugins`
```
brgmnn/fish-docker-compose
edheltzel/fisher-plugin-macos
jorgebucaran/autopair.fish
jorgebucaran/fish-bax
kidonng/zoxide.fish
meaningful-ooo/sponge
schmas/fifc
schmas/fzf.fish
```

**Auto-Installation:**
- Script: `00-install_fisher.fish`
- Runs if fisher not found
- Uses official installer script
- Plugins auto-loaded via fishfile

### Sheldon (Zsh & Bash)

**Purpose:** Unified plugin manager for Zsh and Bash

**Manifest:** `private_{zsh,bash}/etc/sheldon/plugins.toml`

**Zsh Configuration:**
```toml
[plugins.oh-my-zsh]
github = "ohmyzsh/ohmyzsh"
use = ["plugins/{1password,colorize,docker-compose,git,...}"]

[plugins.fzf-tab]
github = "Aloxaf/fzf-tab"

[plugins.zoxide]
github = "ajeetdsouv/zoxide"
```

**Bash Configuration:**
```toml
[plugins.asdf]
github = "asdf-vm/asdf"

[plugins.zoxide-loader]
inline = 'eval "$(zoxide init bash)"'
```

**Initialization:**
- Auto-installs Sheldon if missing (98-sheldon.zsh, 98-sheldon.bash)
- Sources generated sheldon.rc
- Loads all configured plugins

## Secret Management Architecture

### 1Password Integration Flow

```
┌──────────────────────────────────────────┐
│   Chezmoi Apply (runs with 1P account)   │
└───────────────┬────────────────────────────┘
                │
┌───────────────▼────────────────────────────┐
│  Template Processing with onepasswordRead   │
│  "op://Dotfiles/github-token/value"        │
└───────────────┬────────────────────────────┘
                │
┌───────────────▼────────────────────────────┐
│  1Password CLI (op) retrieves secret        │
│  Uses authenticated session (env vars)      │
└───────────────┬────────────────────────────┘
                │
┌───────────────▼────────────────────────────┐
│  Secret injected into config file          │
│  File written with restricted permissions  │
└──────────────────────────────────────────────┘
```

### Vault Structure

**1Password Vault:** Dotfiles (custom vault)

**Items Stored:**
- `github-token` - GitHub API token (email, signing key, etc.)
- `nix-flakehub` - Nix flakehub access token
- `npm-auth` - GitHub NPM registry auth
- `gpg-keys` - Encrypted GPG key backup
- SSH host configs
- Various tool tokens

**Usage Locations:**
1. Git config: `{{ onepasswordRead "op://Dotfiles/github/email" }}`
2. Shell env: `MISE_GITHUB_TOKEN` (Fish template)
3. Nix config: `{{ onepasswordRead "op://Dotfiles/nix-flakehub" }}`
4. GPG scripts: `gpg-backup`, `gpg-restore-backup`

### GPG Key Backup/Restore

```
GPG Key Backup:
  1. Export private key → /tmp/private.gpg
  2. Export public key → /tmp/public.gpg
  3. Export trust database → /tmp/trust.gpg
  4. Encrypt and upload to 1Password (gpg-upload-op)
  5. Clean temp files

GPG Key Restore:
  1. Download encrypted file from 1Password (gpg-download-op)
  2. Decrypt to temp files
  3. Import keys into ~/.gnupg/
  4. Clean temp files
```

## Tool Integration Architecture

### Tool Orchestration

```
Master Update Script (upall.tmpl)
  │
  ├─→ OS Updates (osupdate.tmpl)
  │   ├─→ macOS: softwareupdate, mas
  │   └─→ Linux: apt, dnf, pacman, yay
  │
  ├─→ Homebrew (if installed)
  │
  ├─→ Nix (if using_nix = true)
  │
  ├─→ Mise (version manager)
  │
  ├─→ Rust (rustup, cargo)
  │
  ├─→ Chezmoi (pull and apply)
  │
  └─→ Fisher / Sheldon (plugin updates)
```

### Mise Version Management

**Installed Runtimes:**
```
Languages:
  - Node.js (LTS)
  - Python (3.11)
  - Go (latest)
  - Java (Corretto 23)
  - Rust (latest)
  - Bun (latest)

Build/Development Tools:
  - Maven (3)
  - cargo-update, rust-script
  - age, direnv, sops

NPM Globals:
  - aicommit2 (AI commit generator)
  - prettier (code formatter)
  - @google/gemini-cli
  - claudekit-cli
```

**Configuration:** `dot_config/mise/config.toml`

**Installation Hook:** `run_once_after_01-mise-install.sh.tmpl`
- Installs mise if available
- Generates Fish completions
- Runs `mise install` with retry

### Git Configuration Architecture

**Dual Identity Setup:**

```
Git Identity 1 (default):
  ├─ Name/Email from 1Password
  ├─ SSH Signing (macOS)
  └─ Signing key from 1Password

Git Identity 2 (AAA):
  ├─ Alternative name/email
  ├─ OpenPGP Signing (Linux)
  └─ GPG signing key
```

**Conditional Loading:**
```
[includeIf "gitdir:**/aaa/**"]
    path = ~/.config/git/config.aaa
```

**Signing Configuration:**

macOS (main):
```
[gpg]
    format = ssh

[gpg.ssh]
    program = ~/1Password/op-ssh-sign
```

Linux (AAA):
```
[gpg]
    format = openpgp

[user]
    signingKey = <gpg-key-id>
```

## Shell Initialization Timeline

### Fish Startup Sequence

```
1. config.fish
   ├─ source 00-*.fish files
   │  └─ Fisher auto-installs if missing
   │
   ├─ source 10-*.fish files
   │  └─ Common env (LANG, EDITOR, PATH)
   │
   ├─ source 10-colors.fish
   │  └─ EZA_COLORS setup
   │
   ├─ source 20-os.*.fish files
   │  └─ macOS/Linux specific vars
   │
   ├─ Load functions/ (auto)
   │
   ├─ source 70-zellij.fish
   │  └─ Conditional Zellij launch
   │
   ├─ source 70-starship-init.fish
   │  └─ Starship prompt init
   │
   ├─ source 99-aliases.fish
   │  └─ All abbreviations loaded
   │
   ├─ source zzz-*.fish files
   │  ├─ Carapace completion
   │  ├─ FZF configuration
   │  ├─ Atuin history init
   │  └─ Mise activation
   │
   └─ source config_local.fish (if exists)
      └─ User-specific overrides
```

**Typical Startup Time:** 1-2 seconds (with plugins)

### Zsh Startup Sequence

```
1. zshenv → zshrc (startup order)
2. Load 10-common.env.zsh → common vars
3. Load 20-os.*.zsh → OS-specific
4. Load 49-input.zsh → Keybindings
5. Load 50-completions.zsh → FZF-tab setup
6. Load 98-sheldon.zsh → All Sheldon plugins
7. Load 99-aliases.zsh → Aliases
8. Load zshrc_local (if exists) → User overrides
```

**Typical Startup Time:** 1-2 seconds (with 27 plugins)

## Data Flow Architecture

### Configuration Application Flow

```
User runs: chezmoi init
    │
    ▼
Interactive prompts:
  - Profile selection
  - Editor choice
  - Nix integration
    │
    ▼
Variables collected into ~/.config/chezmoi/chezmoi.toml
    │
    ▼
User runs: chezmoi apply
    │
    ├─ Pre-apply scripts run
    │  └─ 1Password account setup
    │
    ├─ Templates processed with variables
    │  └─ Secrets injected from 1Password
    │
    ├─ Files written to home directory
    │  └─ Permissions set
    │
    └─ Post-apply scripts run
       ├─ Local config files created
       ├─ Mise tools installed
       ├─ Fisher/Sheldon plugins installed
       └─ Neovim config cloned
```

### Shell Runtime Data Flow

```
User opens shell
    │
    ├─ config.fish/zshrc sources conf.d/ modules
    │  └─ Variables set (LANG, EDITOR, PATH, etc.)
    │
    ├─ Plugin managers initialize
    │  └─ Fisher/Sheldon load and activate plugins
    │
    ├─ Functions loaded into shell namespace
    │  └─ Custom functions available
    │
    ├─ Aliases/abbreviations loaded
    │  └─ Command shortcuts available
    │
    ├─ Starship prompt initialized
    │  └─ Dynamic prompt shown
    │
    └─ Shell ready for user input
```

### Tool Integration Data Flow

```
User types command
    │
    ├─ Shell resolves alias/abbreviation
    │  └─ Executes mapped command
    │
    ├─ Tools execute (git, npm, cargo, etc.)
    │  ├─ Git: Signs commits with 1Password SSH key
    │  ├─ Lazygit: Generates AI commit via aicommit2
    │  └─ Shell history: Stored in Atuin
    │
    └─ Prompt updates with status
       └─ Starship shows git branch, exit code, etc.
```

## Performance Considerations

### Shell Startup Optimization

| Component | Optimization |
|-----------|--------------|
| Plugin loading | Lazy load via plugin managers |
| Completion caching | ZSH_CACHE_DIR for compiled completions |
| Alias resolution | Hashed aliases, no command lookup |
| Function loading | Auto-loaded only when needed (Zsh) |
| Prompt rendering | Starship (compiled binary) |

### History System Performance

| Component | Optimization |
|-----------|--------------|
| Atuin database | SQLite indexed on command, timestamp |
| History search | Fuzzy search via FZF, local database |
| Sync | Async background (optional) |
| Secrets filtering | Pre-compiled regex patterns |

### File Manager Performance

| Component | Optimization |
|-----------|--------------|
| Yazi listing | Parallel directory listing |
| Previews | Built-in preview rendering |
| Theme | Catppuccin compiled colors |

## Scalability & Maintenance

### Adding New Profiles

1. Add profile choice to `.chezmoi.yaml.tmpl`
2. Create `is_p_{name}` variable
3. Conditional logic in templates: `{{ if .is_p_{name} }}`
4. Test with `chezmoi init` and `chezmoi apply --dry-run`

### Adding New Tools

1. Create `dot_config/{tool}/` directory
2. Add configuration file
3. Document in shell config (98-sheldon.zsh, etc.)
4. Test tool initialization in post-apply script

### Updating Shell Configurations

1. Edit conf.d/ module with appropriate numeric prefix
2. Use `.tmpl` suffix if needs variable substitution
3. Test with `chezmoi apply --dry-run`
4. Manual test shell startup and aliases

## Unresolved Architectural Questions

1. **Profile clear roles:** What differentiates ct and aaa profiles? Should they be consolidated?
2. **Multiplexer selection:** Should system auto-detect if Zellij is preferred over Tmux?
3. **Atuin sync architecture:** Is Atuin syncing enabled? How are sync conflicts resolved?
4. **Sheldon plugin caching:** Are plugins cached or rebuilt on each shell start?
5. **Script ordering race conditions:** Can post-apply scripts run in parallel safely?
6. **Secret rotation:** How are 1Password secrets rotated/updated in configs?
7. **Profile drift:** How to detect when local configs diverge from repo templates?
8. **Plugin dependency management:** Are plugin versions pinned or floating?
