---
title: "AAA Workspace Backup & Setup Script"
description: "Standalone bash script for backing up and restoring AAA Connect+ workspace"
status: complete
priority: P2
effort: 1h
branch: main
tags: [chezmoi, bash, backup, workspace]
created: 2026-02-05
---

# AAA Workspace Backup & Setup Script

## Summary

Create `home/bin/executable_aaa-workspace` — a bash script with `backup` and `setup` subcommands for the AAA Connect+ workspace.

## Key Facts

| Item | Detail |
|------|--------|
| Script path | `home/bin/executable_aaa-workspace` (becomes `~/bin/aaa-workspace`) |
| Workspace | `~/projects/work/aaa/` |
| Backup dest | `$HOME/Documents/01.1_Projects/01_AAA_Connect+/` |
| data-integration size | ~552MB (compress) |
| connect-plus-db size | ~6.8GB (compress) |
| Bitbucket org | `aaa-national` |
| SSH host | `bitbucket-aaa` (SSH alias in config) |

## Git Remotes (discovered)

```
connect-plus-backend  → git@bitbucket.org:aaa-national/connect-plus-backend.git
connect-plus-frontend → git@bitbucket-aaa:aaa-national/connect-plus-frontend.git
connectsuiteapps      → git@bitbucket.org:aaa-national/connectsuiteapps.git
```

> Note: frontend uses `bitbucket-aaa` SSH host alias. Script should normalize to `bitbucket-aaa` for all repos (works with SSH config).

## Phases

| # | Phase | Status | File |
|---|-------|--------|------|
| 1 | Implement script | complete | [phase-01](phase-01-implement-script.md) |

## Design Decisions

1. **Not a template** — no chezmoi variables needed, plain bash script
2. **Normalize SSH host** to `bitbucket-aaa` for all repos (user has SSH alias configured)
3. **Tar with gzip** for compression (`tar czf`)
4. **Timestamped archives** not needed — overwrite previous backup (KISS)
5. **Style** — match existing `executable_upall.tmpl` pattern: `set -e`, echo progress, simple structure
