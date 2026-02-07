---
title: "Persistent Custom Statusline"
description: "Custom statusline that survives ck update --yes with [50k/200k] token display"
status: complete
priority: P3
effort: 30m
branch: main
tags: [claudekit, statusline, customization]
created: 2026-02-07
---

# Persistent Custom Statusline

## Problem
`ck update --yes` (triggers `ck init`) overwrites `statusline.cjs` and resets `settings.json` `statusLine.command`. User customizations lost every update.

## Solution
Create `statusline-custom.cjs` (not CK-tracked) + post-update restore step in `claude-update`.

## Phases

| # | Phase | Status | Effort | File |
|---|-------|--------|--------|------|
| 1 | [Create custom statusline](./phase-01-create-custom-statusline.md) | complete | 20m | `~/.claude/statusline-custom.cjs` |
| 2 | [Update claude-update script](./phase-02-update-claude-update-script.md) | complete | 10m | `home/bin/executable_claude-update` |

## Architecture

```
ck update --yes
  → CK overwrites statusline.cjs (we don't use it)
  → CK resets settings.json statusLine → statusline.cjs
  ↓
claude-update restore step
  → jq patches settings.json: statusLine.command → statusline-custom.cjs
  → Custom statusline active again
```

## Key Decisions
- `statusline-custom.cjs` lives in `~/.claude/` but NOT in CK's metadata.json
- Uses same CK lib imports (colors.cjs, transcript-parser.cjs, etc.) — those persist
- Only diff from upstream: add `[50k/200k]` token count display + pass `totalTokens`/`contextSize` through ctx

## Dependencies
- `jq` must be installed (already present via Brewfile)
- CK lib modules must remain at `hooks/lib/` (CK convention, stable)

## Reports
- [Brainstorm](../reports/brainstorm-260207-1853-persistent-custom-statusline.md)
