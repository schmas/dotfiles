# Codebase Summary

## Repository Overview

**Repository:** Personal Dotfiles (chezmoi-based)
**Size:** ~9K LOC across 100+ files
**Primary Language:** Shell (Fish, Zsh, Bash) + Config files (TOML, JSON, KDL)
**Management Tool:** Chezmoi (dotfile manager)
**Version Control:** Git

## Directory Structure

```
/Users/schmas/.local/share/chezmoi/
├── home/                                 # Chezmoi source root
│   ├── .chezmoi.yaml.tmpl               # Interactive init config (profiles, settings)
│   ├── .chezmoiexternal.toml            # External dependencies (commented)
│   ├── .chezmoiignore                   # Files to exclude per OS
│   ├── .chezmoiremove                   # Files to remove (empty)
│   ├── .chezmoiscripts/
│   │   ├── 00-run-before/               # Pre-apply scripts
│   │   │   └── run_before_00_configure_1password.sh
│   │   └── 01-common/                   # Post-apply scripts
│   │       ├── run_after_00-local-files.sh.tmpl
│   │       ├── run_once_after_01-mise-install.sh.tmpl
│   │       ├── run_once_after_02-install-fisher.fish.tmpl
│   │       ├── run_once_after_02.1-some-fish-setup.fish.tmpl
│   │       └── run_once_after_05-nvim_lazy-install.sh.tmpl
│   │
│   ├── private_fish/                    # Fish shell config
│   │   ├── config.fish                  # Main entry point
│   │   ├── config_local.template.fish   # User local overrides
│   │   ├── fish_plugins                 # Fisher plugin manifest
│   │   ├── conf.d/                      # Modular configs (14 files)
│   │   ├── functions/                   # Custom functions (13 files)
│   │   └── completions/                 # Shell completions
│   │
│   ├── private_zsh/                     # Zsh shell config
│   │   ├── zshrc                        # Main entry point
│   │   ├── zshenv                       # Env-only init
│   │   ├── zshrc_local.template         # User local overrides
│   │   ├── conf.d/                      # Modular configs (10 files)
│   │   ├── functions/                   # Shell functions (8 files)
│   │   └── etc/sheldon/plugins.toml     # Sheldon plugin manifest (27 plugins)
│   │
│   ├── private_bash/                    # Bash shell config
│   │   ├── bashrc                       # Main entry point
│   │   ├── bashrc_local.template        # User local overrides
│   │   ├── conf.d/                      # Modular configs (7 files)
│   │   ├── functions/                   # Minimal (empty)
│   │   └── etc/sheldon/plugins.toml     # Sheldon manifest (6 plugins)
│   │
│   ├── dot_config/
│   │   ├── fish/                        # Fish shell config (full path)
│   │   ├── zsh/                         # Zsh config (full path)
│   │   ├── bash/                        # Bash config (full path)
│   │   ├── tmux/                        # Tmux config (Oh my tmux!)
│   │   │   ├── tmux.conf               # Base config (1600 LOC)
│   │   │   ├── tmux.conf.local         # Custom overrides
│   │   │   └── tmux.conf.tmp           # Backup (unused)
│   │   ├── git/                         # Git configuration
│   │   │   ├── config.main.tmpl        # Primary config (SSH signing)
│   │   │   ├── config.aaa.tmpl         # AAA account config (OpenPGP)
│   │   │   ├── aliases.tmpl            # 40+ git aliases
│   │   │   └── ignore                  # Global gitignore
│   │   ├── zellij/                      # Zellij multiplexer (366 LOC)
│   │   ├── atuin/                       # Shell history (270 LOC, mostly defaults)
│   │   ├── yazi/                        # File manager
│   │   ├── lazygit/                     # Git UI (39 LOC, custom commands)
│   │   ├── lvim/                        # LunarVim (20 LOC)
│   │   ├── zed/                         # Zed editor (48 LOC)
│   │   ├── starship.toml                # Prompt config (184 LOC)
│   │   ├── ghostty/                     # Terminal emulator (39 LOC)
│   │   ├── mise/                        # Version manager (23 LOC)
│   │   ├── nix/                         # Nix config (templated)
│   │   ├── karabiner/                   # Keyboard customization (125 LOC, macOS)
│   │   └── etc/                         # Other configs (ssh, gpg, npm, launchd)
│   │
│   ├── bin/                             # Custom scripts
│   │   ├── brewup                       # Homebrew updater (Fish)
│   │   ├── gpg-backup                   # GPG backup utility
│   │   ├── gpg-restore-backup           # GPG restore utility
│   │   ├── gpg-{upload,download}-op     # 1Password GPG integration
│   │   ├── setup-atuin                  # Atuin setup script
│   │   ├── setup-dotfiles-repo-url      # Git remote converter
│   │   ├── fix-zsh-insecure             # Zsh permission fixer
│   │   ├── show-zsh-startup-files-order # Debug utility
│   │   ├── upall.tmpl                   # Master update orchestrator
│   │   └── osupdate.tmpl                # OS-specific updates
│   │
│   ├── private_dot_ssh/                 # SSH config
│   │   └── private_ssh_config.template.tmpl
│   │
│   ├── private_Library/                 # macOS ~/Library/ files
│   │
│   ├── dot_ideavimrc                    # IdeaVim config (357 LOC)
│   ├── dot_vimrc                        # Vim config (5 LOC)
│   ├── dot_inputrc                      # Readline config (69 LOC)
│   └── ...
│
├── docs/                                # Documentation (this directory)
├── home/.cursor                         # Cursor IDE settings
├── .git/                                # Git repository
├── .idea/                               # IntelliJ settings
├── plans/                               # Planning and reports
└── README.md, SHELL-REFERENCE.md        # Root documentation
```

## File Organization Patterns

### Naming Conventions

| Pattern | Meaning | Example |
|---------|---------|---------|
| `dot_*` | Dotfile (. prefix) | `dot_ideavimrc` → `~/.ideavimrc` |
| `private_*` | Private/sensitive | `private_fish/` → `~/.config/fish/` |
| `*.tmpl` | Chezmoi template | `config.main.tmpl` → apply-time substitution |
| `*_local*` | User-specific override | `config_local.fish` → user edits here |
| `executable_*` | Executable script | `executable_dot_editorconfig` → script |
| `00-`, `10-`, etc. | Load order | `10-common.env.fish` loads before `99-aliases` |

### Shell Configuration Modules

Each shell (Fish, Zsh, Bash) follows this pattern:

```
private_{shell}/
├── config.{fish,rc}           # Entry point, sources conf.d/
├── {shell}rc_local.template   # User local config (not in repo)
├── {shell}_plugins            # Plugin manifest (Fish/Zsh/Bash)
├── conf.d/
│   ├── 00-*.{fish,zsh,bash}   # Package manager installation
│   ├── 10-*.tmpl              # Common env vars (LANG, EDITOR, PATH)
│   ├── 20-os.{darwin,linux}.* # OS-specific vars
│   ├── 49-*.zsh               # Input/keybindings (zsh-specific)
│   ├── 50-*.{zsh,bash}        # Completions
│   ├── 70-*.fish              # Late-load tools (Fish-specific)
│   ├── 98-*.{zsh,bash,fish}   # Plugin manager + Starship
│   ├── 99-*.tmpl              # Aliases (always last)
│   └── zzz-*.fish             # Fish late-loading (Carapace, FZF, Mise)
├── functions/
│   └── *.{fish,zsh,sh}        # Custom shell functions
└── completions/
    └── *.fish                  # Fish shell completions
```

### Template Variables

Chezmoi templates use Go text/template syntax with custom functions:

```go
{{ .chezmoi.os }}              // OS: "darwin", "linux"
{{ .profile }}                 // Current profile: "default", "server", "ct", "aaa"
{{ .using_nix }}               // Boolean: Nix integration enabled
{{ .is_p_default }}            // Boolean: Profile-specific flag
{{ onepasswordRead "op://..." }} // Retrieve secret from 1Password vault
{{ if eq .chezmoi.os "darwin" }} // Conditional OS check
```

## Configuration File Inventory

### Shell Configurations (~1500 LOC total)

| Shell | Entry | Modules | Functions | Plugins | LOC |
|-------|-------|---------|-----------|---------|-----|
| **Fish** | config.fish | 14 | 13 custom | 13 (Fisher) | ~600 |
| **Zsh** | zshrc | 10 | 8 custom | 27 (Sheldon) | ~500 |
| **Bash** | bashrc | 7 | 0 custom | 6 (Sheldon) | ~200 |

### Tool Configurations

| Tool | Type | LOC | Key Settings |
|------|------|-----|--------------|
| **Tmux** | Config | 1600 | Oh my tmux! + local overrides |
| **Git** | Config + Aliases | 80 | Dual identity, signing, difftastic |
| **Zellij** | Config (KDL) | 366 | Vim keybindings, 11 plugins |
| **Atuin** | Config (TOML) | 270 | History sync, secrets filtering |
| **Starship** | Config (TOML) | 184 | Custom colors, git integration |
| **IdeaVim** | Config (VimL) | 357 | Comprehensive keymaps, which-key |
| **Karabiner** | Config (JSON) | 125 | Device-specific key remapping |
| **Lazygit** | Config (YAML) | 39 | Diff pager, AI commit commands |
| **Yazi** | Config (TOML) | ~20 | Catppuccin Mocha theme |
| **Zed** | Config (JSON) | 48 | Dark theme, JetBrains keybindings |

### Script Inventory

| Script | Language | Purpose | Dependencies |
|--------|----------|---------|--------------|
| `upall.tmpl` | Fish | Master update orchestrator | brew, nix, mise, cargo, fisher, chezmoi |
| `osupdate.tmpl` | Fish | OS-specific updates | apt/dnf/pacman/mas/yay |
| `gpg-backup` | Bash | Backup GPG keys to 1Password | gpg, op |
| `gpg-restore-backup` | Bash | Restore GPG keys from 1Password | gpg, op |
| `setup-atuin` | Bash | Configure Atuin | atuin, op |
| `setup-dotfiles-repo-url` | Bash | Convert git remotes to SSH | git |
| `brewup` | Fish | Update Homebrew | brew |

## Code Statistics

- **Total Files:** 100+
- **Total LOC:** ~9,000 (excluding comments, mostly configs)
- **Languages:** Fish (600), Zsh (500), Bash (200), TOML/YAML/JSON (2000+), Shell scripts (300)
- **Template Files:** ~40 (.tmpl suffixes)
- **Largest Files:** tmux.conf (1600), SHELL-REFERENCE.md (35K), IdeaVim (357)

## Dependencies & External Integrations

### Required Tools
- **Chezmoi** - Dotfile manager
- **1Password CLI** (`op`) - Secrets management
- **Fish/Zsh/Bash** - Shells (at least one)
- **Git** - Version control
- **Homebrew** - macOS package manager
- **Starship** - Shell prompt

### Optional but Integrated
- **Mise** - Version manager (Node, Python, Go, Java, Rust, Maven, Cargo tools)
- **Fisher** - Fish plugin manager (13 plugins)
- **Sheldon** - Zsh/Bash plugin manager (27 + 6 plugins)
- **Tmux/Zellij** - Terminal multiplexer
- **Atuin** - Shell history search
- **FZF** - Fuzzy finding
- **Yazi** - File manager
- **Lazygit** - Git UI
- **Difftastic** - Structural diff
- **Mise GitHub Token** - For package access

### macOS-Specific
- **Karabiner Elements** - Keyboard customization
- **Pinentry-mac** - GPG password entry
- **MAS** - Mac App Store CLI
- **Ghostty** - Terminal emulator

### Linux-Specific
- **apt/dnf/pacman/yay** - Package managers
- **Pipewire/ALSA** - Audio systems (referenced in configs)

## Template System

### Templating Strategy
1. **Interactive Init** (`.chezmoi.yaml.tmpl`) - User selects profile, editor, Nix integration
2. **Config Files** - Chezmoi processes .tmpl files, substitutes variables
3. **Secret Injection** - `onepasswordRead()` retrieves secrets during apply
4. **Conditional Logic** - `{{ if }}` blocks for OS, profile, feature flags

### Chezmoi-Specific Features Used
- Template functions: `onepasswordRead`, `onepasswordItemFields`
- Conditional includes per OS and profile
- Script execution hooks (before/after/once)
- Ignore rules (.chezmoiignore)
- Remove rules (.chezmoiremove)

## Key Integration Points

### 1. Shell Startup Chain
Fish/Zsh/Bash → conf.d/ modules → plugin manager → aliases → Starship prompt

### 2. Git Integration
1Password SSH signing (macOS) ↔ Git config ↔ Lazygit UI ↔ aicommit2 (AI suggestions)

### 3. Secret Management
1Password vault ← GPG backup/restore ← Git signing keys, SSH keys, API tokens

### 4. Tool Orchestration
Mise version manager → Multiple runtimes (Node, Python, Go, Rust, Java, Bun)

### 5. History System
Shell ↔ Atuin daemon ↔ Local SQLite DB ↔ 1Password sync (optional)

## Maintenance & Update Patterns

- **Shell configs:** Added to conf.d/ with numeric prefixes, load order managed
- **Tool configs:** Separate directories per tool, .local overrides for customization
- **Templates:** Apply-time variable substitution, local user edits in *_local files
- **Scripts:** Chezmoi ordering (00-before, 01-after), run_once prevents re-execution
- **Versioning:** All changes tracked in git, profiles enable per-machine variations

## Code Quality & Standards

- **Modularity:** Config split by concern, separate files per tool
- **Naming:** Kebab-case files, clear prefixes indicate load order and type
- **Documentation:** SHELL-REFERENCE.md provides alias/function documentation
- **Security:** All secrets in 1Password, no hardcoded credentials
- **Portability:** OS-specific code in separate files, conditional loading
- **Testing:** Manual (chezmoi apply --dry-run), no automated test suite

## Performance Considerations

- **Shell Startup:** ~1-2 seconds (Fish/Zsh with plugins)
- **Alias Resolution:** Optimized with fifc fork (case-insensitive tab completion)
- **History System:** Atuin uses SQLite for fast lookups
- **Plugin Loading:** Lazy loading where possible (Sheldon, Fisher)
- **Prompt:** Starship compiled binary, minimal startup overhead
