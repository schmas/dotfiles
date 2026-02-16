# PROJECT KNOWLEDGE BASE

**Generated:** 2026-02-14
**Commit:** 1e7ca50
**Branch:** main

## OVERVIEW

Chezmoi-managed dotfiles for cross-platform (macOS/Linux) multi-shell (Fish/Zsh/Bash) configuration. Secrets via 1Password templates. 4 profiles (default/server/ct/aaa) for per-machine customization.

## STRUCTURE

```
./
├── home/                       # Chezmoi source root (via .chezmoiroot)
│   ├── .chezmoi.yaml.tmpl      # Init prompts: profile, editor, nix
│   ├── .chezmoiignore          # OS/tool conditional file exclusion
│   ├── .chezmoiremove          # Deprecated file cleanup
│   ├── .chezmoiexternal.toml   # External archives (nvim_lazy, disabled)
│   ├── .chezmoiscripts/        # Pre/post-apply automation (15 scripts)
│   ├── .chezmoitemplates/      # Reusable template partials
│   ├── Brewfile                # All packages (203 lines, triggers onchange)
│   ├── bin/                    # 36 utility scripts
│   ├── dot_config/             # 19 app configs, 120 files
│   ├── dot_claude/             # Claude Code skills & env
│   ├── private_dot_ssh/        # SSH public keys from 1Password
│   ├── private_Library/        # macOS LaunchAgents, KeyBindings
│   ├── tools/                  # Docker Compose stacks (Ollama, Stirling PDF)
│   └── projects/work/aaa/     # AAA profile workspace config
├── docs/                       # 7 guides (3,129 LOC total)
├── .github/workflows/          # 1 workflow: sync bootstrap gist
└── plans/                      # Empty (task tracking)
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add a package | `home/Brewfile` | `brew "name"` or `cask "name"`, auto-installs on `chezmoi apply` |
| Add a shell alias | `home/dot_config/private_{zsh,bash}/conf.d/99-aliases.*.tmpl` | MUST be identical across Zsh/Bash |
| Add a Fish abbreviation | `home/dot_config/private_fish/conf.d/10-abbr.fish` | Update SHELL-REFERENCE.md too |
| Add env variable (shared) | `home/dot_config/private_env/10-shared.env.tmpl` | Sourced by all shells via POSIX glob |
| Add API token/secret | `home/dot_config/private_env/15-services.env.tmpl` | Use `{{ onepasswordRead "op://..." }}` |
| Add new tool config | `home/dot_config/{tool}/` | Create dir, add config files |
| Add install script | `home/.chezmoiscripts/01-common/` | See naming conventions below |
| Add utility script | `home/bin/executable_{name}` | `executable_` prefix = chmod 755 |
| Modify profile logic | `home/.chezmoi.yaml.tmpl` | Boolean flags: `is_p_default`, etc. |
| OS-specific config | `**/20-os.{darwin,linux}.*` | Separate file per OS, numeric prefix 20 |
| Git config (personal) | `home/dot_config/git/config.main.tmpl` | 1Password for email + signing key |
| Git config (AAA work) | `home/dot_config/git/config.aaa.tmpl` | Profile-specific identity |
| Debug template output | Run `chezmoi execute-template < file.tmpl` | |

## CONVENTIONS

**Chezmoi prefixes** — `dot_` (→`.file`), `private_` (sensitive), `executable_` (755). `.tmpl` suffix = Go template.

**Shell config load order** (numeric prefix, ALL shells):
```
00-*  Homebrew, plugin managers
05-*  Shared env (sources ~/.config/env/*.env)
10-*  Common env, PATH, aliases/abbreviations
20-*  OS-specific (darwin/linux)
49-*  Input/keybindings (Zsh only)
50-*  Completions
70-*  Tool init (Starship, Zellij)
98-*  Plugin managers (Sheldon/Fisher)
99-*  Aliases (always last)
zzz-* Late-load (Mise, FZF, Atuin)
```

**Template patterns:**
```go
{{ if eq .chezmoi.os "darwin" }}...{{ end }}     // OS detection
{{ if .is_p_default }}...{{ end }}               // Profile conditional
{{ onepasswordRead "op://Vault/item/field" }}    // Secret injection
{{ include "Brewfile" | sha256sum }}             // File hash (onchange trigger)
```

**Commit messages:** Conventional commits — `feat(scope):`, `fix(scope):`, `docs:`, `chore:`, `refactor:`

## ANTI-PATTERNS (THIS PROJECT)

- **NEVER** hardcode secrets — always `onepasswordRead` in `.tmpl` files
- **NEVER** break Zsh/Bash alias parity — they MUST be identical
- **NEVER** skip numeric prefix on shell conf.d files — breaks load order
- **NEVER** commit `*_local` files — they're for user overrides only
- **NEVER** use direct paths in shebangs — use `#!/usr/bin/env {shell}`
- **NEVER** assume tool availability — guard with `command -v tool`

## UNIQUE STYLES

- **Centralized env vars:** `private_env/*.env.tmpl` sourced by all shells (not per-shell duplication)
- **Symlink rc files:** `~/.zshrc` → `~/.config/zsh/zshrc` (XDG-compliant home dir)
- **Fish abbreviations** over aliases — they expand inline on space
- **Brewfile hash trigger:** `run_onchange_before_02` re-runs only when Brewfile SHA changes
- **Sudo session management:** Background process keeps sudo alive during long installs
- **Plugin managers split:** Fisher (Fish), Sheldon (Zsh/Bash) — not unified

## COMMANDS

```bash
chezmoi apply --dry-run --verbose  # Preview changes
chezmoi apply                      # Apply configuration
chezmoi status                     # Check diff since last apply
chezmoi update                     # Pull and apply latest
chezmoi execute-template < f.tmpl  # Debug template output
upall                              # Master update: OS + brew + mise + rust + chezmoi + claude + fisher + atuin
```

## DEEP DIVES

Detailed knowledge for specific areas:

| Document | Scope |
|----------|-------|
| [docs/agents-dot-config.md](docs/agents-dot-config.md) | Shell architecture, app configs, 1Password secrets |
| [docs/agents-bin.md](docs/agents-bin.md) | Utility scripts, git extensions, naming conventions |
| [docs/agents-scripts.md](docs/agents-scripts.md) | Chezmoi script naming, execution order, triggers |

## NOTES

- `.chezmoiroot` points to `home/` — repo root has docs/plans, actual dotfiles are in `home/`
- Profile `ct` and `aaa` purposes: `aaa` = AAA Connect+ work profile, `ct` = unclear/legacy
- Tmux config is oh-my-tmux framework (1,891 lines) — don't modify `tmux.conf`, use `tmux.conf.local`
- `is_p_csaa` in `.chezmoi.yaml.tmpl` is hardcoded `false` — appears deprecated
- Karabiner mods are Citrix-specific (print screen, Ctrl+Alt remapping)
- Nushell config is minimal (3 lines) — experimental shell support
- `.chezmoiexternal.toml` has nvim_lazy commented out — Neovim config managed separately
