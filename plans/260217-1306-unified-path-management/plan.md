---
title: "Unified PATH Management"
description: "Replace 9 per-shell PATH configs with shared ~/.config/path/*.path system mirroring the env pattern"
status: complete
priority: P2
effort: 2h
branch: main
tags: [refactor, shell, dotfiles, infra]
created: 2026-02-17
completed: 2026-02-17
---

# Unified PATH Management

## Overview

Replace 9 shell-specific PATH config files (3 shells x 3 configs each) with a shared data system. PATH entries live in `~/.config/path/*.path` files — one path per line with `--check`/`--glob`/`--append` flags. Per-shell loaders parse these files, mirroring how `~/.config/env/*.env` works.

## Problem

- PATH duplicated across Fish/Zsh/Bash with inconsistencies
- Bash hardcodes bin/ subdirs; Fish/Zsh loop
- Linux Zsh/Bash duplicate paths
- Adding a path = editing 3 files

## Phases

| # | Phase | Status | Effort | Link |
|---|-------|--------|--------|------|
| 1 | Create shared path data files | Complete | 20m | [phase-01](./phase-01-create-path-data-files.md) |
| 2 | Create per-shell loaders + parsers | Complete | 1h | [phase-02](./phase-02-create-loaders-and-parsers.md) |
| 3 | Remove old files + chezmoi cleanup | Complete | 20m | [phase-03](./phase-03-remove-old-files.md) |
| 4 | Test and validate | Complete | 20m | [phase-04](./phase-04-test-and-validate.md) |

## Dependencies

- Brainstorm: [brainstorm report](../reports/brainstorm-260217-1306-unified-path-management.md)
- Existing env system: `home/dot_config/private_env/*.env.tmpl` + per-shell `05-shared-env.*`
- Fish parser reference: `home/dot_config/private_fish/functions/source_posix_env.fish`

## File Format Spec

```bash
# One path per line. Default: prepend, no existence check.
# Flags (--prefixed, after path):
#   --check   only add if directory exists
#   --glob    add this dir + all immediate subdirectories
#   --append  add to end of PATH instead of prepending
# $HOME expanded. Quotes for paths with spaces. # for comments.

$HOME/.local/bin
$HOME/bin  --glob
/opt/homebrew/opt/coreutils/libexec/gnubin  --check
```
