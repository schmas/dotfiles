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

**Shell config load order** (numeric prefix in each
`home/dot_config/private_{fish,zsh,bash}/conf.d/`):

```
00-*   Plugin-manager and Homebrew shellenv bootstrap
05-*   Source the shared ~/.config/env/*.env + ~/.config/path/*.path files
10-*   Common env, abbreviations, colors
20-*   OS-specific env (darwin/linux)
49-50  Readline input, completions
70-*   Tool init (Starship, Zellij, Worktrunk, Yazi)
98-*   Sheldon (Zsh/Bash)
99-*   Aliases (Zsh/Bash, templated)
zzz-*  Late load — Mise, FZF, Atuin, Television
```

Nothing may depend on a module with an equal or higher prefix; a new module takes
the lowest prefix its dependencies allow. Owning table:
[System Architecture](./.agents/docs/system-architecture.md#shell-configuration-numeric-load-order).

**Profile system:** `chezmoi init` prompts for `default` (full) or `server` (minimal). `is_p_ct`/`is_p_aaa`/`is_p_csaa` remain as data flags but are not prompted. Owner: `home/.chezmoi.yaml.tmpl`.

## Key Directories

```
home/
├── dot_config/                  # App configs
│   ├── etc/Brewfile.tmpl        # All packages (brews + casks)
│   ├── private_fish/conf.d/     # Fish shell modules
│   ├── private_zsh/conf.d/      # Zsh shell modules
│   └── private_bash/conf.d/     # Bash shell modules
├── bin/                         # Utility scripts
└── .chezmoiscripts/
    ├── 00-run-before/           # Pre-apply: 1Password, Homebrew, packages
    └── 01-common/               # Post-apply: macOS defaults, Linux setup, tools
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

- **macOS:** `.chezmoiscripts/00-run-before/run_onchange_before_02-install-packages-from-brewfile.sh.tmpl`
- **Linux:** `.chezmoiscripts/01-common/run_onchange_after_00-linux-system-setup.sh.tmpl`

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

| Script                              | Purpose                                                                                           |
| ----------------------------------- | ------------------------------------------------------------------------------------------------- |
| `upall`                             | Master update TUI (Go binary, auto-fetched to `~/.local/bin`); `upall-classic` = v2 bash fallback |
| `osupdate`                          | OS-specific updates (apt/dnf/pacman/mas)                                                          |
| `gpg-backup` / `gpg-restore-backup` | GPG key backup to 1Password                                                                       |
| `setup-atuin`                       | Configure history system                                                                          |
| `brewup`                            | Homebrew update shortcut                                                                          |
| `vidproc`                           | Shrink videos (files or folders) for review and AI chat uploads: resize, speed up, compress       |

## Plugin Systems

- **Fish:** Fisher plugins in `fish_plugins`, auto-installed via `00-install_fisher.fish`
- **Zsh/Bash:** Sheldon plugins in `dot_config/private_{zsh,bash}/etc/sheldon/plugins.toml`
  (one list per shell), init in `98-sheldon.*`

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

| Doc                                                               | Content                                       |
| ----------------------------------------------------------------- | --------------------------------------------- |
| [project-overview-pdr.md](./.agents/docs/project-overview-pdr.md) | Intent, goals, non-goals, principles          |
| [system-architecture.md](./.agents/docs/system-architecture.md)   | Boundaries, load order, decision ledger       |
| [code-standards.md](./.agents/docs/code-standards.md)             | Naming, templates, aliases, security          |
| [deployment-guide.md](./.agents/docs/deployment-guide.md)         | Installation, apply pipeline, troubleshooting |
| [project-roadmap.md](./.agents/docs/project-roadmap.md)           | Stateful record: open questions               |
| [codebase-summary.md](./.agents/docs/codebase-summary.md)         | Navigation map: concern → location            |
| [SHELL-REFERENCE.md](./SHELL-REFERENCE.md)                        | All aliases/functions                         |
| [SHORTCUTS-REFERENCE.md](./SHORTCUTS-REFERENCE.md)                | Terminal keyboard shortcuts                   |
