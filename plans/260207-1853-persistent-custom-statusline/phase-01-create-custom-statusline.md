# Phase 01: Create Custom Statusline

## Context
- Parent: [plan.md](./plan.md)
- Brainstorm: [brainstorm report](../reports/brainstorm-260207-1853-persistent-custom-statusline.md)
- Source: `~/.claude/statusline.cjs` (CK upstream, 572 lines)

## Overview
- **Priority:** P3
- **Status:** complete
- **Description:** Fork CK's statusline.cjs → statusline-custom.cjs with token count display `[50k/200k]`

## Key Insights
- CK's `statusline.cjs` already computes `totalTokens` and `contextSize` in `main()` (lines 448-457)
- But these values are NOT passed to renderers via the `ctx` object (line 522-539)
- Need to: (a) add `totalTokens` + `contextSize` to ctx, (b) use them in 3 render functions

## Requirements
- Show `[50k/200k]` alongside existing percentage bar in all modes
- Keep all CK lib imports unchanged (colors.cjs, transcript-parser.cjs, etc.)
- File must be `~/.claude/statusline-custom.cjs` (NOT tracked by CK metadata)

## Related Code Files
- **Create:** `~/.claude/statusline-custom.cjs`
- **Reference:** `~/.claude/statusline.cjs` (upstream to fork from)
- **Reference:** `~/.claude/hooks/lib/colors.cjs` (imported, stable)
- **Reference:** `~/.claude/hooks/lib/transcript-parser.cjs` (imported, stable)
- **Reference:** `~/.claude/hooks/lib/config-counter.cjs` (imported, stable)
- **Reference:** `~/.claude/hooks/lib/ck-config-utils.cjs` (imported, stable)

## Implementation Steps

### Step 1: Copy statusline.cjs → statusline-custom.cjs
```bash
cp ~/.claude/statusline.cjs ~/.claude/statusline-custom.cjs
```

### Step 2: Add helper function for token formatting
Add after `formatElapsed()` (around line 94):
```javascript
/**
 * Format token count as human-readable [used/total] string
 * e.g., [50k/200k] or [150k/1M]
 */
function formatTokens(used, total) {
  const fmt = (n) => {
    if (n >= 1000000) return `${Math.round(n / 1000000)}M`;
    return `${Math.round(n / 1000)}k`;
  };
  return `[${fmt(used)}/${fmt(total)}]`;
}
```

### Step 3: Add totalTokens and contextSize to ctx object
In `main()`, modify the ctx object (around line 522) to include:
```javascript
const ctx = {
  // ... existing fields ...
  totalTokens,    // ADD
  contextSize,    // ADD
  // ... rest ...
};
```

### Step 4: Modify renderSessionLines() (full mode)
At line 161-163, change:
```javascript
// BEFORE:
if (ctx.contextPercent > 0) {
  sessionPart += `  ${coloredBar(ctx.contextPercent, 12)} ${ctx.contextPercent}%`;
}

// AFTER:
if (ctx.contextPercent > 0) {
  sessionPart += `  ${coloredBar(ctx.contextPercent, 12)} ${ctx.contextPercent}%`;
  if (ctx.totalTokens > 0 && ctx.contextSize > 0) {
    sessionPart += ` ${dim(formatTokens(ctx.totalTokens, ctx.contextSize))}`;
  }
}
```

### Step 5: Modify renderMinimal() (minimal mode)
At line 327-328, change:
```javascript
// BEFORE:
parts.push(`${batteryIcon} ${ctx.contextPercent}%`);

// AFTER:
let ctxStr = `${ctx.contextPercent}%`;
if (ctx.totalTokens > 0 && ctx.contextSize > 0) {
  ctxStr += ` ${formatTokens(ctx.totalTokens, ctx.contextSize)}`;
}
parts.push(`${batteryIcon} ${ctxStr}`);
```

### Step 6: Modify renderCompact() (compact mode)
At line 343-344, change:
```javascript
// BEFORE:
line1 += `  ${coloredBar(ctx.contextPercent, 12)} ${ctx.contextPercent}%`;

// AFTER:
line1 += `  ${coloredBar(ctx.contextPercent, 12)} ${ctx.contextPercent}%`;
if (ctx.totalTokens > 0 && ctx.contextSize > 0) {
  line1 += ` ${dim(formatTokens(ctx.totalTokens, ctx.contextSize))}`;
}
```

## Todo
- [x] Copy statusline.cjs to statusline-custom.cjs
- [x] Add formatTokens() helper function
- [x] Add totalTokens/contextSize to ctx object
- [x] Update renderSessionLines() with token display
- [x] Update renderMinimal() with token display
- [x] Update renderCompact() with token display
- [x] Test: run `echo '{}' | node ~/.claude/statusline-custom.cjs` — no crash

## Success Criteria
- `statusline-custom.cjs` renders `[50k/200k]` next to context bar
- All 3 modes (full, compact, minimal) show token counts
- File not tracked in `~/.claude/metadata.json`
- CK lib imports still work

## Risk Assessment
- **Low:** CK changes lib module APIs → custom file breaks. Mitigation: diff upstream statusline.cjs on next update, merge changes.
- **Low:** Token values are 0 on first render → `formatTokens` skipped via guard clause.
