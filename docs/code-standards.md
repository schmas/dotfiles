# Code Standards & Development Guidelines

## File Naming Conventions

### Chezmoi Special Prefixes

| Prefix | Meaning | Example | Result |
|--------|---------|---------|--------|
| `dot_` | Dotfile (. prefix) | `dot_ideavimrc` | `~/.ideavimrc` |
| `private_` | Private/sensitive file | `private_fish/` | `~/.config/fish/` |
| `executable_` | Executable script | `executable_my_script` | `~/bin/my_script` (755) |
| No prefix | Regular file | `README.md` | `README.md` |
| `*.tmpl` | Template file | `config.fish.tmpl` | Processed at apply time |

### Shell Configuration Files

```
Execution order (numeric prefix determines load timing):
00-*  → Installation/setup (Fisher auto-install)
10-*  → Common environment (LANG, EDITOR, PATH)
20-*  → OS-specific configs (darwin/linux variants)
49-*  → Input/keybindings (Zsh)
50-*  → Completions
70-*  → Tool-specific (Zellij, Starship)
98-*  → Plugin managers (Sheldon, Starship)
99-*  → Aliases (always last)
zzz-* → Fish late-loading (Carapace, FZF, Mise)
```

### Custom Script Files

```
run_before_*        → Execute before chezmoi apply
run_after_*         → Execute after chezmoi apply
run_once_*          → Execute only on first apply (idempotent)
Extensions: .sh, .fish, .tmpl (for templating)
```

## Shell Script Standards

### Fish Shell

**Entry Point:** `private_fish/config.fish`
- Sources all `.fish` files from `conf.d/` in alphabetical order
- Sources `conf.d/*.fish.tmpl` after processing
- Loads `functions/` automatically
- All functions use kebab-case naming (e.g., `setup-fifc-fzf`)

**Configuration Modules:**
- Use `source` to load configs: `source $__fish_confdir/10-common.env.fish`
- Template syntax: `{{ if eq .chezmoi.os "darwin" }}`
- Universal variables for persistence: `set -U fish_greeting ""`
- Abbreviations preferred over aliases in Fish

**Functions:**
- Store in `private_fish/functions/` with `.fish` extension
- Use `function name` syntax, avoid `function name --description`
- Export functions that need to be called: `funcsave function_name`
- Private functions prefix with `_`: `function _private_helper`

**Plugins (Fisher):**
- Manifest in `fish_plugins` (one per line)
- Auto-installed via `00-install_fisher.fish`
- Custom forks supported (e.g., `schmas/fifc`)

### Zsh & Bash Shell

**Entry Points:**
- Zsh: `private_zsh/zshrc` (sources conf.d/ modules)
- Bash: `private_bash/bashrc` (sources conf.d/ modules)

**Configuration Modules:**
- Use `source` to load configs
- Zsh-specific opts in `10-common.env.zsh.tmpl`: `setopt HIST_SAVE_NO_DUPS`
- Template syntax same as Fish

**Functions:**
- Define in `private_{shell}/functions/` with appropriate extension
- Zsh functions can use autoload (see `zshrc` for examples)
- Exported to PATH via `fpath`

**Plugins (Sheldon):**
- Manifest in `etc/sheldon/plugins.toml` (TOML format)
- Initialized in `98-sheldon.{zsh,bash}`
- Supports complex plugin interdependencies

### Aliases vs Functions

| Use Case | Convention |
|----------|-----------|
| Simple command replacement | Alias/abbreviation |
| Command with arguments | Alias with `'cmd arg'` |
| Complex logic/conditionals | Function |
| Multi-line operations | Function |
| Interactive usage | Abbreviation (Fish) |
| Scripting | Alias |

**Good Alias Examples:**
```fish
# Fish abbreviations (expand on spacebar)
abbr -a g git
abbr -a gaa git add --all

# Zsh aliases
alias l="ls -la"
alias ni="npm install"
```

**Good Function Examples:**
```fish
# Fish function (multicd example)
function multicd
    while true
        if test -d "$(pwd)/$(string repeat -n (echo $argv | wc -w) ../)"
            # ... logic
        end
    end
end
```

## Configuration File Standards

### TOML (Mise, Sheldon, Atuin)

**Format:**
```toml
# Use [sections] for clarity
[tools]
node = "lts"
python = "3.11"

# Comments explain non-obvious settings
tools = { cargo-update = "latest" }
```

**Best Practices:**
- Comments for version choices (e.g., why `corretto-23` for Java)
- Group related settings in sections
- Use inline tables for simple key-value pairs

### JSON (Karabiner, Zed)

**Format:**
```json
{
  "profiles": [
    {
      "name": "Default profile",
      "selected": true,
      "simple_modifications": []
    }
  ]
}
```

**Best Practices:**
- Two-space indentation
- Meaningful field names (avoid abbreviations)
- Comments explain non-obvious configurations

### YAML (Lazygit)

**Format:**
```yaml
git:
  pager:
    colorArg: always

  customCommands:
    - key: "<c-g>"
      command: "aicommit2 --clipboard"
```

**Best Practices:**
- Consistent indentation (two spaces)
- Use quotes for strings with special characters
- Group related configs under parent keys

### KDL (Zellij)

**Format:**
```kdl
ui {
  pane_frames {
    hide_session_name false
  }
}

keybinds "normal" {
  bind "Alt n" { NewPane; }
}
```

**Best Practices:**
- Use nested blocks for logical grouping
- Bind descriptions for complex key combinations
- Comment non-obvious keybinding choices

## Template Syntax Standards

### Chezmoi Go Templates

**Variable Substitution:**
```go
{{ .chezmoi.os }}              // "darwin" or "linux"
{{ .profile }}                 // "default", "server", "ct", "aaa"
{{ .using_nix }}               // Boolean: true/false
{{ .is_p_default }}            // Profile-specific boolean flags
{{ onepasswordRead "op://Dotfiles/github-token" }}  // Secret retrieval
```

**Conditional Logic:**
```go
{{ if eq .chezmoi.os "darwin" }}
# macOS-specific config
{{ else }}
# Linux-specific config
{{ end }}

{{ if .using_nix }}
# Nix-specific setup
{{ end }}
```

**Multi-line Conditionals:**
```go
{{ if eq .chezmoi.os "darwin" -}}
export PATH="/usr/local/bin:$PATH"
{{ - end }}
```

**Template Files Pattern:**
- Name files with `.tmpl` suffix: `config.fish.tmpl`, `10-common.env.fish.tmpl`
- Keep templates readable; avoid excessive nesting
- Comment complex conditionals

## Environment Variables

### Standard Variables (All Shells)

| Variable | Value | Purpose |
|----------|-------|---------|
| `LANG` | `en_US.UTF-8` | Locale setting |
| `LANGUAGE` | `en_US.UTF-8` | Fallback locale |
| `LC_TIME` | `en_US.UTF-8` | Time format |
| `VISUAL` | `nvim` | Visual editor |
| `EDITOR` | `nvim` or `vim` | Line editor |
| `SYSTEMD_EDITOR` | `$EDITOR` | Systemd editor |
| `CLICOLOR` | `1` | Enable colored output |
| `GPG_TTY` | `$(tty)` | GPG terminal for pinentry |
| `OPENCV_LOG_LEVEL` | `ERROR` | Suppress OpenCV logging |

### Tool-Specific Variables

| Tool | Variable | Set In | Purpose |
|------|----------|--------|---------|
| Mise | `MISE_GITHUB_TOKEN` | Fish (1Password) | GitHub package access |
| Homebrew | `HOMEBREW_GITHUB_TOKEN` | Fish (1Password) | Faster downloads |
| FZF | `FZF_DEFAULT_COMMAND` | All shells | Use `fd` instead of `find` |
| Zsh | `ZSH_CACHE_DIR` | `10-common.env.zsh` | Completion cache |
| Fish | `EZA_COLORS` | `10-colors.fish` | Eza color scheme |

### OS-Specific Variables

**macOS (20-os.darwin.env.*):**
- `HOMEBREW_PREFIX` (typically `/usr/local` or `/opt/homebrew`)
- `COREUTILS_PREFIX` (for GNU coreutils)
- Karabiner config paths

**Linux (20-os.linux.env.*):**
- Distro-specific package manager vars
- WAYLAND vs X11 detection

## Alias & Abbreviation Standards

### Naming Convention

**Git Aliases** (3 char max):
- `g` = `git`
- `gaa` = `git add --all`
- `gc` = `git commit`
- `gco` = `git checkout`
- `gsw` = `git switch`

**NPM Aliases** (consistent with tradition):
- `ni` = `npm install`
- `nr` = `npm run`
- `nrt` = `npm run test`

**Directory Navigation** (3-5 char):
- `home` = `cd ~`
- `configd` = `cd ~/.config`
- `fishd` = `cd ~/.config/fish`

**Tool Shortcuts:**
- `ij` = `idea` (IntelliJ)
- `ws` = `webstorm`
- `rr` = `rustrover`

### Implementation Location

| Shell | Implementation | File |
|-------|----------------|------|
| Fish | Abbreviations (abbr) | `10-abbr.fish` |
| Zsh | Aliases (alias) | `99-aliases.zsh.tmpl` |
| Bash | Aliases (alias) | `99-aliases.bash.tmpl` |

**Rule:** Zsh and Bash aliases MUST be identical (shared logic from template)

## Cross-Platform Compatibility

### OS Detection

**Fish:**
```fish
if [ (uname) = "Darwin" ]
    # macOS-specific code
end
```

**Zsh/Bash:**
```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS-specific code
fi
```

**Chezmoi Template:**
```go
{{ if eq .chezmoi.os "darwin" }}
# macOS-specific config
{{ end }}
```

### Conditional Configuration Files

- Separate files per OS: `20-os.darwin.env.fish`, `20-os.linux.env.fish`
- Source order ensures proper override: common → os-specific
- Use templating for complex conditionals in single file

### Tool Availability Checks

```fish
# Fish: check if tool exists
if command -v nvim &> /dev/null
    set -gx EDITOR nvim
end
```

```bash
# Bash: check if tool exists
if command -v nvim &> /dev/null; then
    export EDITOR=nvim
fi
```

## Function & Utility Standards

### Function Documentation

Recommended format (Fish example):
```fish
function my_function
    # Short description
    # Usage: my_function [args...]
    # Returns: exit code

    # Implementation
end
```

### Error Handling

**Fish:**
```fish
function safe_operation
    if not command -v required_tool &> /dev/null
        echo "Error: required_tool not found" >&2
        return 1
    end
    # Safe operation
end
```

**Zsh/Bash:**
```bash
safe_operation() {
    if ! command -v required_tool &> /dev/null; then
        echo "Error: required_tool not found" >&2
        return 1
    fi
    # Safe operation
}
```

### Utility Scripts (bin/)

**Shebang:**
- `#!/usr/bin/env fish` (prefer env over direct path)
- `#!/usr/bin/env bash`
- Ensure executable bit: `chmod +x script_name`

**Error Codes:**
- `0` = Success
- `1` = General error
- `2` = Misuse of command
- Custom codes for specific failure modes

**Output:**
- Errors to stderr: `echo "error message" >&2`
- Status to stdout: `echo "success message"`
- Enable `set -euo pipefail` in Bash

## Secret Management Standards

### 1Password Integration

**Never hardcode secrets.** Always use templates:

```go
{{ onepasswordRead "op://Vault/item-name/field-name" }}
```

**Usage in Configs:**
```bash
# In git config template
[user]
    email = {{ onepasswordRead "op://Dotfiles/github/email" }}
    signingKey = {{ onepasswordRead "op://Dotfiles/github/signing-key" }}
```

**Local Overrides:**
- User-specific secrets in `*_local` files (not in repo)
- Templates used only for shared/environment secrets
- SSH keys, API tokens, passwords never in version control

## Security Standards

### File Permissions

| File Type | Permission | Reason |
|-----------|-----------|--------|
| SSH private key | 600 | Read-only by user |
| SSH public key | 644 | Readable by others |
| Config files | 600-644 | Prevent tampering |
| Shell scripts | 755 | Executable |
| GPG keys | 700 | Directory, restrictive |
| Sensitive data | 600 | Private only |

### Git Configuration

- All commits signed (`gpgsign = true`)
- SSH signing key (macOS), OpenPGP signing (Linux)
- Signing key stored in 1Password
- Backup/restore via GPG scripts

### Secrets Filtering

Atuin automatically filters:
- AWS keys (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
- GitHub PAT (ghp_, github_pat_)
- Slack tokens (xoxb-, xoxp-)
- Stripe keys (sk_live, pk_live)

## Documentation Standards

### Inline Comments

```fish
# Why we use this option
set -gx MISE_GITHUB_TOKEN (op read "op://...")

# When adding non-obvious abbreviations
abbr -a gaa git add --all  # Add all changes (stages)
```

### Function Comments

```fish
# Get AWS token expiration status
# Used to refresh tokens before expiry
function has_aws_token_expired
    # Implementation
end
```

### Configuration Comments

```toml
# Mise config - pins language/tool versions
[tools]
node = "lts"           # Latest LTS version
python = "3.11"        # Stable release
java = "corretto-23"   # Amazon Corretto preferred
```

## Maintenance & Updates

### Adding New Configurations

1. Create file with appropriate prefix (10-*, 20-*, etc.)
2. Add to corresponding conf.d/ directory
3. Use `.tmpl` suffix if requires variable substitution
4. Test with `chezmoi apply --dry-run --verbose`

### Updating Aliases

1. Edit `99-aliases.{zsh,bash}.tmpl`
2. Ensure identical logic across shells
3. Update `SHELL-REFERENCE.md` documentation
4. Add to `10-abbr.fish` for Fish equivalents

### Adding New Tool Integration

1. Create `dot_config/{tool}/` directory
2. Create config files with standard names
3. Document tool in relevant shell config (98-sheldon, etc.)
4. Add to `project-overview-pdr.md`

## Code Review Checklist

- [ ] File named per convention (kebab-case, appropriate prefix)
- [ ] Template syntax correct (if using `.tmpl`)
- [ ] No hardcoded secrets (use 1Password)
- [ ] Cross-platform compatible (or clearly documented as OS-specific)
- [ ] Comments explain non-obvious logic
- [ ] Aliases documented in SHELL-REFERENCE.md
- [ ] OS-specific code in separate files where possible
- [ ] File permissions correct (755 for scripts, 644 for configs)
- [ ] Load order respected (numeric prefixes)
- [ ] Tested with `chezmoi apply --dry-run`

## Unresolved Questions

1. **Test automation:** Should dotfile application be tested automatically?
2. **Backwards compatibility:** How to handle breaking config changes across profiles?
3. **Local config templates:** Should *_local templates be committed (with examples) or ignored?
4. **Plugin version pinning:** Should plugin versions be pinned in Fisher/Sheldon manifests?
