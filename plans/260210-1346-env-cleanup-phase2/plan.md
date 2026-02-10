---
title: "Env Cleanup Phase 2"
description: "Centralize remaining shared env vars, separate tokens, relocate misplaced commands, delete dead code"
status: complete
priority: P2
effort: 1.5h
branch: main
tags: [chezmoi, env-vars, fish, zsh, bash, DRY, cleanup]
created: 2026-02-10
---

# Env Cleanup Phase 2

## Overview

Continues [Phase 1](../260210-1251-centralized-shared-env-vars/plan.md) (complete). Centralizes 11 more env vars, separates tokens into dedicated file, relocates misplaced shell commands (ulimit, linuxbrew, gpg-agent), deletes all commented-out dead code.

Brainstorm: [brainstorm-260210-1346-env-cleanup-phase2.md](../reports/brainstorm-260210-1346-env-cleanup-phase2.md)

## Phases

| # | Phase | Status | File |
|---|-------|--------|------|
| 1 | Split tokens into 15-services.env | complete | [phase-01](phase-01-split-tokens-to-services-env.md) |
| 2 | Expand 10-shared.env with centralized vars | complete | [phase-02](phase-02-expand-shared-env.md) |
| 3 | Enhance fish source_posix_env ($HOME expansion) | complete | [phase-03](phase-03-enhance-fish-source-posix-env.md) |
| 4 | Create 00-load-homebrew for Zsh + Bash | complete | [phase-04](phase-04-create-homebrew-loaders.md) |
| 5 | Strip per-shell 10-common.env files | complete | [phase-05](phase-05-strip-common-env-files.md) |
| 6 | Strip 20-os files + delete dead code | complete | [phase-06](phase-06-strip-os-files-delete-dead-code.md) |
| 7 | Verify with chezmoi dry-run | complete | [phase-07](phase-07-verify-chezmoi-dry-run.md) |
| 8 | Update architecture docs | complete | [phase-08](phase-08-update-docs.md) |

## Key Dependencies

- Phases 1-2 can run in parallel (separate files)
- Phase 3 independent (fish function only)
- Phase 4 independent (new files)
- Phase 5 depends on 1-3 (removing vars that must exist in centralized first)
- Phase 6 depends on 4 (removing brew init that must exist in 00-load-homebrew first)
- Phase 7 depends on all previous
- Phase 8 depends on 7

## Architecture (after completion)

```
~/.config/env/                          # Glob-loaded by all shells
├── 10-shared.env                       # Config: LANG, EDITOR, CLICOLOR, etc.
├── 15-services.env                     # Secrets: API tokens (neutral filename)
├── 20-os-darwin.env                    # macOS: XDG dirs
├── 20-os-linux.env                     # Linux: TMPDIR, WSL vars
├── 50-1password.env                    # Optional: 1Password CLI generated
└── 90-local.env                        # Optional: manual overrides

Shell load order:
  00-* → Setup (Homebrew for ALL shells, Fisher)
  05-* → Shared env (globs ~/.config/env/*.env)
  10-* → Shell-specific env (GPG_TTY, rm_opts, ZSH_*, HIST*)
  20-* → OS-specific init (ulimit, VSCode integration, GPG agent)
```

## Files to Create (3)

| Chezmoi Source | Target |
|---|---|
| `home/dot_config/private_env/15-services.env.tmpl` | `~/.config/env/15-services.env` |
| `home/dot_config/private_zsh/conf.d/00-load-homebrew.zsh.tmpl` | `~/.config/zsh/conf.d/00-load-homebrew.zsh` |
| `home/dot_config/private_bash/conf.d/00-load-homebrew.bash.tmpl` | `~/.config/bash/conf.d/00-load-homebrew.bash` |

## Files to Modify (11)

| File | Action |
|---|---|
| `private_env/10-shared.env.tmpl` | Remove tokens, add 11 centralized vars |
| `private_fish/functions/source_posix_env.fish` | Add $HOME expansion |
| `private_fish/conf.d/00-load-homebrew.fish.tmpl` | Add Linux linuxbrew support |
| `private_fish/conf.d/10-common.env.fish.tmpl` | Strip to GPG_TTY only |
| `private_zsh/conf.d/10-common.env.zsh.tmpl` | Strip centralized vars + dead code |
| `private_bash/conf.d/10-common.env.bash.tmpl` | Strip centralized vars + dead code |
| `private_fish/conf.d/20-os.darwin.env.fish.tmpl` | Remove redundant EDITOR + comments |
| `private_zsh/conf.d/20-os.darwin.env.zsh.tmpl` | Remove comments + brew FPATH |
| `private_bash/conf.d/20-os.darwin.env.bash.tmpl` | Remove comments |
| `private_fish/conf.d/20-os.linux.env.fish.tmpl` | Remove centralized TMPDIR + comments |
| `private_zsh/conf.d/20-os.linux.env.zsh.tmpl` | Remove linuxbrew + comments |
| `private_bash/conf.d/20-os.linux.env.bash.tmpl` | Remove linuxbrew + comments |
