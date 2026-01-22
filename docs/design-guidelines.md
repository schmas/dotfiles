# Design Guidelines & Philosophy

## Core Philosophy

This dotfiles system is built on three foundational principles:

1. **Consistency** - Same configuration across all shells and machines
2. **Modularity** - Small, focused files that load in predictable order
3. **Automation** - Minimal manual setup; tools auto-install and configure

---

## Shell Configuration Philosophy

### Universal Principles

**All shells (Fish, Zsh, Bash) should:**
- Provide identical command aliases
- Use same environment variables (LANG, EDITOR, PATH)
- Support same tool integrations (Git, Atuin, FZF, Mise)
- Share visual prompt (Starship)
- Offer consistent keybindings where applicable

**Rationale:** A user switching shells shouldn't need to relearn commands or remember shell-specific aliases.

### Shell-Specific Flexibility

**Fish shell differences justified for:**
- Abbreviations (auto-expanding) - better UX for interactive shell
- Custom functions - different syntax is acceptable
- Keybindings - VI mode with custom fifc tab completion
- Plugin manager - Fisher has unique ecosystem

**Zsh shell differences justified for:**
- Completion system - fzf-tab is Zsh-optimized
- Sheldon plugins - richer ecosystem than Bash needs
- History features - substring and multi-word search

**Bash shell differences justified for:**
- Minimal setup - focus on compatibility over features
- Lean plugin set - server-friendly configuration
- Limited functions - scripting language different enough to avoid duplication

### Cross-Shell Consistency Rules

| Feature | Implementation | Status |
|---------|---|---|
| Command aliases | Identical in `99-aliases.*` | ✓ Required |
| Environment vars | Same across all shells | ✓ Required |
| PATH setup | Consistent order across shells | ✓ Required |
| Prompt | Starship (same for all) | ✓ Required |
| Git config | 1Password templates (identical) | ✓ Required |
| SSH config | Same across shells | ✓ Required |
| Functions/Utils | May differ (syntax constraints) | ✓ Acceptable |
| Keybindings | Shell-native, UI may differ | ✓ Acceptable |
| Completion | Shell-optimized approach | ✓ Acceptable |

---

## Configuration Organization

### File Placement Logic

**Question: Where should a new config go?**

```
Is it shell-specific?
├─ Yes, same logic for all shells?
│  └─ Create shared file in etc/ or use template
├─ Yes, different per shell?
│  └─ Create in private_{shell}/conf.d/
└─ No, tool-specific?
   └─ Create in dot_config/{tool}/
```

**Examples:**

- `10-common.env.fish.tmpl` - Shell-specific env vars (different per shell)
- `99-aliases.zsh.tmpl` - Shared aliases logic (identical across shells, templated)
- `dot_config/git/config.main.tmpl` - Tool-specific (not shell-dependent)
- `dot_config/atuin/config.toml` - App config (global, not shell-dependent)

### Module Load Order Design

```
00-*  Initialization      (Install managers, setup)
10-*  Environment         (Vars, PATH, common setup)
20-*  OS-Specific         (Darwin vs Linux)
49-*  Input/Keys (Zsh)    (Shell-specific features)
50-*  Completions         (Tab completion setup)
70-*  Tools               (Zellij, Starship if needed)
98-*  Plugin Managers     (Load all plugins)
99-*  Aliases             (Always last, override everything)
zzz-* Late Load (Fish)    (After everything)
```

**Design Rationale:**
1. Setup tools first (00)
2. Basic environment (10)
3. System-specific (20)
4. Interactive features (49-50)
5. External tools (70)
6. Plugin managers (98) - plugins can use all above
7. Aliases (99) - should override plugin aliases
8. Fish post-load (zzz) - catch anything missed

**Critical Rule:** Aliases MUST be last to ensure they override plugin aliases.

---

## Template Design Patterns

### When to Use Templates

**Use `.tmpl` suffix when:**
- Config needs profile-specific behavior
- Config needs OS-specific paths
- Config needs secrets from 1Password
- Config needs machine-specific variables

**Don't use `.tmpl` when:**
- Config is static across all machines
- Config is user-specific (goes in *_local)
- Config is tool-specific (not shell/profile dependent)

### Template Variable Scope

**Global (all machines/profiles):**
```go
{{ .chezmoi.os }}              // Safe to assume available everywhere
{{ .chezmoi.osRelease }}       // OS-specific details
```

**Profile-specific (only during init):**
```go
{{ .profile }}                 // Selected profile name
{{ .is_p_default }}            // Profile detection
{{ .using_nix }}               // Feature flag from init
```

**Secret injection (1Password):**
```go
{{ onepasswordRead "op://vault/item/field" }}
// Only for config that should have secrets
// Never for user-editable local files
```

### Template Placement

- **User-facing configs:** Don't template → Use *_local file
- **System-wide configs:** Template is OK
- **Secrets:** Always template
- **Machine-specific paths:** Template if commonly different

---

## Code Style Principles

### Shell Script Style

**Readability over cleverness:**
```fish
# Good - clear intent
if not command -v nvim &> /dev/null
    echo "Installing nvim..."
    install_nvim
end

# Avoid - clever but unclear
command -v nvim > /dev/null || install_nvim
```

**Consistent indentation:**
- 4 spaces for conditionals (shell standard)
- 2 spaces for TOML/YAML configs
- Tab for Makefiles only

**Meaningful comments:**
```fish
# Why this specific version
set -gx JAVA_VERSION "corretto-23"

# Avoid obvious comments
set -gx JAVA_VERSION corretto-23  # Set Java version
```

### Configuration File Style

**TOML:**
```toml
# Group related settings
[tools]
node = "lts"
python = "3.11"

# Use meaningful names
java = "corretto-23"  # Not java23, not jdk
```

**JSON:**
```json
{
  "readability": "is paramount",
  "indentation": "2 spaces",
  "comments": "add clarity for non-obvious settings"
}
```

**YAML:**
```yaml
# Logical section grouping
git:
  pager:
    colorArg: always

  customCommands:
    - key: "<c-g>"
      command: "aicommit2 --clipboard"
```

---

## Naming Conventions Design

### Why Chezmoi Prefixes?

| Prefix | Purpose | Rationale |
|--------|---------|-----------|
| `dot_` | Dotfiles | Clear at glance; maps to `~/.` |
| `private_` | Sensitive/hidden | Indicates not tracked in git |
| `executable_` | Scripts | Automatic chmod +x |
| `*.tmpl` | Template files | Processed before apply |

**Design principle:** Naming tells you behavior without reading file contents.

### Numeric Load Order Design

Numbers clearly communicate intent:

```
00 - Installation (first)
10 - Common (all machines)
20 - OS-specific (conditional)
...
99 - Overrides (last)
```

Without numbers, order would be alphabetical (bad):
- `10-common.env.fish` would load before `99-aliases.fish` (unclear why)
- `aliases.fish` would load before `common.env.fish` (wrong order!)

**Design principle:** Explicit ordering prevents magic.

---

## Customization Philosophy

### What Users Should Customize

**Safe to customize (via *_local files):**
- Shell aliases/functions for personal shortcuts
- Local environment variables
- Machine-specific PATH additions
- Personal keybindings

**Don't customize (use repo):**
- Standard aliases (shared across shells)
- Core environment variables
- Global configurations
- Tools and their settings

### Preventing Customization Conflicts

**Problem:** User edits `config.fish`, repo updates `config.fish`, conflict on `chezmoi apply`

**Solution:** Separate files by scope:
1. **Repo manages:** `10-common.env.fish`, `99-aliases.fish`
2. **User manages:** `config_local.fish`
3. **Main file sources both:** `config.fish` sources conf.d/ then config_local

**Design principle:** Repo and user files should never conflict.

---

## Security Design

### Secrets Handling

**Rule 1: Never hardcode secrets**
- All credentials stored in 1Password vault
- Injected via `{{ onepasswordRead }}` at apply time
- Files with secrets should have restricted permissions (600)

**Rule 2: Secrets only in applied configs**
- Templates generate secrets
- Templates are never committed
- Generated configs have restricted permissions

**Rule 3: Local overrides exempt from repo**
- *_local files not in git
- User can store local secrets without worrying about repo

### File Permissions Design

```
644 (rw-r--r--) - Public configs (shell, tools)
600 (rw-------) - Private configs (git, ssh, gpg)
755 (rwxr-xr-x) - Executable scripts
700 (rwx------) - Private directories (.ssh, .gnupg)
```

**Design principle:** Conservative defaults; relax only when needed.

### 1Password Integration

**Why 1Password for secrets?**
- Single source of truth for all credentials
- Same credentials accessible from multiple machines
- Credentials can be rotated without redeploying
- Encrypted locally and in transit
- Audit trail of access

**What NOT to store in 1Password:**
- Public configuration (tools, aliases)
- Non-sensitive environment variables
- Tool version pins

---

## Tool Integration Design

### Tool Selection Criteria

**Tools included if they:**
1. **Improve shell experience** (Starship, FZF, Atuin)
2. **Essential for development** (Git, SSH, GPG)
3. **Standard in modern workflows** (Mise, Lazygit, Yazi)
4. **Cross-platform available** (not macOS-only)
5. **Actively maintained** (not abandoned projects)

**Tools optional/conditional if:**
- Platform-specific (Karabiner for macOS)
- Profile-specific (Zellij for desktop, not servers)
- User preference (Vim vs Neovim)

### Tool Configuration Pattern

Each tool follows this pattern:

```
dot_config/{tool}/
├── {tool}.conf          # Main config
├── {tool}.local         # User overrides
└── [optional subfiles]  # Modular configs
```

**Apply order:**
1. Tool loads main config
2. Tool auto-sources .local file (if tool supports it)
3. User edits .local for customizations

**Design principle:** Tool configs follow same "repo + local override" pattern.

---

## Performance Design Goals

### Shell Startup < 1.5 seconds

**Optimization strategies:**
1. **Lazy loading** - Load plugins only when needed
2. **Caching** - Cache compilation results (Zsh)
3. **Selective execution** - Skip unnecessary checks
4. **Async operations** - Background updates

**Measurement points:**
- Time to shell prompt: < 1 second
- Time to first command: < 2 seconds
- Plugin loading overhead: < 0.5s per 10 plugins

### Preventing Slowness

**Don't:**
- Run network checks during shell init
- Execute slow external commands unconditionally
- Load all plugins eagerly
- Use inefficient loops in init

**Do:**
- Lazy-load plugins (on-demand)
- Cache expensive computations
- Use built-in features over external commands
- Profile startup with `time zsh -i -c exit`

---

## Documentation Design

### Documentation Scope

Each document has a clear purpose:

| Document | Audience | Focus |
|----------|----------|-------|
| README.md | New users | Quick start, links |
| deployment-guide.md | Installers | Step-by-step setup |
| project-overview-pdr.md | Project stakeholders | Goals, features, PDR |
| code-standards.md | Contributors | How to edit configs |
| system-architecture.md | Technical leads | How it works |
| codebase-summary.md | Maintainers | What exists where |
| design-guidelines.md | Designers | Why design choices |

**Design principle:** Each doc answers one main question.

### When to Add Documentation

Add docs when:
- New major feature added
- Architecture changed
- Questions from users indicate gap
- Someone asks "why is this like this?"

Update docs when:
- Code changes behavior
- New tool added
- Standard changes
- Unresolved question gets answered

---

## Platform Portability Design

### macOS vs Linux Handling

**Single codebase approach:**
- Same repo for macOS and Linux
- Conditional includes per OS
- Separate files per OS when significantly different
- CI testing on both platforms

**Fallback philosophy:**
- macOS: Use Homebrew, 1Password native features
- Linux: Use distro package manager, fallback tools
- Both: Support common tools (Git, SSH, etc.)

### Strategy for OS-Specific Features

**When feature is macOS-only:**
```go
{{ if eq .chezmoi.os "darwin" }}
    # macOS-specific config
{{ end }}
```

**When feature needs fallback:**
```bash
if command -v tool-macos &> /dev/null; then
    # Use macOS tool
else
    # Use fallback tool
fi
```

**Design principle:** One codebase, conditional execution.

---

## Future Design Principles

### Extensibility

System should be easy to extend with:
- New shells (Nushell, Elvish)
- New tools (additional LSPs, formatters)
- New profiles (specialized setups)
- New platforms (Windows WSL, Cygwin)

**Design goal:** Adding new tool shouldn't require rewriting existing configs.

### Maintainability

System should be easy to maintain by:
- Clear separation of concerns
- Comprehensive documentation
- Automated testing
- Explicit over implicit configuration

**Design goal:** Configs should be self-documenting and change-resistant.

### Usability

System should be easy to use by:
- Minimal first-time setup
- Clear error messages
- Good defaults
- Easy customization without forking

**Design goal:** Works well out-of-the-box, customizable without pain.

---

## Decision Making Framework

When making design decisions, ask:

1. **Consistency:** Does this choice align with existing patterns?
2. **Simplicity:** Is this the simplest solution?
3. **Maintainability:** Will future developers understand this?
4. **User Impact:** How does this affect user experience?
5. **Performance:** Does this slow down shell startup?
6. **Security:** Are secrets handled properly?
7. **Portability:** Works on macOS and Linux?
8. **Future-proof:** Will this work as the project grows?

If you can't answer "yes" to 6+ questions, reconsider the design.

---

**Last Updated:** Jan 22, 2026
**Version:** 1.0
**Status:** Active
