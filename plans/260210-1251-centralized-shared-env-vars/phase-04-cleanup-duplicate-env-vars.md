# Phase 4: Clean Up Duplicate Env Vars

## Context

- Parent plan: [plan.md](plan.md)
- Depends on: Phase 1, 2, 3 (new files must exist before removing old defs)

## Overview

- **Priority:** High (prevents double-setting vars)
- **Status:** complete
- **Description:** Remove env var definitions that moved to `~/.config/env/` from per-shell conf.d files

## Key Insights

- Only remove **pure env vars** that are now centralized
- Keep all **shell commands** (ulimit, typeset, FPATH, VSCode, linuxbrew, GPG agent)
- Keep all **shell-specific vars** (LANG, EDITOR, ZSH history, etc.)
- Linux files have mix of pure vars and shell commands — careful surgical removal

## Requirements

- No duplicate env var definitions across centralized + per-shell files
- Shell-specific commands remain functional
- All templates still valid (proper Go template conditionals)

## Related Code Files

All paths relative to `home/dot_config/`:

| File | What to Remove | What to Keep |
|---|---|---|
| `private_fish/conf.d/10-common.env.fish.tmpl` | L28-31: MISE, HOMEBREW, GEMINI, PODMAN | L1-23: LANG, EDITOR, MISC, DOTFILES_BIN |
| `private_zsh/conf.d/20-os.darwin.env.zsh.tmpl` | L3-5: tokens; L8-12: XDG vars | L14-31: comments, ulimit, brew FPATH |
| `private_bash/conf.d/20-os.darwin.env.bash.tmpl` | L4-6: tokens; L9-13: XDG vars | L15-25: comments, ulimit |
| `private_fish/conf.d/20-os.darwin.env.fish.tmpl` | L7-15: XDG vars | L17-25: EDITOR, VSCode, ulimit |
| `private_fish/conf.d/20-os.linux.env.fish.tmpl` | L2: `TMPDIR=/tmp` | L4-8: WSL conditional (shell-specific `set -gx`), Arch conditional |
| `private_zsh/conf.d/20-os.linux.env.zsh.tmpl` | L3: `TMPDIR`; L7-8: WSL `TMPDIR`+`DOTFILES_LOAD_FULL_THEME` | L16-18: linuxbrew, L24-28: GPG agent, L33-35: compinit |
| `private_bash/conf.d/20-os.linux.env.bash.tmpl` | L3: `TMPDIR`; L7-8: WSL `TMPDIR`+`DOTFILES_LOAD_FULL_THEME` | L16-18: linuxbrew, L24-28: GPG agent |

## Implementation Steps

### 1. Edit `private_fish/conf.d/10-common.env.fish.tmpl`

Remove the "Others" section (L25-31):
```
##########
# Others #
##########
set -gx MISE_GITHUB_TOKEN ...
set -gx HOMEBREW_GITHUB_API_TOKEN ...
set -gx GEMINI_API_KEY ...
set -gx PODMAN_COMPOSE_WARNING_LOGS false
```

**After:** File ends at L23 (GPG_TTY line).

### 2. Edit `private_zsh/conf.d/20-os.darwin.env.zsh.tmpl`

Remove L3-12 (tokens + XDG block). Keep template wrapper + shell commands.

**After:**
```
{{ if eq .chezmoi.os "darwin" }}
#!/usr/bin/env zsh

# export _JAVA_OPTIONS="-XX:-MaxFDLimit"

##########################
# nodejs memory increase #
##########################
# export NODE_OPTIONS="--max-old-space-size=4096"

# fix for too many files open
ulimit -f unlimited

if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

{{ end }}
```

### 3. Edit `private_bash/conf.d/20-os.darwin.env.bash.tmpl`

Remove L4-13 (tokens + XDG block). Keep template wrapper + shell commands.

**After:**
```
{{ if eq .chezmoi.os "darwin" }}
#!/usr/bin/env bash

# export _JAVA_OPTIONS="-XX:-MaxFDLimit"

##########################
# nodejs memory increase #
##########################
# export NODE_OPTIONS="--max-old-space-size=4096"

# fix for too many files open
ulimit -f unlimited

{{ end }}
```

### 4. Edit `private_fish/conf.d/20-os.darwin.env.fish.tmpl`

Remove L6-15 (XDG block). Keep VSCode integration + ulimit.

**After:**
```
{{ if eq .chezmoi.os "darwin" }}
##########################
# MacOS
##########################

# set Visual Studio Code as default editor use code, code-insiders, subl or vim
set -gx EDITOR nvim

string match -q "$TERM_PROGRAM" vscode
and . (code --locate-shell-integration-path fish)

# fix for too many files open
ulimit -f unlimited

{{ end }}
```

### 5. Edit `private_fish/conf.d/20-os.linux.env.fish.tmpl`

Remove L2 (`set -gx TMPDIR /tmp`). Keep WSL/Arch conditionals as-is since they use fish-native `set -gx` syntax and chezmoi template conditionals (can't go in POSIX .env).

**Note:** The WSL `set -gx TMPDIR /tmp` on L6 is redundant with centralized `20-os-linux.env` but it's inside a fish-specific WSL conditional block. Keep it for now — harmless double-set.

### 6. Edit `private_zsh/conf.d/20-os.linux.env.zsh.tmpl`

Remove L3 (`export TMPDIR="/tmp"`) and L7-8 (WSL `TMPDIR`+`DOTFILES_LOAD_FULL_THEME`). Keep linuxbrew eval, GPG agent, compinit.

### 7. Edit `private_bash/conf.d/20-os.linux.env.bash.tmpl`

Remove L3 (`export TMPDIR="/tmp"`) and L7-8 (WSL `TMPDIR`+`DOTFILES_LOAD_FULL_THEME`). Keep linuxbrew eval, GPG agent.

### 8. Post-cleanup verification

Grep all conf.d files for moved var names to confirm no remaining duplicates:
- `MISE_GITHUB_TOKEN`
- `HOMEBREW_GITHUB_API_TOKEN`
- `GEMINI_API_KEY`
- `GITHUB_TOKEN`
- `PODMAN_COMPOSE_WARNING_LOGS`
- `XDG_CONFIG_HOME` (should only be in `20-os-darwin.env.tmpl` now)

## Todo

- [x] Remove tokens + PODMAN from fish 10-common
- [x] Remove tokens + XDG from zsh 20-darwin
- [x] Remove tokens + XDG from bash 20-darwin
- [x] Remove XDG from fish 20-darwin
- [x] Remove TMPDIR from fish 20-linux
- [x] Remove TMPDIR + WSL vars from zsh 20-linux
- [x] Remove TMPDIR + WSL vars from bash 20-linux
- [x] Grep verify: no duplicate definitions of moved vars

## Success Criteria

- Zero duplicate definitions of centralized vars across shell configs
- All shell conf.d files still syntactically valid
- Shell commands (ulimit, FPATH, VSCode, GPG, linuxbrew) still work

## Risk Assessment

| Risk | Impact | Mitigation |
|---|---|---|
| Accidentally remove shell command | Shell feature breaks | Careful line-by-line review; keep commented lines |
| Go template conditional broken after removal | chezmoi apply fails | Test with `chezmoi execute-template` |
| Miss a duplicate | Var set twice (harmless, just messy) | Post-cleanup grep verification |

## Next Steps

- Phase 5: Verify everything with chezmoi dry-run
