# Brainstorm: Env Cleanup Phase 2 — Centralize + Relocate + Prune

## Problem Statement

After Phase 1 (centralizing tokens + XDG vars), many env vars remain duplicated across Fish/Zsh/Bash `10-common.env.*` files. Additionally, non-env-var commands (ulimit, linuxbrew init, GPG agent) are mixed into `*.env.*` files where they don't belong. Commented-out dead code clutters all env files.

## Decisions Made

- **Scope**: Full cleanup (centralize + relocate + prune)
- **Editor**: Normalize to `nvim` everywhere (bash currently has `vim`)
- **$HOME expansion**: Enhance fish `source_posix_env` to expand `$HOME`
- **Token separation**: Move tokens from `10-shared.env` → `15-services.env` (neutral name, no "tokens" in filename for security)

---

## Plan: 7 Phases

### Phase 1: Expand 10-shared.env with literal-value vars

Split current `10-shared.env.tmpl` — move tokens to new `15-services.env.tmpl`:

**10-shared.env.tmpl** (config only):
```
LANG=en_US.UTF-8
LANGUAGE=en_US:en
LC_TIME=en_US.UTF-8
VISUAL=nvim
EDITOR=nvim
SYSTEMD_EDITOR=nvim
OPENCV_LOG_LEVEL=ERROR
CLICOLOR=1
DOTFILES_BIN=$HOME/bin
forgit_ignore=/dev/null
ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY=latest_installed
PODMAN_COMPOSE_WARNING_LOGS=false
```

**15-services.env.tmpl** (secrets, neutral filename):
```
MISE_GITHUB_TOKEN={{ onepasswordRead ... }}
GITHUB_TOKEN={{ onepasswordRead ... }}
HOMEBREW_GITHUB_API_TOKEN={{ onepasswordRead ... }}
GEMINI_API_KEY={{ onepasswordRead ... }}
```

### Phase 2: Enhance fish source_posix_env

Add `$HOME` expansion to `source_posix_env.fish`:
```fish
set -l val (string replace -a '$HOME' "$HOME" -- $val)
```

Simple, handles `DOTFILES_BIN=$HOME/bin` correctly.

### Phase 3: Create 00-load-homebrew for Zsh + Bash

Fish already has `00-load-homebrew.fish.tmpl`. Create matching:
- `00-load-homebrew.zsh.tmpl` — macOS `/opt/homebrew` + Linux linuxbrew + zsh brew FPATH
- `00-load-homebrew.bash.tmpl` — macOS `/opt/homebrew` + Linux linuxbrew

Move brew init FROM `20-os.linux.env.{zsh,bash}` and FPATH FROM `20-os.darwin.env.zsh`.

Also update fish's `00-load-homebrew.fish.tmpl` to handle Linux linuxbrew (currently macOS-only).

### Phase 4: Strip per-shell 10-common env files

**Fish 10-common** → after removing centralized vars, only `GPG_TTY` remains:
```fish
set -gx GPG_TTY (tty)
```

**Zsh 10-common** → remove centralized vars + commented code. Keep:
- GPG_TTY, rm_opts
- All ZSH-specific: HIST*, ZSH_*, DISABLE_*, HISTORY_*, typeset -U, skip_global_compinit, ZSH_CACHE_DIR

**Bash 10-common** → remove centralized vars + commented code. Keep:
- GPG_TTY, rm_opts
- HISTCONTROL

### Phase 5: Strip per-shell 20-os.darwin env files

After removing centralized vars, commented code, and relocated commands:

**Fish 20-darwin.env** → keeps: `ulimit -f unlimited` + VSCode shell integration
**Zsh 20-darwin.env** → keeps: `ulimit -f unlimited`
**Bash 20-darwin.env** → keeps: `ulimit -f unlimited`

### Phase 6: Strip per-shell 20-os.linux env files

After removing centralized vars (TMPDIR already moved), linuxbrew (moved to 00-load-homebrew), commented code:

**Fish 20-linux.env** → keeps: WSL conditional block (nearly empty, but structure matters for future)
**Zsh 20-linux.env** → keeps: WSL GPG agent init + debian skip_global_compinit
**Bash 20-linux.env** → keeps: WSL GPG agent init

### Phase 7: Verify with chezmoi dry-run

Run `chezmoi apply --dry-run --verbose` to confirm no breakage.

---

## Commented Code to Delete (complete list)

| Dead Code | Location(s) |
|---|---|
| `# export NODE_OPTIONS=...` | zsh/bash 10-common, zsh/bash 20-darwin |
| `# export _JAVA_OPTIONS=...` | zsh/bash 20-darwin |
| `# export LS_COLORS=...` | zsh/bash 20-darwin |
| `# ulimit -n 524288 524288` | fish/zsh/bash 20-darwin |
| `#set -gx rm_opts "-I -v"` | fish 10-common |
| `# WD_CONFIG=...` / `# AUTOENV_AUTH_FILE=...` | zsh 10-common |
| `# ASDF_DIR=...` / `# ASDF_DATA_DIR=...` | zsh 10-common |
| `# XDG_DATA_DIRS=...` (typo "gkgpg") | fish/zsh/bash 20-linux |
| `# DOTFILES_LOAD_FULL_THEME=true` | fish 20-linux |

## Inconsistency Fixed

- Bash `VISUAL=vim` → `VISUAL=nvim` (normalized via centralized config)

## Risks

- **Low**: Fish `$HOME` expansion is simple string replacement — won't handle nested vars, but we only need `$HOME`
- **Low**: Removing dead commented code is safe — if needed later, git history has it
- **Medium**: Linuxbrew relocation needs testing on Linux (WSL or real)

## Success Criteria

- `chezmoi apply --dry-run` shows no errors
- All shells get identical values for centralized vars
- No duplicate definitions
- No commented-out dead code in env files
- Brew init in `00-*` tier for all shells (consistent load order)
- Env files contain only env var exports (no commands like ulimit)
