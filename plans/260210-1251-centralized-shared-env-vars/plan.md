---
title: "Centralized Shared Environment Variables"
description: "Single ~/.config/env/ directory with POSIX .env files glob-loaded by all shells"
status: complete
priority: P2
effort: 1h
branch: main
tags: [chezmoi, env-vars, fish, zsh, bash, DRY]
created: 2026-02-10
---

# Centralized Shared Environment Variables

## Overview

Eliminate DRY violation: shared env vars (API tokens, prefs) duplicated across Fish/Zsh/Bash configs. Centralize into `~/.config/env/` with POSIX KEY=VALUE files, glob-loaded by all shells.

Brainstorm report: [brainstorm-260210-1251-centralized-shared-env-vars.md](../reports/brainstorm-260210-1251-centralized-shared-env-vars.md)

## Phases

| # | Phase | Status | File |
|---|-------|--------|------|
| 1 | Create centralized env templates | complete | [phase-01](phase-01-create-centralized-env-templates.md) |
| 2 | Create fish source_posix_env function | complete | [phase-02](phase-02-create-fish-source-posix-env-function.md) |
| 3 | Create shell loaders (05-shared-env) | complete | [phase-03](phase-03-create-shell-loaders.md) |
| 4 | Clean up duplicates from per-shell files | complete | [phase-04](phase-04-cleanup-duplicate-env-vars.md) |
| 5 | Verify with chezmoi dry-run | complete | [phase-05](phase-05-verify-chezmoi-dry-run.md) |

## Key Dependencies

- Phase 2 and 3 can run in parallel (fish function + loaders are independent files)
- Phase 4 depends on 1-3 being complete (cleanup after new files exist)
- Phase 5 depends on all previous phases

## Architecture

```
~/.config/env/                          # Glob-loaded by all shells
├── 10-shared.env                       # Chezmoi: tokens + shared prefs
├── 20-os-darwin.env                    # Chezmoi: XDG dirs (empty on Linux)
├── 20-os-linux.env                     # Chezmoi: TMPDIR, WSL vars (empty on macOS)
├── 50-1password.env                    # Optional: 1Password CLI generated
└── 90-local.env                        # Optional: manual overrides

Shell load order:
  00-* → Setup (Homebrew, Fisher)
  05-* → Shared env ← NEW: globs ~/.config/env/*.env
  10-* → Common env (LANG, EDITOR, shell-specific)
  20-* → OS-specific (shell commands only)
```

## Files to Create (6)

| Chezmoi Source | Target |
|---|---|
| `home/dot_config/private_env/10-shared.env.tmpl` | `~/.config/env/10-shared.env` |
| `home/dot_config/private_env/20-os-darwin.env.tmpl` | `~/.config/env/20-os-darwin.env` |
| `home/dot_config/private_env/20-os-linux.env.tmpl` | `~/.config/env/20-os-linux.env` |
| `home/dot_config/private_fish/functions/source_posix_env.fish` | `~/.config/fish/functions/source_posix_env.fish` |
| `home/dot_config/private_fish/conf.d/05-shared-env.fish` | `~/.config/fish/conf.d/05-shared-env.fish` |
| `home/dot_config/private_zsh/conf.d/05-shared-env.zsh` | `~/.config/zsh/conf.d/05-shared-env.zsh` |
| `home/dot_config/private_bash/conf.d/05-shared-env.bash` | `~/.config/bash/conf.d/05-shared-env.bash` |

## Files to Modify (5)

| File | Action |
|---|---|
| `private_fish/conf.d/10-common.env.fish.tmpl` | Remove L28-31 (tokens + PODMAN) |
| `private_zsh/conf.d/20-os.darwin.env.zsh.tmpl` | Remove L3-5 (tokens) + L8-12 (XDG) |
| `private_bash/conf.d/20-os.darwin.env.bash.tmpl` | Remove L4-6 (tokens) + L9-13 (XDG) |
| `private_fish/conf.d/20-os.darwin.env.fish.tmpl` | Remove L7-15 (XDG) |
| `private_fish/conf.d/20-os.linux.env.fish.tmpl` | Remove L2 (TMPDIR), keep WSL conditionals as-is |

## Success Criteria

- [ ] `chezmoi apply --dry-run` shows no errors
- [ ] No duplicate env var definitions across shell configs
- [ ] All shells get same token values
- [ ] `~/.claude/.env` unchanged
- [ ] New env file in `~/.config/env/` can be added without touching shell loaders
