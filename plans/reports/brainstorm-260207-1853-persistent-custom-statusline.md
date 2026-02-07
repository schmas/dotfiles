# Brainstorm: Persistent Custom Statusline Across CK Updates

## Problem
`ck init` overwrites `statusline.cjs` (ownership: `ck`) and selective-merges `settings.json` (resets `statusLine.command`). User customizations (like `[50k/200k]` token display) are lost every update.

## Evaluated Approaches

### 1. Post-init restore + custom file (CHOSEN)
- Create `statusline-custom.cjs` — CK doesn't track it
- After `ck init`, patch `settings.json` to point to custom file
- **Pros:** Zero CK conflicts, automated, clean separation
- **Cons:** Must maintain separate file, manual merge for upstream improvements

### 2. Chezmoi-managed settings.json
- Manage settings.json via chezmoi templates
- **Pros:** Declarative, version-controlled
- **Cons:** CK and chezmoi both want to own settings.json — conflict risk high

### 3. Metadata ownership hack
- Change `statusline.cjs` ownership from `ck` to `user` in metadata.json
- **Pros:** CK skips user-owned files
- **Cons:** metadata.json itself gets overwritten by `ck init` — fragile

## Recommended Solution

### Architecture
```
ck update --yes  (also triggers ck init internally)
  → CK overwrites statusline.cjs (we don't use it)
  → CK resets settings.json statusLine → statusline.cjs
  ↓
restore-statusline step (in claude-update, right after ck update)
  → Patches settings.json: statusLine.command → statusline-custom.cjs
```

### Files to Create/Modify

1. **`~/.claude/statusline-custom.cjs`** — Fork of CK's statusline with:
   - Token display: `[50k/200k]` alongside percentage
   - Any other personal customizations
   - Uses same CK lib imports (colors.cjs, transcript-parser.cjs, etc.)

2. **`~/bin/claude-update` (chezmoi managed)** — Add restore step:
   - After `ck update`, run `jq` to patch settings.json statusLine.command
   - Idempotent: safe to run multiple times

### Key Details
- `statusline-custom.cjs` lives in `~/.claude/` but NOT tracked by CK metadata
- CK's selective merge only touches keys it knows about — custom file is invisible
- `jq` one-liner: `.statusLine.command = "node $HOME/.claude/statusline-custom.cjs"`
- The custom file can `require()` CK's lib modules (colors.cjs, etc.) since those stay in place

## Success Criteria
- `ck init --global --yes` followed by `claude-update` restore → custom statusline active
- Token display shows `[50k/200k]` format
- No manual intervention needed

## Next Steps
- Implement via `/plan` command
