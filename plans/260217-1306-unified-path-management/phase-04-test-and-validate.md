# Phase 04: Test and Validate

## Context Links
- Parent: [plan.md](./plan.md)
- Depends on: All previous phases complete

## Overview
- **Priority:** High (validation gate)
- **Status:** Complete
- **Description:** Verify PATH output matches expectations across Fish, Zsh, and Bash. Confirm no regressions in shell startup or missing paths.

## Key Insights
- Before migration: capture `echo $PATH` from each shell as baseline
- After migration: compare output — paths should be equivalent (order may differ slightly due to unified approach)
- `--glob` expansion depends on actual `~/bin/` subdirectories present

## Requirements
- PATH contains all expected entries in each shell
- `--check` paths only appear when their dirs exist
- `--glob` paths expand correctly
- Shell startup time not degraded
- No duplicate entries (Fish/Zsh handle natively, Bash via awk dedup)

## Implementation Steps

### 1. Capture baseline (BEFORE migration)

Run before any changes:
```bash
# Save current PATH from each shell
fish -c 'echo $PATH' | tr ' ' '\n' > /tmp/path-fish-before.txt
zsh -c 'echo $PATH' | tr ':' '\n' > /tmp/path-zsh-before.txt
bash -c 'echo $PATH' | tr ':' '\n' > /tmp/path-bash-before.txt
```

### 2. Apply changes and capture new PATH

After all phases applied:
```bash
chezmoi apply

# Capture new PATH (new shell sessions)
fish -c 'echo $PATH' | tr ' ' '\n' > /tmp/path-fish-after.txt
zsh -c 'echo $PATH' | tr ':' '\n' > /tmp/path-zsh-after.txt
bash -c 'echo $PATH' | tr ':' '\n' > /tmp/path-bash-after.txt
```

### 3. Compare before/after

```bash
diff /tmp/path-fish-before.txt /tmp/path-fish-after.txt
diff /tmp/path-zsh-before.txt /tmp/path-zsh-after.txt
diff /tmp/path-bash-before.txt /tmp/path-bash-after.txt
```

Expected diffs:
- Bash may gain dedup (fewer entries) — improvement
- Order within `bin/` subdirs may change (glob order vs hardcoded) — acceptable
- No paths should be **missing**

### 4. Verify flag behavior

```bash
# --check: temporarily rename a checked dir, verify it's skipped
# (manual test — rename /opt/homebrew/opt/libpq/bin, open new shell, check PATH)

# --glob: verify bin subdirs present
fish -c 'echo $PATH' | tr ' ' '\n' | grep '/bin/'
# Should show: ~/bin, ~/bin/git-scripts, ~/bin/macos, ~/bin/etc, ~/bin/nix

# --append: if any paths use it, verify they're at end of PATH
```

### 5. Measure startup time

```bash
# Fish
time fish -c exit     # Should be < 200ms

# Zsh
time zsh -c exit      # Should be < 200ms

# Bash
time bash -l -c exit  # Should be < 200ms
```

Compare with pre-migration times. Regression threshold: +50ms.

### 6. Cross-shell consistency check

```bash
# Extract just the custom paths (not system paths) and compare
fish -c 'echo $PATH' | tr ' ' '\n' | grep -E '(HOME|local|homebrew|antigravity)' | sort > /tmp/custom-fish.txt
zsh -c 'echo $PATH' | tr ':' '\n' | grep -E '(home|local|homebrew|antigravity)' | sort > /tmp/custom-zsh.txt
bash -c 'echo $PATH' | tr ':' '\n' | grep -E '(home|local|homebrew|antigravity)' | sort > /tmp/custom-bash.txt

diff /tmp/custom-fish.txt /tmp/custom-zsh.txt
diff /tmp/custom-zsh.txt /tmp/custom-bash.txt
```

All custom paths should be identical across shells.

## Todo List
- [ ] Capture baseline PATH from all 3 shells (BEFORE changes)
- [ ] Apply chezmoi changes
- [ ] Compare before/after PATH output
- [ ] Verify `--check` skips missing dirs
- [ ] Verify `--glob` expands subdirectories
- [ ] Measure startup time — no regression
- [ ] Confirm cross-shell consistency
- [ ] Open new terminal tabs, verify normal operation

## Success Criteria
- No missing paths compared to baseline
- Custom paths identical across Fish/Zsh/Bash
- Startup time within 50ms of baseline
- `chezmoi status` clean
- New shell sessions work normally

## Risk Assessment
- **PATH order change breaks tool resolution:** If a tool exists in multiple PATH dirs, different order could pick different version. Mitigated by comparing `which` output for key tools.
- **Startup regression:** Measured with `time` command. Bash dedup awk is the only risk — single invocation should be < 5ms.

## Security Considerations
- None — testing only, no code changes.

## Next Steps
- If all tests pass: commit changes with `feat(shell): unify PATH management across shells`
- Update `SHELL-REFERENCE.md` if path-related docs exist there
