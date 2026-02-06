# Phase 02: Add Brewfile with Packages

## Status: completed

## Overview

Create `Brewfile` containing all packages currently managed by Nix. This provides declarative package management via `brew bundle`.

## Source Analysis

### From packages.nix (CLI tools)

| Category | Packages |
|----------|----------|
| core | atuin, carapace, nushell, sheldon, starship, tmux, coreutils, moreutils, findutils, gnused, gnutar, fswatch, fh |
| tools | bat, eza, fd, fzf, ripgrep, pay-respects, tree-sitter, unar, zoxide |
| viewers | chafa, ffmpegthumbnailer, poppler, viu |
| processing | gawk, jq, yq |
| editors | vim, neovim |
| dotfiles | chezmoi, mkalias |
| utils | ast-grep, mas, nixfmt, shfmt, watch, xz, envsubst |
| vcs | git, git-lfs, gitleaks, gh, lazygit, diff-so-fancy, difftastic |
| monitoring | btop, neofetch |
| network | curl, wget, inetutils, dig |
| dev | mise, usage, python3, nixd |
| container | podman, podman-tui, podman-compose |
| security | age, openssl, gnupg, sshpass, pinentry, 1password-cli |
| packaging | pkg-config, luarocks |

### From packages-darwin.nix

**Brews (already Homebrew):**
- urlview, openssl, podman, podman-compose, coreutils, moreutils, findutils

**Casks (GUI apps):**
- 1password, gpg-suite-no-mail, proton-pass, protonvpn, tunnelblick
- alfred, bartender, cleanmymac, cleanshot, doll, hammerspoon, imageoptim
- keepingyouawake, leader-key, logi-options+, monitorcontrol, neohtop
- notion, notion-calendar, obsidian, pixelsnap, rectangle-pro, transnomino, clop
- ghostty, jetbrains-toolbox, podman-desktop, postman, visual-studio-code, cursor, zed
- discord, google-chrome, slack, vivaldi, zoom
- google-drive, proton-drive, proton-mail
- spotify, steam, whisky, heroic
- utm

## Package Name Mappings

Some packages have different names in Homebrew:

| Nix Name | Homebrew Name |
|----------|---------------|
| gnused | gnu-sed |
| gnutar | gnu-tar |
| _1password-cli | 1password-cli |
| yq-go | yq |
| pay-respects | pay-respects |
| unixtools.watch | watch |
| pinentry-curses | pinentry |
| pinentry_mac | pinentry-mac |
| inetutils | inetutils |

## Target File

Create `home/Brewfile`:

```ruby
# Brewfile - Declarative package management
# Run: brew bundle --file=~/Brewfile

# Taps
tap "homebrew/bundle"
tap "homebrew/cask-fonts"

# === Core Shell Tools ===
brew "atuin"          # Shell history sync
brew "carapace"       # Multi-shell completion
brew "nushell"        # Modern shell
brew "sheldon"        # Shell plugin manager
brew "starship"       # Cross-shell prompt
brew "tmux"           # Terminal multiplexer

# === GNU Utilities ===
brew "coreutils"      # GNU core utilities
brew "moreutils"      # Additional Unix utilities
brew "findutils"      # GNU find, xargs, locate
brew "gnu-sed"        # GNU sed
brew "gnu-tar"        # GNU tar
brew "gawk"           # GNU awk
brew "watch"          # Execute program periodically

# === File Tools ===
brew "bat"            # Cat with syntax highlighting
brew "eza"            # Modern ls replacement
brew "fd"             # Modern find replacement
brew "fzf"            # Fuzzy finder
brew "ripgrep"        # Fast grep replacement
brew "tree-sitter"    # Parser generator
brew "unar"           # Universal archive extractor
brew "zoxide"         # Smarter cd command
brew "fswatch"        # File change monitor

# === Viewers ===
brew "chafa"          # Terminal image viewer
brew "ffmpegthumbnailer"  # Video thumbnailer
brew "poppler"        # PDF utilities
brew "viu"            # Terminal image viewer

# === Data Processing ===
brew "jq"             # JSON processor
brew "yq"             # YAML processor
brew "envsubst"       # Environment variable substitution

# === Editors ===
brew "vim"
brew "neovim"

# === Version Control ===
brew "git"
brew "git-lfs"        # Large file storage
brew "gitleaks"       # Secret scanner
brew "gh"             # GitHub CLI
brew "lazygit"        # Git TUI
brew "diff-so-fancy"  # Better git diffs
brew "difftastic"     # Structural diff

# === Development ===
brew "mise"           # Dev runtime manager (replaces asdf)
brew "usage"          # CLI usage parser
brew "python@3"       # Python 3
brew "pkg-config"     # Compiler helper
brew "luarocks"       # Lua package manager
brew "ast-grep"       # AST-based search

# === Containers ===
brew "podman"         # Container runtime
brew "podman-compose" # Docker compose for Podman

# === Monitoring ===
brew "btop"           # Resource monitor
brew "neofetch"       # System info

# === Networking ===
brew "curl"
brew "wget"
brew "inetutils"      # Network utilities
brew "bind"           # DNS tools (dig)

# === Security ===
brew "age"            # Modern encryption
brew "openssl"
brew "gnupg"          # GPG
brew "sshpass"        # SSH password auth
brew "pinentry"       # GPG PIN entry
brew "pinentry-mac"   # macOS PIN entry
brew "1password-cli"  # 1Password CLI

# === Utilities ===
brew "chezmoi"        # Dotfiles manager
brew "mas"            # Mac App Store CLI
brew "shfmt"          # Shell formatter
brew "xz"             # Compression
brew "urlview"        # URL extractor
brew "fh"             # FlakeHub CLI
brew "dockutil"       # Dock management

# === macOS Casks ===

# Security & Privacy
cask "1password"
cask "gpg-suite-no-mail"
cask "proton-pass"
cask "protonvpn"
cask "tunnelblick"

# Productivity
cask "alfred"
cask "bartender"
cask "cleanmymac"
cask "cleanshot"
cask "doll"
cask "hammerspoon"
cask "imageoptim"
cask "keepingyouawake"
cask "leader-key"
cask "logi-options+"
cask "monitorcontrol"
cask "neohtop"
cask "notion"
cask "notion-calendar"
cask "obsidian"
cask "pixelsnap"
cask "rectangle-pro"
cask "transnomino"
cask "clop"

# Development
cask "ghostty"
cask "jetbrains-toolbox"
cask "podman-desktop"
cask "postman"
cask "visual-studio-code"
cask "cursor"
cask "zed"

# Browsers & Communication
cask "discord"
cask "google-chrome"
cask "slack"
cask "vivaldi"
cask "zoom"

# Cloud Storage
cask "google-drive"
cask "proton-drive"
cask "proton-mail"

# Media
cask "spotify"
cask "steam"
cask "whisky"
cask "heroic"

# Virtual Machines
cask "utm"
```

## Implementation Steps

1. Create `home/Brewfile` with content above
2. Verify package names exist in Homebrew: `brew search <name>`
3. Test locally: `brew bundle check --file=home/Brewfile`

## Notes

- Casks only install on macOS (Homebrew ignores on Linux)
- `nixfmt` and `nixd` excluded (only needed with Nix)
- `mkalias` excluded (Nix-specific, mac-app-util replacement)
- `pay-respects` may need tap or alternative

## Success Criteria

- [ ] Brewfile created at `home/Brewfile`
- [ ] All package names verified in Homebrew
- [ ] `brew bundle check` passes (or lists only missing)
