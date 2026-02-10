# Phase 6: Strip 20-os Files + Delete Dead Code

## Context
- Parent: [plan.md](plan.md)
- Depends on: Phase 4 (brew init must exist in 00-load-homebrew before removing from here)

## Overview
- **Priority**: Medium
- **Status**: pending
- **Description**: Remove relocated commands, centralized vars, and ALL commented-out dead code from 20-os.darwin and 20-os.linux env files across all shells.

## Key Insights
- Darwin files: ulimit stays, everything else goes or was already moved
- Linux files: linuxbrew moves to 00-*, WSL GPG agent stays, commented code deleted
- Fish darwin: redundant EDITOR override must go (centralized now)
- All files: commented-out code is dead — git history preserves it

## Related Code Files

**Darwin files:**
- `home/dot_config/private_fish/conf.d/20-os.darwin.env.fish.tmpl`
- `home/dot_config/private_zsh/conf.d/20-os.darwin.env.zsh.tmpl`
- `home/dot_config/private_bash/conf.d/20-os.darwin.env.bash.tmpl`

**Linux files:**
- `home/dot_config/private_fish/conf.d/20-os.linux.env.fish.tmpl`
- `home/dot_config/private_zsh/conf.d/20-os.linux.env.zsh.tmpl`
- `home/dot_config/private_bash/conf.d/20-os.linux.env.bash.tmpl`

## Implementation Steps

### 1. Fish 20-darwin → keep ulimit + VSCode integration
```fish
{{ if eq .chezmoi.os "darwin" }}
##########################
# MacOS
##########################

string match -q "$TERM_PROGRAM" vscode
and . (code --locate-shell-integration-path fish)

ulimit -f unlimited

{{ end }}
```
Remove: `set -gx EDITOR nvim` (L7, redundant), `# ulimit -n` (L13)

### 2. Zsh 20-darwin → keep ulimit only
```zsh
{{ if eq .chezmoi.os "darwin" }}
#!/usr/bin/env zsh

ulimit -f unlimited

{{ end }}
```
Remove: `# _JAVA_OPTIONS` (L4), `# LS_COLORS` (L5), `# NODE_OPTIONS` (L10), `# ulimit -n` (L13), brew FPATH block (L16-21, moved to 00-load-homebrew)

### 3. Bash 20-darwin → keep ulimit only
```bash
{{ if eq .chezmoi.os "darwin" }}
#!/usr/bin/env bash

ulimit -f unlimited

{{ end }}
```
Remove: `# _JAVA_OPTIONS` (L4), `# LS_COLORS` (L5), `# NODE_OPTIONS` (L10), `# ulimit -n` (L13)

### 4. Fish 20-linux → keep WSL + Arch structure
```fish
{{ if eq .chezmoi.os "linux" }}

{{   if (.chezmoi.kernel.osrelease | lower | contains "microsoft") }}
# WSL-specific code
{{   end }}

{{  if eq .chezmoi.osRelease.idLike "arch" }}
# Archlinux
{{  end }}

{{ end }}
```
Remove: `set -gx TMPDIR /tmp` (L5, centralized), `# DOTFILES_LOAD_FULL_THEME` (L6, centralized), `# XDG_DATA_DIRS=...gkgpg` (L11, dead code with typo)

### 5. Zsh 20-linux → keep WSL GPG agent + debian compinit
```zsh
{{ if eq .chezmoi.os "linux" }}
#!/usr/bin/env zsh

{{   if (.chezmoi.kernel.osrelease | lower | contains "microsoft") }}
# WSL-specific code
{{   end }}

{{  if eq .chezmoi.osRelease.idLike "arch" }}
# Archlinux
{{  end }}

{{ if .chezmoi.kernel.osrelease | lower | contains "microsoft" }}
# WSL-specific code

# Ensure that gpg can find the agent when needed
if [ -n "$(pgrep gpg-agent)" ]; then
    export GPG_TTY=$(tty)
else
    eval $(gpg-agent --daemon)
fi

{{   end }}

{{   if (eq .chezmoi.osRelease.id "debian" "ubuntu") -}}
  # Skip the not really helping Ubuntu global compinit
  skip_global_compinit=1
{{   end -}}

{{ end }}
```
Remove: linuxbrew block (L13-15, moved to 00-load-homebrew), `# XDG_DATA_DIRS=...gkgpg` (L10, dead code)

### 6. Bash 20-linux → keep WSL GPG agent
```bash
{{ if eq .chezmoi.os "linux" }}
#!/usr/bin/env bash

{{   if (.chezmoi.kernel.osrelease | lower | contains "microsoft") }}
# WSL-specific code
{{   end }}

{{  if eq .chezmoi.osRelease.idLike "arch" }}
# Archlinux
{{  end }}

{{ if .chezmoi.kernel.osrelease | lower | contains "microsoft" }}
# WSL-specific code

# Ensure that gpg can find the agent when needed
if [ -n "$(pgrep gpg-agent)" ]; then
    export GPG_TTY=$(tty)
else
    eval $(gpg-agent --daemon)
fi

{{   end }}

{{ end }}
```
Remove: linuxbrew block (L13-15, moved to 00-load-homebrew), `# XDG_DATA_DIRS=...gkgpg` (L10, dead code)

## Todo
- [ ] Rewrite fish 20-os.darwin.env.fish.tmpl
- [ ] Rewrite zsh 20-os.darwin.env.zsh.tmpl
- [ ] Rewrite bash 20-os.darwin.env.bash.tmpl
- [ ] Rewrite fish 20-os.linux.env.fish.tmpl
- [ ] Rewrite zsh 20-os.linux.env.zsh.tmpl
- [ ] Rewrite bash 20-os.linux.env.bash.tmpl
- [ ] Confirm zero commented-out code remains in any env file

## Success Criteria
- No commented-out dead code in any 20-os file
- No linuxbrew init in 20-os linux files (moved to 00-load-homebrew)
- No brew FPATH in 20-os.darwin.env.zsh (moved to 00-load-homebrew)
- ulimit -f unlimited preserved in all darwin files
- WSL GPG agent preserved in zsh/bash linux files
- VSCode shell integration preserved in fish darwin

## Risk Assessment
- **Low**: Most removals are dead comments
- **Medium**: Linuxbrew relocation — verify brew PATH still available (now loads earlier at 00-*)
