---
title: "Claude Code Install & Setup Script"
description: "Enhance chezmoi script to install Claude Code CLI and configure with user's custom config repo"
status: complete
priority: P2
effort: 45m
branch: feat/nix-to-homebrew-migration
tags: [chezmoi, claude-code, setup, automation]
created: 2026-02-05
---

# Claude Code Install & Setup Script

## Overview

Enhance existing `run_once_after_03-claude-install.sh.tmpl` to:
1. Install Claude Code via native installer (already implemented)
2. Clone user's claude-config repo to `~/.claude`
3. Run the setup script from the cloned repo
4. Display plugin installation instructions (manual step in Claude Code)

## Current State

**Existing script:** `home/.chezmoiscripts/01-common/run_once_after_03-claude-install.sh.tmpl`
- Installs Claude Code CLI via `curl -fsSL https://claude.ai/install.sh | bash`
- Checks for existing installation before running
- Basic error handling

**Missing:**
- Clone `git@github.com:schmas/claude-config.git` to `~/.claude`
- Run `./setup.sh` from cloned repo
- Display manual plugin install instructions

## Implementation Phases

| Phase | Description | Status | Effort |
|-------|-------------|--------|--------|
| [Phase 1](./phase-01-update-claude-install-script.md) | Update chezmoi script + create standalone bin script | Complete | 45m |

## Files to Modify

- `home/.chezmoiscripts/01-common/run_once_after_03-claude-install.sh.tmpl`

## Files to Create

- `home/bin/executable_setup-claude-code` - Standalone script for manual execution

## Success Criteria

- [x] Chezmoi script installs Claude Code if not present
- [x] Chezmoi script clones claude-config repo to `~/.claude` (handles existing dir)
- [x] Chezmoi script runs setup.sh from cloned repo
- [x] Scripts display manual plugin instructions
- [x] Scripts are idempotent (safe to run multiple times)
- [x] Works on macOS and Linux
- [x] Standalone `setup-claude-code` script available in PATH

## Dependencies

- Git (SSH access to GitHub)
- curl
- Bash

## Notes

Plugin installation must be done manually inside Claude Code:
```
/plugin install claude-plugins-official
/plugin install mgrep
```
These cannot be automated as they require Claude Code interactive session.
