# Phase 5: Strip Per-Shell 10-common.env Files

## Context
- Parent: [plan.md](plan.md)
- Depends on: Phases 1-3 (centralized vars must exist before removing from per-shell)

## Overview
- **Priority**: High
- **Status**: pending
- **Description**: Remove centralized vars and dead code from all three `10-common.env.*` files. Each file retains only shell-specific content that can't be centralized.

## Key Insights
- `GPG_TTY=$(tty)` uses command substitution — can't centralize
- `rm_opts=(-I -v)` uses bash/zsh array syntax — can't centralize
- Fish doesn't need rm_opts (commented out = dead code)
- Zsh has extensive shell-specific config (ZSH_*, HIST*, etc.)
- Bash has minimal shell-specific (HISTCONTROL only)

## Related Code Files
- **Modify**: `home/dot_config/private_fish/conf.d/10-common.env.fish.tmpl`
- **Modify**: `home/dot_config/private_zsh/conf.d/10-common.env.zsh.tmpl`
- **Modify**: `home/dot_config/private_bash/conf.d/10-common.env.bash.tmpl`

## Implementation Steps

### 1. Rewrite Fish `10-common.env.fish.tmpl`

**Before** (24 lines): LANG, LANGUAGE, LC_TIME, DOTFILES_BIN, VISUAL, EDITOR, SYSTEMD_EDITOR, OPENCV_LOG_LEVEL, commented rm_opts, CLICOLOR, GPG_TTY

**After**:
```fish
# Shell-specific env — vars that need fish syntax (command substitution)
# Shared vars loaded from ~/.config/env/ via 05-shared-env.fish
set -gx GPG_TTY (tty)
```

Remove: LANG (L1), LANGUAGE (L2), LC_TIME (L3), DOTFILES_BIN (L8), VISUAL (L13), EDITOR (L14), SYSTEMD_EDITOR (L15), OPENCV_LOG_LEVEL (L20), `#set -gx rm_opts` (L21), CLICOLOR (L22)

### 2. Rewrite Zsh `10-common.env.zsh.tmpl`

**After**:
```zsh
#!/usr/bin/env zsh

# Shell-specific env — vars that need zsh syntax
# Shared vars loaded from ~/.config/env/ via 05-shared-env.zsh

export GPG_TTY=$(tty)
export rm_opts=(-I -v)

##########################################################################################
# ZSH SPECIFIC
##########################################################################################
# Skip the not really helping Ubuntu global compinit
skip_global_compinit=1

# prevent PATH from taking on duplicate entries
typeset -U path

##############################
# MISC
##############################
export DISABLE_AUTO_UPDATE="true";
export DISABLE_UPDATE_PROMPT="true";
export UPDATE_ZSH_DAYS=99999;

##############################
# History file configuration
##############################
HISTFILE="$HOME/.zsh_history"
HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=1000
SAVEHIST=1000

##############################
# ZSH
##############################
ZSH_DISABLE_COMPFIX=true
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50
ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c50,)"
ZSH_AUTOSUGGEST_MANUAL_REBIND="true"

HISTORY_SUBSTRING_SEARCH_FUZZY=set
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

ZSHZ_DATA="${HOME}/.config/z"

ZSH_CACHE_DIR="$HOME/.zcompcache"
mkdir -p $ZSH_CACHE_DIR
```

Remove: LANG (L3), LANGUAGE (L4), LC_TIME (L5), VISUAL (L10), EDITOR (L11), SYSTEMD_EDITOR (L12), OPENCV_LOG_LEVEL (L17), rm_opts (L18→keep, array syntax), CLICOLOR (L19), `# export NODE_OPTIONS` (L25), forgit_ignore (L30), `# ASDF_DIR` (L33), `# ASDF_DATA_DIR` (L34), ASDF_NODEJS... (L35), `# WD_CONFIG` (L76), `# AUTOENV_AUTH_FILE` (L77)

### 3. Rewrite Bash `10-common.env.bash.tmpl`

**After**:
```bash
#!/usr/bin/env bash

# Shell-specific env — vars that need bash syntax
# Shared vars loaded from ~/.config/env/ via 05-shared-env.bash

##############################
# HISTORY
##############################
export HISTCONTROL=ignoredups:erasedups

##############################
# MISC
##############################
export GPG_TTY=$(tty)
export rm_opts=(-I -v)
```

Remove: LANG (L3), LANGUAGE (L4), LC_TIME (L5), VISUAL (L10), EDITOR (L11), SYSTEMD_EDITOR (L12), OPENCV_LOG_LEVEL (L22), CLICOLOR (L24), GPG_TTY (L25→keep, command sub), `# export NODE_OPTIONS` (L30), forgit_ignore (L35)

## Todo
- [ ] Rewrite fish 10-common.env.fish.tmpl (GPG_TTY only)
- [ ] Rewrite zsh 10-common.env.zsh.tmpl (remove centralized + dead code)
- [ ] Rewrite bash 10-common.env.bash.tmpl (remove centralized + dead code)
- [ ] Verify no duplicate definitions remain

## Success Criteria
- No env var defined in both centralized .env and per-shell file
- GPG_TTY still set in all 3 shells (command substitution)
- Zsh-specific config preserved (ZSH_*, HIST*, etc.)
- All commented-out code removed from these files

## Risk Assessment
- **Low**: Straightforward removal of duplicates
- Verify rm_opts array syntax works in both zsh and bash (already tested — existing code)
