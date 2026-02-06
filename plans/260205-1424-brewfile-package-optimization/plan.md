---
title: "Brewfile Package Optimization"
description: "Remove redundant packages and add modern CLI tools"
status: complete
priority: P2
effort: 15m
branch: feat/nix-to-homebrew-migration
tags: [brewfile, packages, optimization]
created: 2026-02-05
---

# Brewfile Package Optimization

## Overview

Optimize `home/Brewfile` by removing redundant packages (handled by mise or unused) and adding modern CLI utilities.

## Phases

| Phase | Description | Status | Effort |
|-------|-------------|--------|--------|
| [Phase 01](./phase-01-update-brewfile.md) | Update Brewfile | complete | 15m |

## Summary of Changes

### Remove (4 packages)

| Package | Line | Reason |
|---------|------|--------|
| `python@3` | 68 | macOS has Python 3; use mise for version management |
| `usage` | 67 | Already managed by mise |
| `age` | 88 | Already managed by mise |
| `carapace` | 16 | User confirmed not using |

### Add (7 packages)

| Package | Section | Description |
|---------|---------|-------------|
| `hyperfine` | Utilities | CLI benchmarking tool |
| `just` | Development | Task runner (Makefile alternative) |
| `tokei` | Development | Code statistics |
| `sd` | File Tools | Modern sed replacement |
| `procs` | Monitoring | Modern ps replacement |
| `dust` | File Tools | Modern du replacement |
| `delta` | Version Control | Git diff viewer |

## Dependencies

- None; straightforward file edit

## Risks

- Low risk; packages are well-established Homebrew formulae
- No breaking changes to existing shell configs

## Success Criteria

- [x] Brewfile updated with removals and additions
- [x] `chezmoi apply --dry-run` succeeds
- [x] `brew bundle --file=~/Brewfile` runs without errors
