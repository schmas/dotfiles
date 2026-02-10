# Phase 3: Enhance Fish source_posix_env ($HOME Expansion)

## Context
- Parent: [plan.md](plan.md)
- Independent (no dependencies)

## Overview
- **Priority**: Medium
- **Status**: pending
- **Description**: Add `$HOME` variable expansion to fish `source_posix_env` function so centralized .env files can use `$HOME` in values.

## Key Insights
- Current fish parser does literal string matching — `$HOME` stored as literal string
- Bash/Zsh loaders use `. "$f"` which naturally expands `$HOME`
- Only need `$HOME` expansion (not general variable expansion) — KISS

## Requirements
- `DOTFILES_BIN=$HOME/bin` must resolve to `/Users/schmas/bin` in fish
- No other variable expansion needed
- Must not break existing literal values

## Architecture
```
Before: set -gx DOTFILES_BIN "$HOME/bin"  (literal $HOME)
After:  set -gx DOTFILES_BIN "/Users/schmas/bin"  (expanded)
```

## Related Code Files
- **Modify**: `home/dot_config/private_fish/functions/source_posix_env.fish`

## Implementation Steps

1. Edit `source_posix_env.fish`, add `$HOME` expansion after quote stripping (line 7):

Current:
```fish
set -l val (string replace -r '^["\'](.*)["\']$' '$1' -- $kv[3])
set -gx $kv[2] $val
```

New:
```fish
set -l val (string replace -r '^["\'](.*)["\']$' '$1' -- $kv[3])
set -l val (string replace -a '$HOME' "$HOME" -- $val)
set -gx $kv[2] $val
```

## Todo
- [ ] Add `$HOME` expansion line to `source_posix_env.fish`
- [ ] Test: `echo 'FOO=$HOME/test' > /tmp/test.env && source_posix_env /tmp/test.env && echo $FOO`

## Success Criteria
- `$HOME` in .env values expands to actual home directory
- Existing literal values (no `$HOME`) unchanged
- Tokens with special characters still work

## Risk Assessment
- **Low**: Simple string replacement, only affects values containing literal `$HOME`
- Won't interfere with `$HOME` inside quoted strings since quotes stripped first
