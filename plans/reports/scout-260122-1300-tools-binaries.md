# Scout Report: Tools, Binaries & Major Configs

**Date:** 2026-01-22  
**Scope:** Chezmoi dotfiles repository custom tools and configurations  
**Directories Analyzed:** `home/bin/`, `home/dot_config/tmux/`, `home/dot_config/git/`, `home/dot_config/zellij/`, `home/dot_config/atuin/`, `home/dot_config/yazi/`, `home/dot_config/lazygit/`, `home/dot_config/etc/`

---

## Overview

This repository contains a well-organized set of custom shell scripts, terminal multiplexer configs, and developer tool configurations. The setup emphasizes:
- Cross-platform support (macOS, Linux)
- 1Password integration for secrets management
- GPG key backup/restoration via 1Password
- Modern terminal tooling (Zellij, Atuin, Yazi, Lazygit)
- Comprehensive git configuration with multiple identities
- Systemwide update automation

---

## Custom Scripts (bin/)

### Script Inventory

| Script | Purpose | Language | Dependencies |
|--------|---------|----------|--------------|
| `brewup` | Update Homebrew | Fish | brew |
| `dot_editorconfig` | EditorConfig standard for dotfiles | Config | N/A |
| `fix-zsh-insecure` | Secure zsh startup files | Zsh | compaudit, chmod |
| `gpg-backup` | Backup GPG keys to 1Password | Bash | gpg, gpg-upload-op |
| `gpg-download-op` | Download GPG keys from 1Password | Bash | op (1Password CLI) |
| `gpg-restore-backup` | Restore GPG keys from backup | Bash | gpg, gpg-download-op |
| `gpg-upload-op` | Upload GPG keys to 1Password | Bash | op (1Password CLI) |
| `setup-atuin` | Configure Atuin shell history tool | Bash | atuin |
| `setup-dotfiles-repo-url` | Update git remotes to SSH | Bash | git |
| `show-zsh-startup-files-order` | Display zsh startup sequence | Bash | N/A |
| `upall.tmpl` | Universal update orchestrator | Fish | Templated (chezmoi) |
| `osupdate.tmpl` | OS-specific updates | Fish | Templated (chezmoi) |

### Key Utilities

**GPG Key Management Suite**
- `gpg-backup` → `gpg-upload-op`: Backup chain exports private/public keys and trust data
- `gpg-restore-backup` → `gpg-download-op`: Restore chain imports keys via 1Password
- Files stored: `~/.gnupg/bkp/{private,public,trust}.gpg` (temporary during operations)
- Security: Strict permissions (600 for private, 644 for public)

**Update Orchestration**
- `upall.tmpl`: Master update script with conditional logic
  - Requests sudo upfront
  - Updates: OS, Nix, Brew, Mise, Rust, Chezmoi, Fisher
  - Uses template variables: `{{ if eq .using_nix true }}`
  
- `osupdate.tmpl`: Platform-specific OS updates
  - macOS: MAS (Mac App Store) updates
  - Ubuntu/Debian: apt update/upgrade/autoremove
  - RHEL: dnf update
  - Arch: pacman + AUR (yay) + flatpak

**Shell Security**
- `fix-zsh-insecure`: Runs `compaudit | xargs chmod go-w` to fix zsh permission warnings

**Repository Setup**
- `setup-dotfiles-repo-url`: Converts git remotes to SSH for three repos:
  - Chezmoi dotfiles
  - Nix configuration
  - Neovim configuration

---

## Tmux Configuration

### Files

- `/home/dot_config/tmux/tmux.conf` (~1600 lines): Base config from "Oh my tmux!"
- `/home/dot_config/tmux/tmux.conf.local`: User customizations & overrides
- `/home/dot_config/tmux/tmux.conf.tmp`: Temporary/backup file (unused)

### Key Features

**Base Configuration** (`tmux.conf`)
- Framework: "Oh my tmux!" (gpakosz/.tmux) - dual WTFPL v2/MIT licensed
- Terminal: 256 colors with extended keys support
- Escape time: 10ms (faster command sequences)
- History: 5000 lines
- Prefix keys: `C-b` (default) + `C-a` (GNU Screen compatible)

**Key Bindings** (partial summary)
- **Pane Navigation**: hjkl movements (vim-like)
- **Window Navigation**: `C-h`/`C-l` previous/next window
- **Split Windows**: `-` (horizontal), `_` (vertical)
- **Session Creation**: `C-c` new-session, `C-f` find-session
- **Copy Mode**: `Enter` to enter, `v` select, `y` copy, vim keybindings
- **Misc**: `m` toggle mouse, `r` reload config, `e` edit config, `F` facebook pathpicker

**Theming** (`tmux.conf.local`)
- Color scheme: Custom dark theme (80808 dark gray base)
- Status bar: Unicode powerline separators (E0B0-E0B3)
- Left status: Session name + uptime
- Right status: Prefix indicator, mouse, pairing, sync status, battery %, time, username, hostname
- Pane borders: Thin style, active pane highlighted in light blue

**Customizations** (`tmux.conf.local`)
- Mouse mode: Enabled (`set -g mouse on`)
- TPM (Tmux Plugin Manager): Auto-update enabled
- Battery indicator: Gradient palette (visual battery bar)
- User bindings: Custom mouse toggle feedback

### Plugins/Theme

- **Framework**: Oh my tmux! with TPM integration
- **Plugins**: Currently disabled (commented out)
- **Available plugins**: tmux-copycat, tmux-cpu, tmux-resurrect, tmux-continuum
- **No active plugins** in current config

---

## Git Configuration

### Files

- `/home/dot_config/git/config.main.tmpl`: Primary git config (SSH signing for macOS)
- `/home/dot_config/git/config.aaa.tmpl`: Alternative config (OpenPGP signing for AAA account)
- `/home/dot_config/git/aliases.tmpl`: 40+ git aliases
- `/home/dot_config/git/ignore`: Global gitignore rules
- `/home/dot_config/etc/gitconfig.template.tmpl`: Master gitconfig (sourced by system)

### Configuration Details

**User Identity Management**
- Config includes 1Password vault references: `onepasswordRead "op://..."`
- Dual identity setup: main account vs AAA account
- Main: SSH signing via 1Password (macOS)
- AAA: OpenPGP signing via gpg2

**Commit Signing**
- Main config: `gpg.format = ssh` + 1Password op-ssh-sign
- AAA config: `gpg.format = openpgp` + gpg2
- Both: `commit.gpgsign = true`

**Core Settings** (gitconfig.template.tmpl)
- Whitespace handling: Strict (space-before-tab, trailing-space)
- Autocorrect: Enabled (typo correction)
- EOL: LF only, autocrlf = input
- Core settings: trustctime=false, ignorecase=false

**Diff Tools**
- Default: `difftastic` (difft)
- Detection: Copies as well as renames
- Pager: diff-so-fancy integration

**Merge & Pull**
- Pull strategy: Rebase disabled (merge-based)
- Merge commits: Include summaries
- Submodules: Recurse disabled by default

### Aliases

**Log Viewing** (40+ aliases total)
- `l`: Pretty oneline log (20 commits, colored, decorated)
- `lg`: Color format with author/date/graph
- `dft`: Difftool
- `dlog`: Difftool log with difft external tool

**Branch Management**
- `go`: Checkout or create branch
- `del-gone`: Delete branches deleted in origin
- `del-branch`: Delete local and remote
- `rename`: Rename branch locally and remotely
- `copy-branch-name`: Copy current branch to clipboard (platform-aware)
- `update-*`: Update specific branches without switching

**Status & Diff**
- `s`: Status short format
- `d`: Diff with current state
- `di`: Diff against N revisions ago

**Commits & Pulls**
- `ca`: Add all + commit (verbose)
- `r`: Reset hard (clean + reset + checkout)
- `p`: Pull with submodule recursion
- `c`: Clone recursive
- `amend`: Amend to HEAD
- `pf`/`pfr`: Full pull with all tags, prune, progress

**Conditional Includes**
- Main config: Loaded by default
- AAA config: Auto-loaded when gitdir matches `**/aaa/**/.git`

---

## Terminal Multiplexer (Zellij)

### Configuration

**File**: `/home/dot_config/zellij/config.kdl` (366 lines)

**Key Settings**
- Default shell: Fish
- UI: Standard with tab bar, status bar, filepicker, session manager
- Mouse: Default enabled
- Copy target: System clipboard (default)
- Scroll buffer: 10,000 lines

**Keybindings** (comprehensive vim-style setup)
- **Modes**: Normal, Locked, Pane, Resize, Move, Tab, Scroll, Search, Session, Tmux-compat
- **Navigation**: hjkl for all directional controls
- **Mode Switching**: Ctrl+key combinations
  - `Ctrl-g`: Locked mode
  - `Ctrl-p`: Pane mode
  - `Ctrl-n`: Resize mode
  - `Ctrl-t`: Tab mode
  - `Ctrl-s`: Scroll mode
  - `Ctrl-o`: Session mode
  - `Ctrl-h`: Move mode
  - `Ctrl-b`: Tmux mode (compatibility)

**Pane Operations**
- `Alt-n`: New pane
- `Ctrl-p + {n,d,r}`: New pane (normal, down, right)
- `Ctrl-p + x`: Close focus
- `Ctrl-p + f`: Toggle fullscreen
- `Ctrl-p + z`: Toggle pane frames

**Tab Operations**
- `Ctrl-t + n`: New tab
- `Ctrl-t + x`: Close tab
- `Ctrl-t + {h,l}`: Previous/next tab
- `Tab`: Toggle last tab
- Numbers `1-9`: Direct tab selection

**Scroll/Search**
- `Ctrl-s`: Enter scroll mode
- `Ctrl-f`/`Ctrl-b`: Page down/up
- `j/k`: Line scroll
- `d/u`: Half-page scroll
- `e`: Edit scrollback
- `s`: Enter search mode

**Session Management**
- `Ctrl-o`: Session mode
- `d`: Detach
- `w`: Session manager (floating)

**Plugins**
- tab-bar, status-bar, strider (file picker), compact-bar, session-manager, welcome-screen

### Theme

- Default theme used (customizable via theme files)
- No custom theme defined

---

## Atuin (Shell History Tool)

### Configuration

**File**: `/home/dot_config/atuin/private_config.toml` (270 lines, mostly commented defaults)

**Active Settings**
- `filter_mode_shell_up_key_binding = "directory"`: Filter by directory on up-key
- `style = "full"`: Full UI style (not compact)
- `invert = false`: Search bar at bottom (standard)
- `show_preview = true`: Show command preview
- `enter_accept = true`: Immediate execution on enter (not edit mode)

**Sync Configuration**
- `records = true`: Enable sync v2 by default
- Auto-sync: Disabled by default (commented)
- Sync address: Default (api.atuin.sh)

**Security Features**
- `secrets_filter = true`: Default, filters AWS keys, GitHub PAT, Slack tokens, Stripe keys
- Environment-based filtering for sensitive commands

**Statistics**
- Common subcommands: Disabled (uses defaults like git, docker, kubectl)
- Ignored commands: Can be customized (cd, ls, vi by default)

**Database & Storage**
- Database: `~/.local/share/atuin/history.db`
- Encryption key: `~/.local/share/atuin/key`
- Session token: `~/.local/share/atuin/session`

### Integration

Atuin is initialized in shell configs via `eval "$(atuin init bash)"` or equivalent. The `setup-atuin` script handles first-time login, import, and sync.

---

## File Manager (Yazi)

### Configuration

**Files**
- `/home/dot_config/yazi/yazi.toml`: Minimal config
- `/home/dot_config/yazi/theme.toml`: Theme reference
- `/home/dot_config/yazi/package.toml`: Package/flavor dependencies

**Settings**
- `show_hidden = true`: Display hidden files by default

**Theme**
- Flavor: `catppuccin-mocha` (dark theme)
- Package dependency: `yazi-rs/flavors:catppuccin-mocha` (rev: d479f67)

**Plugins & Flavors**
- No custom plugins (empty deps)
- Flavor system managed via package.toml

---

## Git TUI (Lazygit)

### Configuration

**File**: `/home/dot_config/lazygit/config.yml` (39 lines)

**Diff Configuration**
- Pager: `diff-so-fancy`
- Color arg: Always enabled
- External diff tool: `difft` (difftastic)

**Custom Commands**
- `<c-g>`: "Pick AI commit" - `aicommit2 --clipboard`
- `<c-n>`: "Pick AI commit (no verify)" - `aicommit2 --no-verify --clipboard`
- Both output to terminal

**Theme** (Catppuccin Mocha palette)
- Active border: Light blue (#89b4fa, bold)
- Inactive border: Soft blue (#a6adc8)
- Selected line bg: Dark surface (#313244)
- Cherry-picked bg/fg: Purple (#45475a/#89b4fa)
- Unstaged changes: Red (#f38ba8)
- Default text: Light gray (#cdd6f4)
- Search active border: Yellow (#f9e2af)
- Author color: Lavender (#b4befe)

---

## EditorConfig

### File

`/home/dot_config/bin/executable_dot_editorconfig`

### Rules

**Global (all files)**
- Indent: 2 spaces
- EOL: LF
- Charset: UTF-8
- Trim trailing whitespace: true
- Insert final newline: true

**Language-Specific**
- Python: 4 spaces, 80 char line length
- JSON: No final newline (inconsistent in projects)
- Minified JS: Ignore formatting
- Makefiles & batch files: Tab indentation
- Markdown: Don't trim trailing whitespace

---

## SSH Configuration

### File

`/home/dot_config/etc/private_ssh_config.template.tmpl`

**Hosts Configured**
- **1Password Integration**: Includes `~/.ssh/1Password/config` (host keys managed externally)
- **GitHub**: SSH key `~/.ssh/id_github.pub`, git user
- **Bitbucket (personal)**: SSH key `~/.ssh/id_bitbucket.pub` (default)
- **Bitbucket (AAA)**: Alias `bitbucket-aaa`, SSH key `~/.ssh/id_bitbucket_aaa.pub`

**Settings**: IdentitiesOnly=yes (strict key matching), no passwords

---

## GPG Agent Configuration

### File

`/home/dot_config/etc/private_gpg-agent.conf.template.tmpl`

**Cache Settings**
- Default TTL: 172,800 seconds (2 days)
- Max TTL: 432,000 seconds (5 days)

**Pinentry** (macOS)
- Auto-detects `pinentry-mac` via `which` command
- Falls back to commented note if not found
- Template-conditional: Only on Darwin

---

## NPM Configuration

### File

`/home/dot_config/etc/npmrc.template.tmpl`

**Secrets Management**
- GitHub NPM registry auth token retrieved from 1Password
- Reference: `onepasswordItemFields "lzlakqn35xiz2wptj56mhtghdy"`
- Conditional on `is_p_csaa` template variable
- Format: `//npm.pkg.github.com/:_authToken=<token>`

---

## macOS LaunchD Configuration

### File

`/home/dot_config/etc/limit.maxfiles.plist.tmpl`

**Purpose**: Increase file descriptor limits at startup

**Settings**
- Label: `limit.maxfiles`
- Soft limit: 65,536 files
- Hard limit: 200,000 files
- RunAtLoad: true (execute at system startup)

**Conditional**: Darwin (macOS) only

---

## Git Ignore

### File

`/home/dot_config/git/ignore`

**Global Ignores**
- `.DS_Store` (macOS)
- `Thumbs.db` (Windows)
- `.history/` (shell history backups)
- `.mise.local.toml` / `mise.local.toml` (local tool config overrides)
- `**/.claude/settings.local.json` (AI assistant local settings)

---

## Integration Points with Shell Configs

### Assumed Shell Integrations

Based on scripts and configs, these tools integrate with shell startup:

1. **Atuin**: Shell init via `eval "$(atuin init bash)"` or Fish equivalent
   - Replaces shell history with Atuin backend
   - Syncs across machines

2. **Zellij**: Launched as terminal multiplexer alternative to Tmux
   - Default shell set to Fish
   - Keybindings configured for vim users

3. **Tmux**: Fallback multiplexer or parallel to Zellij
   - Loads Oh my tmux! framework
   - Local config overrides in `.local` file

4. **Git**: Integration via aliases and signed commits
   - SSH signing for main account
   - OpenPGP for AAA account
   - difftastic integration

5. **Lazygit**: Git UI launcher (typically via shell function/alias)
   - AI commit suggestions via aicommit2

6. **Yazi**: File manager launcher (can be in shell alias)
   - Hidden files shown by default

### 1Password Integration Points

- **Git commits**: SSH signing via `1Password.app/Contents/MacOS/op-ssh-sign`
- **Git config**: User data pulled via `onepasswordRead` (name, email, signing key)
- **GPG keys**: Backup/restore via `op document` commands
- **SSH config**: Host configuration managed by 1Password
- **NPM registry**: Auth tokens stored in 1Password vault
- **Setup scripts**: Repo URL initialization

---

## Dependencies Summary

### External Tools Required

- **Homebrew**: Package manager (macOS)
- **1Password CLI** (`op`): Secrets retrieval
- **Git/GPG**: Version control and cryptography
- **Difftastic** (`difft`): Diff tool
- **Fish shell**: Default shell for scripts
- **Atuin**: Shell history tool
- **Zellij/Tmux**: Terminal multiplexer
- **Yazi**: File manager
- **Lazygit**: Git UI
- **aicommit2**: AI commit message generation
- **diff-so-fancy**: Git diff pager
- **mas**: macOS App Store CLI (optional)
- **Mise**: Polyglot version manager (optional)
- **Rustup/Cargo**: Rust updates (optional)
- **Fisher**: Fish plugin manager (optional)
- **pinentry-mac**: GPG password entry (macOS)

### Optional/Conditional Dependencies

- **Nix**: For `~/.config/nix-config` updates
- **Docker/Kubernetes**: For yay (AUR), pacman tools
- **apt/dnf/yay**: Platform-specific package managers

---

## Security Observations

1. **1Password Integration**: Centralized secrets management
   - Git signing keys stored in 1Password
   - GPG backups uploaded to 1Password vault
   - SSH configuration managed by 1Password

2. **GPG Setup**: Backup/restore cycle with temporary files
   - Files cleaned up after import
   - Permissions strictly enforced (600/644)

3. **Commit Signing**: Mandatory (`gpgsign = true`)
   - SSH signing for main (macOS)
   - OpenPGP for AAA

4. **Secrets Filtering**: Atuin filters sensitive commands
   - AWS keys, GitHub PAT, Slack tokens, Stripe keys excluded from history

5. **SSH Key Management**: Multiple identities per host
   - IdentitiesOnly=yes (prevents key leakage)
   - 1Password hosts file integrated

---

## Architecture Notes

### Modular Design

- **Bin scripts**: Self-contained utilities, minimal dependencies
- **Config files**: Separated by tool (tmux/, git/, zellij/, etc.)
- **Templating**: Chezmoi templates allow environment-specific configs
- **Overrides**: `.local` files for tmux enable customizations without modifying main config

### Cross-Platform Support

- Conditional template blocks for macOS (Darwin) vs Linux
- OS-specific update scripts (osupdate.tmpl)
- Dual git configs for different accounts/signing methods

### Update Automation

- Master `upall.tmpl` script orchestrates all updates
- Conditional subsystem updates (Nix, Brew, Rust, etc.)
- Template variables control feature enablement

---

## Unresolved Questions

1. **Tmux TPM**: Why are plugins commented out? Are they intended for future use?
2. **Zellij vs Tmux**: What's the active multiplexer? Both configured - primary choice?
3. **AAA Account**: What is the AAA account used for? (Separate git config + ssh host)
4. **Fish Shell**: Is Fish the primary shell, or is it alongside Zsh/Bash?
5. **Mise Tool**: What managed tools are configured in Mise?
6. **Nix Config**: What's in `~/.config/nix-config`? NixOS or Home Manager setup?
7. **Aicommit2**: What model/API does aicommit2 use? (OpenAI/local?)
8. **Active Lazygit**: Is lazygit regularly used, or is it secondary to other git UIs?

