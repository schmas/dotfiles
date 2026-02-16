# BIN — Utility Scripts

36 scripts deployed to `~/bin/`. All use `executable_` prefix (→ chmod 755).

## WHERE TO LOOK

| Task | Script | Notes |
|------|--------|-------|
| Update everything | `upall.tmpl` | Orchestrates: OS → brew → mise → rust → chezmoi → claude → fisher → atuin |
| Update OS packages | `osupdate.tmpl` | macOS (mas), Ubuntu (apt), RHEL (dnf), Arch (pacman) |
| Update Homebrew | `brewup` | `brew update && upgrade && cleanup` |
| Bootstrap new machine | `bootstrap-chezmoi.sh` | Xcode CLI → Homebrew → 1Password → SSH → chezmoi init |
| Backup GPG to 1Password | `gpg-backup`, `gpg-upload-op` | Export keys → store in 1Password |
| Restore GPG from 1Password | `gpg-download-op`, `gpg-restore-backup` | Download → import keys |
| Claude Code management | `claude-update`, `claude-backup`, `setup-claude-code` | Update/backup/install CLI |
| AI project settings backup | `ai-project-backup` | Backs up Claude, Cursor, OpenCode settings |
| AAA workspace backup | `aaa-workspace` | Bitbucket/ProtonDrive workspace management |
| Sync bootstrap gist | `sync-bootstrap-gist.sh` | Push bootstrap script to GitHub gist |

## SUBDIRECTORIES

```
bin/
├── git-scripts/    # Git extensions (git-amend, git-delete-gone-branch, git-wtf, etc.)
├── macos/          # macOS-only (setup-macos-defaults, docker shim, backup/restore apps)
└── nix/            # Nix utilities (channel setup, config update)
```

## CONVENTIONS

- **Naming:** `executable_{name}` — chezmoi strips prefix, sets 755
- **Shebangs:** `#!/usr/bin/env bash` (or fish) — never direct paths
- **Templates:** `.tmpl` suffix when OS/profile conditionals needed (e.g., `upall.tmpl`, `osupdate.tmpl`)
- **Error handling:** `set -euo pipefail` in Bash scripts, errors to stderr
- **Tool guards:** Always `command -v tool` before using optional tools
- Git scripts in `git-scripts/` are callable as `git {name}` (git subcommand convention)
