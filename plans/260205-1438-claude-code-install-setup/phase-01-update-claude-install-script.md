---
phase: 1
title: "Update Claude Install Script"
status: complete
effort: 30m
---

# Phase 1: Update Claude Install Script

## Context Links

- [Parent Plan](./plan.md)
- [Code Standards](../docs/code-standards.md)
- [Existing Script](../home/.chezmoiscripts/01-common/run_once_after_03-claude-install.sh.tmpl)

## Overview

- **Priority:** P2
- **Status:** Complete
- **Description:** Enhance existing Claude Code install script to clone user's config repo and run setup

## Key Insights

1. Script already exists with basic Claude Code installation
2. Need to handle `~/.claude` directory state (may exist from previous install, may not exist)
3. Plugin installation requires manual steps inside Claude Code session
4. Script must be idempotent for `run_once` behavior

## Requirements

### Functional
- Install Claude Code CLI if not present
- Clone `git@github.com:schmas/claude-config.git` to `~/.claude`
- Handle existing `~/.claude` directory (backup or skip clone)
- Run `./setup.sh` from cloned repo
- Display plugin installation instructions

### Non-Functional
- Idempotent execution
- Clear error messages
- Exit gracefully on non-critical failures

## Architecture

```
Script Flow:
┌─────────────────────────────┐
│ Check Claude Code installed │
├─────────────────────────────┤
│ No  → Install via curl      │
│ Yes → Skip install          │
├─────────────────────────────┤
│ Check ~/.claude exists      │
├─────────────────────────────┤
│ Yes (git repo) → git pull   │
│ Yes (not repo) → backup+clone│
│ No  → git clone             │
├─────────────────────────────┤
│ Run setup.sh                │
├─────────────────────────────┤
│ Print plugin instructions   │
└─────────────────────────────┘
```

## Related Code Files

### Modify
- `home/.chezmoiscripts/01-common/run_once_after_03-claude-install.sh.tmpl`

### Create
- `home/bin/executable_setup-claude-code` - Standalone script for manual use

## Implementation Steps

1. **Keep existing Claude Code installation logic** (lines 1-12)

2. **Add config repo setup section:**
   ```bash
   CLAUDE_CONFIG_DIR="$HOME/.claude"
   CLAUDE_CONFIG_REPO="git@github.com:schmas/claude-config.git"
   ```

3. **Handle ~/.claude directory states:**
   - If dir exists and is git repo → `git pull`
   - If dir exists but not git repo → backup to `~/.claude.backup.{timestamp}` then clone
   - If dir doesn't exist → clone

4. **Run setup.sh:**
   ```bash
   if [ -x "$CLAUDE_CONFIG_DIR/setup.sh" ]; then
     cd "$CLAUDE_CONFIG_DIR" && ./setup.sh
   fi
   ```

5. **Display plugin instructions:**
   ```bash
   echo ""
   echo "=== Claude Code Setup Complete ==="
   echo "To install plugins, open Claude Code and run:"
   echo "  /plugin install claude-plugins-official"
   echo "  /plugin install mgrep"
   ```

6. **Create standalone bin script:**
   - Create `home/bin/executable_setup-claude-code`
   - Same logic as chezmoi script but standalone
   - Can be run manually via `setup-claude-code` command

## Todo List

- [x] Update chezmoi script with config repo variables
- [x] Implement directory state handling in chezmoi script
- [x] Add setup.sh execution
- [x] Add plugin instruction display
- [x] Create standalone `bin/executable_setup-claude-code` script
- [x] Test on macOS
- [x] Test idempotency

## Success Criteria

- [x] Script completes without errors on fresh system
- [x] Script completes without errors on system with existing `~/.claude`
- [x] Git pull works when config repo already cloned
- [x] setup.sh executes successfully
- [x] Plugin instructions displayed clearly
- [x] No data loss (backup before overwrite)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| SSH key not configured | Medium | Script fails to clone | Clear error message, document prerequisite |
| setup.sh missing | Low | Script continues | Check file exists before execution |
| Network failure | Low | Partial install | Script can be re-run |

## Security Considerations

- Uses SSH for GitHub clone (requires SSH key)
- No secrets stored in script
- Backup preserves user data before overwrite

## Next Steps

After implementation:
1. Test with `chezmoi apply --dry-run`
2. Apply changes with `chezmoi apply`
3. Manually install plugins in Claude Code
