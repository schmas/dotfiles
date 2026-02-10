# Phase 4: Create 00-load-homebrew for Zsh + Bash

## Context
- Parent: [plan.md](plan.md)
- Independent (no dependencies)
- Reference: `home/dot_config/private_fish/conf.d/00-load-homebrew.fish.tmpl` (existing fish version)

## Overview
- **Priority**: Medium (must complete before Phase 6)
- **Status**: pending
- **Description**: Create `00-load-homebrew` loaders for Zsh and Bash matching existing fish pattern. Move brew init from 20-os.linux files and FPATH from 20-os.darwin.env.zsh. Also update fish to handle Linux.

## Key Insights
- Fish already has `00-load-homebrew.fish.tmpl` but macOS-only
- Zsh/Bash linux files have linuxbrew init at `20-*` tier — wrong load order
- Homebrew must load at `00-*` (setup tier) so PATH is available for later modules
- Zsh needs brew FPATH for completions (currently in 20-os.darwin.env.zsh)
- All wrapped in `{{ if eq .using_nix false }}` conditional (matches fish pattern)

## Requirements
- macOS: `/opt/homebrew/bin/brew` init
- Linux: `/home/linuxbrew/.linuxbrew/bin/brew` init
- Zsh: brew FPATH for zsh completions (macOS only)
- Chezmoi template conditionals for OS + nix

## Related Code Files
- **Create**: `home/dot_config/private_zsh/conf.d/00-load-homebrew.zsh.tmpl`
- **Create**: `home/dot_config/private_bash/conf.d/00-load-homebrew.bash.tmpl`
- **Modify**: `home/dot_config/private_fish/conf.d/00-load-homebrew.fish.tmpl`

## Implementation Steps

### 1. Create `00-load-homebrew.zsh.tmpl`
```zsh
{{- if eq .using_nix false -}}
#!/usr/bin/env zsh

{{ if eq .chezmoi.os "darwin" -}}
if [[ -e /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
{{ else -}}
if [[ -e /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
{{ end -}}

{{- end -}}
```

### 2. Create `00-load-homebrew.bash.tmpl`
```bash
{{- if eq .using_nix false -}}
#!/usr/bin/env bash

{{ if eq .chezmoi.os "darwin" -}}
if [[ -e /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
{{ else -}}
if [[ -e /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
{{ end -}}

{{- end -}}
```

### 3. Update `00-load-homebrew.fish.tmpl`
Add Linux linuxbrew support:
```fish
{{- if eq .using_nix false -}}

{{ if eq .chezmoi.os "darwin" -}}
if test -e /opt/homebrew/bin/brew
    eval $(/opt/homebrew/bin/brew shellenv)
end
{{ else -}}
if test -e /home/linuxbrew/.linuxbrew/bin/brew
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end
{{ end -}}

{{- end -}}
```

## Todo
- [ ] Create `00-load-homebrew.zsh.tmpl` with macOS + Linux + FPATH
- [ ] Create `00-load-homebrew.bash.tmpl` with macOS + Linux
- [ ] Update `00-load-homebrew.fish.tmpl` to add Linux linuxbrew
- [ ] Verify chezmoi template syntax renders correctly

## Success Criteria
- All 3 shells have `00-load-homebrew` at setup tier
- Homebrew loads before any env vars that depend on brew-installed tools
- Zsh gets brew FPATH for completions on macOS
- Nix users skip homebrew loading

## Risk Assessment
- **Medium**: Linuxbrew relocation changes load order (20→00). Should be safe since brew PATH is needed early.
- Test on Linux (WSL) if possible

## Next Steps
- Phase 6 can then remove brew init from 20-os.linux.env.{zsh,bash} and FPATH from 20-os.darwin.env.zsh
