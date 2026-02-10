# Phase 3: Create Shell Loaders (05-shared-env)

## Context

- Parent plan: [plan.md](plan.md)
- Depends on: Phase 1 (env files must exist), Phase 2 (fish function must exist)

## Overview

- **Priority:** High (connects env files to shell startup)
- **Status:** complete
- **Description:** Create `05-shared-env.*` loader files for each shell that glob-source all `~/.config/env/*.env` files

## Key Insights

- Load order `05-*` runs before `10-*` (common) and `20-*` (OS-specific) — no dependency issues
- Zsh/Bash: `set -a` auto-exports all sourced vars, `set +a` restores
- Zsh `(N)` glob qualifier prevents error if no files match
- Bash needs `[ -f "$f" ]` guard for empty glob
- Fish calls `source_posix_env` function from Phase 2

## Requirements

- Each shell globs `$HOME/.config/env/*.env` in sorted order
- Later files override earlier (50-1password > 10-shared)
- No errors if directory or files don't exist
- No template processing needed (these are static files, not `.tmpl`)

## Related Code Files

- `home/dot_config/private_zsh/conf.d/` — existing zsh conf.d files
- `home/dot_config/private_bash/conf.d/` — existing bash conf.d files
- `home/dot_config/private_fish/conf.d/` — existing fish conf.d files
- `home/dot_config/private_fish/functions/source_posix_env.fish` — Phase 2

## Implementation Steps

### 1. Create `home/dot_config/private_zsh/conf.d/05-shared-env.zsh`

```zsh
#!/usr/bin/env zsh
# Source all POSIX .env files from ~/.config/env/
set -a
for f in "$HOME"/.config/env/*.env(N); do . "$f"; done
set +a
```

### 2. Create `home/dot_config/private_bash/conf.d/05-shared-env.bash`

```bash
#!/usr/bin/env bash
# Source all POSIX .env files from ~/.config/env/
set -a
for f in "$HOME"/.config/env/*.env; do [ -f "$f" ] && . "$f"; done
set +a
```

### 3. Create `home/dot_config/private_fish/conf.d/05-shared-env.fish`

```fish
# Source all POSIX .env files from ~/.config/env/
for f in $HOME/.config/env/*.env
    source_posix_env $f
end
```

## Todo

- [x] Create `05-shared-env.zsh` in zsh conf.d
- [x] Create `05-shared-env.bash` in bash conf.d
- [x] Create `05-shared-env.fish` in fish conf.d
- [x] Verify load order: confirm `05-*` sorts before `10-*` in each shell

## Success Criteria

- New shell session loads vars from `~/.config/env/*.env`
- `echo $MISE_GITHUB_TOKEN` returns correct value in all 3 shells
- Empty `~/.config/env/` dir doesn't cause errors
- Adding `90-local.env` with `FOO=bar` auto-loads without changing loaders

## Risk Assessment

| Risk | Impact | Mitigation |
|---|---|---|
| Glob returns no files | Zsh `(N)` handles it; Bash `[ -f ]` guards; Fish loop skips | All shells handle empty glob |
| `~/.config/env/` dir missing | Glob returns nothing, no error | Harmless — Phase 1 creates dir via chezmoi |

## Next Steps

- Phase 4: Clean up duplicate vars from per-shell files
