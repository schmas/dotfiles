# Scout Report: Chezmoi & Miscellaneous Configurations

## Overview

This dotfiles repository uses chezmoi as the dotfile manager with a comprehensive configuration system supporting multiple profiles (default, server, ct, aaa). The setup is heavily templated using Go's text/template syntax with machine-specific customizations, external tool management via mise, keyboard customization via Karabiner, and IDE/editor configurations for IntelliJ, Zed, LunarVim, and Ghostty terminal.

**Key Statistics:**
- Root directory: `home/` (chezmoi source root)
- Multiple profiles: default, server, ct, aaa
- Template variables defined in: `.chezmoi.yaml.tmpl`
- Installation scripts: 6 scripts across 2 directories (00-run-before, 01-common)
- Configured editors: IdeaVim, LunarVim, Zed, Vim
- Keyboard manager: Karabiner (macOS-specific, device-targeted mappings)

---

## Chezmoi Configuration

### Root Setup

**File:** `/Users/schmas/.local/share/chezmoi/.chezmoiroot`
- Content: `home` (indicates source root is the home/ directory)
- This means all dotfiles are under `home/` subdirectory

**File:** `/Users/schmas/.local/share/chezmoi/home/.chezmoi.yaml.tmpl`
- Interactive template that prompts during `chezmoi init`
- Prompts for:
  1. **Profile choice:** 1-default (default), 2-server
  2. **NIX-CONFIG integration:** Boolean (default: true)
  3. **Default editor:** 1-none, 2-nvim, 3-zed, 4-code (default: 2-nvim)
- Template variables exported:
  - `os_id`: System OS ID (e.g., "darwin", "linux-ubuntu")
  - `os_id_like`: Fallback OS identification
  - `using_nix`: Whether Nix integration enabled
  - `profile`: Selected profile (default, server, ct, aaa)
  - `is_p_default`, `is_p_server`, `is_p_ct`, `is_p_aaa`: Boolean flags per profile
  - `is_p_csaa`: Always false (legacy?)
- Edit command configured based on selected editor

### External Dependencies

**File:** `/Users/schmas/.local/share/chezmoi/home/.chezmoiexternal.toml`
- Currently commented out
- Was intended for external archive management (e.g., Neovim lazy config)
- Format example: Type=archive, URL fetching, auto-refresh intervals

### Ignore/Remove Rules

**File:** `/Users/schmas/.local/share/chezmoi/home/.chezmoiignore`
- Ignores:
  - `README.md`, `docs/`, `etc/`, `__*` files
  - Conditional OS-specific ignores:
    - On non-Darwin: ignore `bin/macos/`, Karabiner assets, `Library/`
    - On non-Linux: ignore `bin/linux/`

**File:** `/Users/schmas/.local/share/chezmoi/home/.chezmoiremove`
- Empty (single newline only)

### Installation Scripts

**Location:** `/Users/schmas/.local/share/chezmoi/home/.chezmoiscripts/`

**00-run-before/ (runs before chezmoi apply):**

1. **`run_before_00_configure_1password.sh`** (28 LOC)
   - Checks if `op` CLI installed
   - If no 1Password account found, prompts for:
     - Email address
     - Secret Key
   - Adds account to 1Password using: `op account add --address "my.1password.com"`
   - Used for secure credential retrieval in subsequent scripts

**01-common/ (runs after chezmoi apply):**

1. **`run_after_00-local-files.sh.tmpl`** (68 LOC templated)
   - Creates local config files from templates if missing:
     - `~/.config/git/config` from `gitconfig.template`
     - `~/.ssh/config` from `ssh_config.template`
     - `~/.gnupg/gpg-agent.conf` from template
     - `~/.npmrc` from template
     - `~/.config/fish/config_local.fish` from template
     - `~/.config/bash/bashrc_local` from template
     - `~/.config/zsh/zshrc_local` from template
   - macOS-specific: Creates `/Library/LaunchDaemons/limit.maxfiles.plist` (file descriptor limits)
   - Ensures proper permissions (700 for dirs, 600 for files)

2. **`run_once_after_01-mise-install.sh.tmpl`** (29 LOC)
   - Sets up mise (version manager) if installed
   - Commands:
     - `mise use -g usage` (sets global usage tool)
     - Generates Fish shell completions: `mise completion fish > ~/.config/fish/completions/mise.fish`
     - Runs `mise install` with retry logic (max 5 attempts, 2-second delays)
   - Marked as `run_once` - only runs on first apply

3. **`run_once_after_02-install-fisher.fish.tmpl`** (6 LOC)
   - Installs Fisher (Fish shell package manager) if not present
   - Uses official Fisher installer script

4. **`run_once_after_02.1-some-fish-setup.fish.tmpl`** (5 LOC)
   - Clears Fish shell welcome message: `set -U fish_greeting ""`
   - Persistent universal variable

5. **`run_once_after_05-nvim_lazy-install.sh.tmpl`** (12 LOC)
   - Clones Neovim lazy config if not exists
   - Repository: `https://github.com/schmas/nvim_lazy.git`
   - Clones to: `~/.config/nvim`

---

## Karabiner (Keyboard Customization)

**File:** `/Users/schmas/.local/share/chezmoi/home/dot_config/private_karabiner/private_karabiner.json` (125 LOC)
- macOS keyboard customization tool configuration
- Contains: 1 default profile (selected=true)

### Key Mappings (Device-Specific)

**Device 1: Vendor 0x46D (Logitech), Product 0xC52B (50503)**
- Simple modifications:
  - `left_command` ↔ `left_option` (swap)

**Device 2: Vendor 0x46D (Logitech), Product 0xC337 (50007)**
- Simple modifications:
  - `left_command` ↔ `left_option` (swap)

### Complex Modifications

**Swap Command and Control in Remote Access Apps**
- Applies to:
  - Microsoft RDC (Remote Desktop Connection): `com.microsoft.rdc.mac`, `com.microsoft.rdc.macos`
  - Ericom BlazeCLIENT: `com.ericom.blazeclient`
- Mappings (bidirectional):
  - `left_control` ↔ `left_command`
  - `right_control` ↔ `right_command`
- Purpose: Fixes key bindings when using VM/RDP (swap Control and Command locally to match remote behavior)

---

## Editor Configurations

### IdeaVim (IntelliJ IDEA Vim Emulation)

**File:** `/Users/schmas/.local/share/chezmoi/home/dot_ideavimrc` (357 LOC)

**Core Settings:**
- Leader key: Space
- Plugin ecosystem enabled: surround, highlightedyank, sneak, nerdtree, easymotion, which-key
- Which-key font size: 16pt, custom colors (cyan, pink)

**Key Keymaps (Space-prefixed):**
- `<leader>x` - Toggle NERDTree file explorer
- `<leader>j` - Easymotion jump
- `<leader>c` - Comment line
- `<leader>z` - Folding (zc=collapse, zo=expand all)
- `<leader>w` - Window splits (wv=vertical, ws=horizontal, wu=unsplit, wm=move editor)
- `<leader>d` - Display options (dz=zen mode, dd=distraction-free, df=fullscreen)
- `<leader>a` - Actions (am=context menu, as=search)
- `<leader>f` - File navigation (ff=go to file, fc=search content, fr=recent, fl=locations)
- `<leader>r` - Refactoring (rn=rename, rm=extract method, rv=introduce variable, rf=field, rs=signature, rr=list)
- `<leader>g` - Go to code (gd=definition, gy=type, gi=implementation, gu=usages, gt=test, gb=back, gf=forward)
- `<leader>e` - Error navigation (en=next, ep=previous)
- `<leader>q` - Close tab
- `<leader>y` - Yank to system clipboard
- `jk`/`kj` - Exit insert mode
- `n`/`N` - Find and center

**General Settings:**
- Relative line numbers, break indent, smart case
- System clipboard sync (Darwin-specific: `set clipboard=unnamed`)
- Colorscheme: wildcharm, dark background
- Mouse enabled, spell checking (en_us, de_de, es_es)

### LunarVim Configuration

**File:** `/Users/schmas/.local/share/chezmoi/home/dot_config/lvim/config.lua` (20 LOC)

**Settings:**
- Display listchars enabled (visual whitespace)
  - Tabs: `>-`
  - Trailing spaces: `.`
  - Extended lines: `>`
  - Preceding truncation: `<`
  - Space chars: `.`
  - Concealed text: `┆`
- Relative line numbers enabled

**Notes:** Minimal configuration, likely extends from LunarVim defaults. References official docs and community forums.

### Zed Editor Configuration

**File:** `/Users/schmas/.local/share/chezmoi/home/dot_config/zed/private_settings.json` (48 LOC)

**Theme & UI:**
- Theme: "macOS Classic Dark2"
- Base keymap: JetBrains (emulates JetBrains IDE key bindings)
- Vim mode: Disabled
- Font size: UI 16pt, buffer (editor) 16pt
- Whitespace display: "all"
- Tab size: 2 spaces

**Features:**
- Inline completions: Zed's provider
- Inlay hints enabled (lifetime elision, closure return types)
- Rust analyzer config with `analyzerTargetDir` optimization
- LSP integration for Rust

**Terminal Integration:**
- Font: MesloLGM Nerd Font Mono
- Font size: 14pt
- Environment variables:
  - `ZED=1`
  - `TERM_PROGRAM=ZedTerm`
- Remove trailing whitespace on save

### Vim Configuration

**File:** `/Users/schmas/.local/share/chezmoi/home/dot_vimrc` (5 LOC)
- Syntax highlighting enabled
- Filetype detection and plugin loading
- Wrap gitcommit files at proper length

---

## Terminal & Shell Configurations

### Starship Prompt

**File:** `/Users/schmas/.local/share/chezmoi/home/dot_config/starship.toml` (184 LOC)

**Layout:**
- Left prompt: username, hostname, directory, git branch, git status, fill, shell
- Right prompt: command exit status, command duration, time
- Custom color palette: mine (yellow, green, blue accents)

**Module Styling:**
- Directory: 3-level truncation, repo-root aware, fish-style pwd
- Git branch: Green, with status indicators
- Git status: Yellow with ahead/behind/staged/modified/untracked counts
- Shell indicator: Fish shell shows 󰈺 icon in cyan bold
- Time: 24-hour format (HH:MM), disabled by default (can enable)
- Status/error display: Shows non-zero exit codes with ✖ symbol
- Command duration: Shows with ⧖ prefix

**Language Symbols:**
- Python, Node.js, Go, Rust (🦀), Java, Dart, Elm, Haskell, etc.
- Nix shell indicator enabled
- Docker context, AWS, Buf protocol buffers

### Readline Configuration

**File:** `/Users/schmas/.local/share/chezmoi/home/dot_inputrc` (69 LOC)
- Used by Bash, Fish, other readline-based shells
- Completion behavior:
  - Case-insensitive tab completion
  - Show all matches if ambiguous
  - Mark symlinked directories
  - Skip hidden files unless dot-prefixed
  - No page breaks (show all at once, max 200 items)
  - Visible file stats (like `ls -F`)
- History search: Alt+Up/Down searches backward/forward in command history
- Key bindings for navigation:
  - Meta+Delete: Kill word backward
  - Escape sequences for Home/End/Page Up/Down/Delete
- UTF-8 support enabled

### Ghostty Terminal Emulator

**File:** `/Users/schmas/.local/share/chezmoi/home/dot_config/ghostty/config` (39 LOC)

**Theme & Display:**
- Theme: "Builtin Pastel Dark"
- macOS icon: Official Apple style
- Background opacity: 0.9
- Window dimensions: 130 columns × 40 rows
- Window state: Always save (restore on launch)

**Font Configuration:**
- Primary fonts (fallback chain):
  1. JetBrainsMono Nerd Font Mono
  2. GeistMono Nerd Font
  3. MesloLGL Nerd Font Mono
- Font size: 16pt
- Ligatures disabled: `-liga`
- Font thickening enabled

**Cursor & Shell Integration:**
- Cursor style: Block, non-blinking
- Shell integration: No cursor (custom cursor handling)

**System Integration:**
- Auto-update: Download new versions
- Confirm on close: Disabled
- macOS option key as Alt: Enabled
- Cursor style: Block

---

## Tool Configurations

### Mise (Version Manager)

**File:** `/Users/schmas/.local/share/chezmoi/home/dot_config/mise/config.toml` (23 LOC)

**Managed Tools:**
- **Languages/Runtimes:**
  - Node.js: lts
  - Python: (not explicitly listed, likely via tool dependency)
  - Go: latest
  - Java: corretto-23 (Amazon Corretto)
  - Rust: latest
  - Bun: latest

- **Build Tools:**
  - Maven: 3
  - Cargo tools:
    - cargo-update (latest)
    - rust-script (latest)

- **CLI Tools:**
  - age (encryption, latest)
  - direnv (env management, latest)
  - sops (secret ops, latest)
  - usage (CLI documentation, latest)

- **NPM Global Packages:**
  - aicommit2 (AI commit message generator)
  - prettier (code formatter)
  - @google/gemini-cli (Gemini AI CLI)
  - rulesync (sync rules tool)
  - @fission-ai/openspec (OpenSpec tool)
  - opencode-ai (AI code tools)
  - claudekit-cli (Claude AI toolkit CLI)

**Settings:**
- Experimental features enabled

### 1Password CLI Integration

**Directory:** `/Users/schmas/.local/share/chezmoi/home/dot_config/private_1Password/private_ssh/`
- SSH key management through 1Password
- 1Password account setup handled by pre-script
- Used for retrieving secrets (e.g., Nix flakehub token in `nix.conf.tmpl`)
- Function: `onepasswordRead "op://vault/item-id/field"`

### Nix Configuration

**File:** `/Users/schmas/.local/share/chezmoi/home/dot_config/nix/nix.conf.tmpl` (1 LOC)
- Retrieves GitHub access token from 1Password vault
- Path: `op://Dotfiles/lzlakqn35xiz2wptj56mhtghdy/Tokens/nix_flakehub`
- Sets `access-tokens` for Flakehub integration
- Templated to inject secret at apply time

### Atuin Configuration

**File:** `/Users/schmas/.local/share/chezmoi/home/dot_config/atuin/private_config.toml` (269 LOC)
- Shell history search and sync tool
- (Full content review needed for details)

---

## Project Structure & Conventions

### Directory Organization

```
/Users/schmas/.local/share/chezmoi/
├── home/                              # Chezmoi source root (.chezmoiroot = "home")
│   ├── .chezmoi.yaml.tmpl            # Interactive init config
│   ├── .chezmoiexternal.toml         # External deps (commented)
│   ├── .chezmoiignore                # Files to exclude
│   ├── .chezmoiremove                # Files to remove
│   ├── .chezmoiscripts/               # Installation scripts
│   │   ├── 00-run-before/            # Pre-apply scripts
│   │   └── 01-common/                # Post-apply scripts
│   ├── dot_*                          # Dotfiles (. prefix)
│   ├── dot_config/                   # ~/.config/ files
│   │   ├── karabiner/
│   │   ├── ghostty/
│   │   ├── starship.toml
│   │   ├── mise/
│   │   ├── nix/
│   │   ├── lvim/
│   │   ├── zed/
│   │   ├── atuin/
│   │   ├── fish/
│   │   ├── bash/
│   │   ├── zsh/
│   │   └── [others]
│   ├── bin/                           # Executable scripts
│   │   ├── macos/                    # macOS-specific scripts
│   │   └── linux/                    # Linux-specific scripts
│   ├── private_Library/              # ~/Library/ (macOS)
│   ├── private_dot_ssh/              # ~/.ssh/ with private markers
│   └── projects/
├── README.md                         # Installation & usage guide
├── SHELL-REFERENCE.md               # Comprehensive shell alias/function docs
├── docs/                             # Project documentation
├── etc/                              # Other configuration
└── .git/                             # Git repository

```

### Naming Conventions

- **Private directories/files:** Prefixed with `private_`
  - `private_karabiner/` → `~/.config/karabiner/`
  - `private_Library/` → `~/Library/`
  - `private_dot_ssh/` → `~/.ssh/`
  - `private_config.toml` → hidden config file
  - `private_settings.json` → hidden settings

- **Dotfiles:** Prefixed with `dot_`
  - `dot_ideavimrc` → `~/.ideavimrc`
  - `dot_vimrc` → `~/.vimrc`
  - `dot_inputrc` → `~/.inputrc`
  - `dot_config/` → `~/.config/`
  - `dot_*` files use chezmoi's built-in dot prefix handling

- **Templates:** Suffixed with `.tmpl` or `.tmpl.fish`, `.tmpl.sh`
  - Processed with Go text/template + chezmoi functions
  - `onepasswordRead()` for secrets
  - Conditional logic with `{{ if eq .chezmoi.os "darwin" }}`

- **Scripts:** Named per chezmoi convention
  - `run_before_*` - Before apply
  - `run_after_*` - After apply
  - `run_once_*` - Only on first apply
  - Extension patterns: `.sh`, `.fish`, `.tmpl` variants

### Chezmoi Features Used

1. **Templating:** Go text/template with custom functions
2. **Profile System:** Different configs per machine type
3. **Conditional Logic:** OS-based, profile-based, feature-based
4. **Scripts:** Automatic setup with ordering (00-run-before → 01-common)
5. **Ignore/Remove Rules:** Clean up non-applicable files
6. **External Integration:** 1Password, mise, Fisher
7. **Source Path Tracking:** For debugging via `chezmoi source-path`
8. **Dry-run Support:** `chezmoi apply --dry-run --verbose`

---

## Unresolved Questions

1. **Commented External Archive:** What was the intention for `nvim_lazy` external archive config? Is it still needed or should be removed?
2. **Legacy `is_p_csaa` variable:** Why is `is_p_csaa` hardcoded to false in template? Is this a deprecated profile?
3. **Karabiner Device IDs:** What are the exact keyboard models for product IDs 50503 and 50007? (Vendor 0x46D is Logitech)
4. **Atuin Config Details:** The 269-line config file wasn't fully reviewed; unclear what features/syncing enabled.
5. **Fish Config Locals:** What specific local machine configurations are expected in `config_local.fish`, `bashrc_local`, `zshrc_local` templates?
6. **Git Template:** What's in `gitconfig.template` and `ssh_config.template`?
7. **LaunchDaemon:** Why set macOS file descriptor limits via LaunchDaemon? Is this for specific tools?
8. **Nvim Lazy Repo:** Is `schmas/nvim_lazy` a personal fork or does it track upstream?

