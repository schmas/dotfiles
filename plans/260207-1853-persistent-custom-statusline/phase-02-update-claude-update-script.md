# Phase 02: Update claude-update Script

## Context
- Parent: [plan.md](./plan.md)
- Depends on: [Phase 01](./phase-01-create-custom-statusline.md) (statusline-custom.cjs must exist)

## Overview
- **Priority:** P3
- **Status:** complete
- **Description:** Add post-ck-update restore step to `claude-update` script that patches settings.json

## Key Insights
- `ck update --yes` triggers `ck init` internally, which selective-merges settings.json
- The selective merge resets `statusLine.command` to `node $HOME/.claude/statusline.cjs`
- Need to patch it back to `node $HOME/.claude/statusline-custom.cjs` after every update
- `jq` is already installed via Brewfile — safe to depend on

## Requirements
- Restore step runs AFTER `ck update --yes`
- Idempotent: safe if statusline-custom.cjs is already set
- In-place edit of settings.json preserving all other keys
- Informative echo message for user feedback

## Related Code Files
- **Modify:** `home/bin/executable_claude-update` (chezmoi source)
- **Target:** `~/.claude/settings.json` (patched at runtime)

## Implementation Steps

### Step 1: Add restore block after ck update
Insert after the `ck update --yes` + `echo` block (after line 25):

```bash
# Restore custom statusline (ck update resets to default)
echo -e "${YELLOW}Restoring custom statusline...${NC}"
if [ -f ~/.claude/statusline-custom.cjs ]; then
  jq '.statusLine.command = "node $HOME/.claude/statusline-custom.cjs"' \
    ~/.claude/settings.json > ~/.claude/settings.json.tmp \
    && mv ~/.claude/settings.json.tmp ~/.claude/settings.json
  echo -e "${GREEN}Custom statusline restored${NC}"
else
  echo -e "${YELLOW}No custom statusline found, using default${NC}"
fi
echo
```

### Key Details
- Uses `jq` for safe JSON manipulation (no sed/awk on JSON)
- Writes to `.tmp` then `mv` for atomic update (no partial writes)
- Guards on `statusline-custom.cjs` existence — graceful fallback if file missing
- Preserves all other settings.json content (jq only modifies the one key)

## Todo
- [x] Add restore block to executable_claude-update after ck update step
- [x] Test: run `chezmoi apply --dry-run --verbose` to verify template output
- [x] Test: run `claude-update` end-to-end and verify settings.json has custom command

## Success Criteria
- After `claude-update`, `settings.json` has `statusLine.command` pointing to `statusline-custom.cjs`
- Script doesn't fail if `statusline-custom.cjs` is missing
- All other settings.json content preserved

## Risk Assessment
- **Low:** `jq` not installed → script fails. Mitigation: jq is in Brewfile, always present.
- **Low:** settings.json has no `statusLine` key yet → jq creates it. This is fine.
