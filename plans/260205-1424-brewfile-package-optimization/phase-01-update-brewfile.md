# Phase 01: Update Brewfile

## Context Links

- [Brewfile](../../home/Brewfile) - Target file
- [Code Standards](../../docs/code-standards.md) - Naming conventions

## Overview

- **Priority:** P2
- **Status:** complete
- **Effort:** 15m

Update the Brewfile to remove redundant packages and add modern CLI utilities.

## Key Insights

1. `python@3`, `usage`, `age` are redundant - mise manages these runtimes
2. `carapace` is unused - user confirmed removal
3. New tools follow modern Rust CLI replacement pattern (sd, procs, dust, delta)
4. All additions are established Homebrew formulae

## Requirements

### Functional

- Remove 4 packages from Brewfile
- Add 7 packages to appropriate sections
- Maintain existing comment style: `brew "name"  # Description`

### Non-functional

- Keep alphabetical order within sections where existing
- Preserve section headers and formatting

## Related Code Files

### Modify

- `home/Brewfile` - Main package manifest

## Implementation Steps

### Step 1: Remove redundant packages

Remove these lines from Brewfile:

```bash
# Line 16 - Core Shell Tools section
brew "carapace"       # Multi-shell completion

# Lines 67-68 - Development section
brew "usage"          # CLI usage parser
brew "python@3"       # Python 3

# Line 88 - Security section
brew "age"            # Modern encryption
```

### Step 2: Add new packages to File Tools section (after line 38)

Add to File Tools section (after `brew "zoxide"`):

```bash
brew "dust"           # Modern du replacement
brew "sd"             # Modern sed replacement
```

### Step 3: Add new packages to Version Control section (after line 63)

Add after `brew "difftastic"`:

```bash
brew "delta"          # Git diff viewer
```

### Step 4: Add new packages to Development section (after line 71)

Add after `brew "ast-grep"`:

```bash
brew "just"           # Task runner
brew "tokei"          # Code statistics
```

### Step 5: Add new packages to Monitoring section (after line 79)

Add after `brew "neofetch"`:

```bash
brew "procs"          # Modern ps replacement
```

### Step 6: Add new packages to Utilities section (after line 103)

Add after `brew "urlview"`:

```bash
brew "hyperfine"      # CLI benchmarking
```

## Expected Final State

### File Tools section

```bash
# === File Tools ===
brew "bat"            # Cat with syntax highlighting
brew "dust"           # Modern du replacement
brew "eza"            # Modern ls replacement
brew "fd"             # Modern find replacement
brew "fzf"            # Fuzzy finder
brew "ripgrep"        # Fast grep replacement
brew "sd"             # Modern sed replacement
brew "tree-sitter"    # Parser generator
brew "unar"           # Universal archive extractor
brew "zoxide"         # Smarter cd command
brew "fswatch"        # File change monitor
```

### Version Control section

```bash
# === Version Control ===
brew "git"
brew "git-lfs"        # Large file storage
brew "gitleaks"       # Secret scanner
brew "gh"             # GitHub CLI
brew "lazygit"        # Git TUI
brew "diff-so-fancy"  # Better git diffs
brew "difftastic"     # Structural diff
brew "delta"          # Git diff viewer
```

### Development section (without removed packages)

```bash
# === Development ===
brew "mise"           # Dev runtime manager (replaces asdf)
brew "pkg-config"     # Compiler helper
brew "luarocks"       # Lua package manager
brew "ast-grep"       # AST-based search
brew "just"           # Task runner
brew "tokei"          # Code statistics
```

### Monitoring section

```bash
# === Monitoring ===
brew "btop"           # Resource monitor
brew "neofetch"       # System info
brew "procs"          # Modern ps replacement
```

### Security section (without age)

```bash
# === Security ===
brew "openssl"
brew "gnupg"          # GPG
brew "sshpass"        # SSH password auth
brew "pinentry"       # GPG PIN entry
brew "pinentry-mac"   # macOS PIN entry
brew "1password-cli"  # 1Password CLI
```

### Core Shell Tools section (without carapace)

```bash
# === Core Shell Tools ===
brew "atuin"          # Shell history sync
brew "sheldon"        # Shell plugin manager
brew "starship"       # Cross-shell prompt
brew "tmux"           # Terminal multiplexer
```

### Utilities section

```bash
# === Utilities ===
brew "chezmoi"        # Dotfiles manager
brew "hyperfine"      # CLI benchmarking
brew "mas"            # Mac App Store CLI
brew "pay-respects"   # Command correction (f to fix)
brew "reattach-to-user-namespace"  # tmux clipboard fix
brew "shfmt"          # Shell formatter
brew "xz"             # Compression
brew "urlview"        # URL extractor
brew "dockutil"       # Dock management
```

## Todo List

- [ ] Remove `carapace` from Core Shell Tools
- [ ] Remove `usage` from Development
- [ ] Remove `python@3` from Development
- [ ] Remove `age` from Security
- [ ] Add `dust` to File Tools
- [ ] Add `sd` to File Tools
- [ ] Add `delta` to Version Control
- [ ] Add `just` to Development
- [ ] Add `tokei` to Development
- [ ] Add `procs` to Monitoring
- [ ] Add `hyperfine` to Utilities
- [ ] Run `chezmoi apply --dry-run` to verify
- [ ] Run `brew bundle --file=~/Brewfile` to install

## Success Criteria

- All 4 packages removed
- All 7 packages added with proper comments
- Brewfile maintains consistent formatting
- `chezmoi apply` succeeds
- `brew bundle` installs new packages

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Package name typo | Low | Brew bundle will error; easy to fix |
| Missing dependency | Low | New packages are standalone |

## Security Considerations

- No secrets or credentials involved
- All packages from official Homebrew tap

## Next Steps

1. After implementation, run `chezmoi apply`
2. Run `brew bundle` to install new packages
3. Optionally add aliases/abbreviations for new tools
