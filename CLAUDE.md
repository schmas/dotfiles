# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles managed by **chezmoi** for cross-platform shell configuration (Fish, Zsh, Bash) on macOS and Linux. All secrets are stored in 1Password and injected via templates.

## Essential Commands

```bash
# Preview changes before applying
chezmoi apply --dry-run --verbose

# Apply configuration changes
chezmoi apply

# Check what changed since last apply
chezmoi status

# Pull and apply latest from remote
chezmoi update

# Update all tools (brew, mise, rust, chezmoi, fisher)
upall

# Debug template output
chezmoi execute-template < path/to/file.tmpl
```

## Architecture Quick Reference

**Chezmoi file prefixes:**
- `dot_` → dotfile (becomes `.filename`)
- `private_` → sensitive directory
- `executable_` → script with 755 permissions
- `.tmpl` suffix → Go template processed at apply time

**Shell config load order (numeric prefix):**
```
00-*  Setup (plugin managers, Homebrew)
05-*  Shared configs (centralized ~/.config/env/*.env + ~/.config/path/*.path)
10-*  Shell-specific env (LANG, EDITOR, GPG_TTY, HIST*, ZSH_*)
20-*  OS-specific (darwin/linux)
50-*  Completions
70-*  Tool init (Starship, Zellij)
98-*  Plugin managers (Sheldon)
99-*  Aliases (always last)
zzz-* Fish late-load (Mise, FZF)
```

**Profile system:** `chezmoi init` prompts for `default` (full) or `server` (minimal). `is_p_ct`/`is_p_aaa`/`is_p_csaa` remain as data flags but are not prompted. Owner: `home/.chezmoi.yaml.tmpl`.

## Key Directories

```
home/
├── dot_config/etc/Brewfile.tmpl  # All packages (brews + casks)
├── private_fish/conf.d/     # Fish shell modules
├── private_zsh/conf.d/      # Zsh shell modules
├── private_bash/conf.d/     # Bash shell modules
├── bin/                     # Utility scripts (~20)
├── dot_config/              # App configs (21 tools)
└── .chezmoiscripts/
    ├── 00-run-before/       # Pre-apply: Homebrew, packages
    └── 01-common/           # Post-apply: macOS defaults, Linux setup, tools
```

## Package Management

Packages are managed via `~/.config/etc/Brewfile` (Homebrew):
```bash
# Add a package
echo 'brew "package-name"' >> home/dot_config/etc/Brewfile.tmpl

# Add a macOS app
echo 'cask "app-name"' >> home/dot_config/etc/Brewfile.tmpl

# Apply changes
chezmoi apply
```

Scripts automatically install packages during `chezmoi apply`:
- **macOS:** `run_before_02-install-packages-from-brewfile.sh.tmpl`
- **Linux:** `run_once_after_00-linux-system-setup.sh.tmpl`

## Template Patterns

```go
// OS detection
{{ if eq .chezmoi.os "darwin" }}macOS{{ else }}Linux{{ end }}

// Profile conditionals
{{ if .is_p_default }}full setup{{ end }}

// 1Password secret injection
{{ onepasswordRead "op://Dotfiles/github/email" }}
```

## Utility Scripts (bin/)

| Script | Purpose |
|--------|---------|
| `upall` | Master update TUI (Go binary, auto-fetched to `~/.local/bin`); `upall-classic` = v2 bash fallback |
| `osupdate` | OS-specific updates (apt/dnf/pacman/mas) |
| `gpg-backup` / `gpg-restore-backup` | GPG key backup to 1Password |
| `setup-atuin` | Configure history system |
| `brewup` | Homebrew update shortcut |

## Plugin Systems

- **Fish:** Fisher plugins in `fish_plugins`, auto-installed via `00-install_fisher.fish`
- **Zsh/Bash:** Sheldon plugins in `etc/sheldon/plugins.toml`, init in `98-sheldon.*`

## Cross-Shell Consistency

Aliases must be identical across Zsh and Bash (shared template logic). Fish uses abbreviations in `10-abbr.fish`. Update `SHELL-REFERENCE.md` when modifying aliases.

## Commit Convention

Use conventional commits: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `style:`, `perf:`

Examples:
```
feat(fish): add docker compose abbreviations
fix(git): correct signing key path in template
docs: update SHELL-REFERENCE with new aliases
```

## Documentation

| Doc | Content |
|-----|---------|
| [project-overview-pdr.md](./docs/project-overview-pdr.md) | Intent, goals, non-goals, principles |
| [system-architecture.md](./docs/system-architecture.md) | Boundaries, load order, decision ledger |
| [code-standards.md](./docs/code-standards.md) | Naming, templates, aliases, security |
| [deployment-guide.md](./docs/deployment-guide.md) | Installation, apply pipeline, troubleshooting |
| [project-roadmap.md](./docs/project-roadmap.md) | Stateful record: open questions |
| [codebase-summary.md](./docs/codebase-summary.md) | Navigation map: concern → location |
| [SHELL-REFERENCE.md](./SHELL-REFERENCE.md) | All aliases/functions |
| [SHORTCUTS-REFERENCE.md](./SHORTCUTS-REFERENCE.md) | Terminal keyboard shortcuts |
