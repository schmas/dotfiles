# Code Review: Claude Code Setup Scripts

**Date:** 2026-02-05 15:42
**Reviewer:** code-reviewer
**Branch:** feat/nix-to-homebrew-migration

## Scope

- **Files:** 2
- **LOC:** 143 total (64 + 79)
- **Focus:** Claude Code CLI install & config automation

| File | Lines | Purpose |
|------|-------|---------|
| `home/.chezmoiscripts/01-common/run_once_after_03-claude-install.sh.tmpl` | 64 | Chezmoi automated setup |
| `home/bin/executable_setup-claude-code` | 79 | Standalone manual script |

## Overall Assessment

**Score: 7/10**

Solid implementation with good structure and reasonable error handling. Both scripts accomplish their goals but violate DRY significantly with near-identical code. The scripts follow repo conventions and handle edge cases like existing non-git directories well.

## Critical Issues

None found. No security vulnerabilities or breaking changes.

## High Priority

### 1. DRY Violation - Duplicated Code (75%+ identical)

Both scripts contain identical functions:
- `setup_claude_config()` - exact duplicate
- `run_setup_script()` - exact duplicate
- `show_plugin_instructions()` - exact duplicate

**Impact:** Maintenance burden; bugs fixed in one script won't be fixed in the other.

**Recommendation:** Have chezmoi script call the standalone script:

```bash
# In run_once_after_03-claude-install.sh.tmpl
#!/usr/bin/env bash
set -euo pipefail

# Use already-installed script or fallback to direct execution
if [ -x "$HOME/bin/setup-claude-code" ]; then
  "$HOME/bin/setup-claude-code"
elif [ -x "{{ .chezmoi.sourceDir }}/home/bin/executable_setup-claude-code" ]; then
  "{{ .chezmoi.sourceDir }}/home/bin/executable_setup-claude-code"
else
  echo "Warning: setup-claude-code script not found" >&2
fi
```

### 2. Pipe to Bash Security Pattern

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**Impact:** Standard pattern but downloads and executes arbitrary code without verification.

**Recommendation:** Accept this as industry-standard for CLI installers. The `-f` flag ensures failure on HTTP errors, `-s` silences progress, `-S` shows errors, `-L` follows redirects - all appropriate flags.

### 3. `cd` Without Returning to Original Directory

```bash
cd "$CLAUDE_CONFIG_DIR" && git pull --rebase
# Later...
cd "$CLAUDE_CONFIG_DIR" && ./setup.sh
```

**Impact:** Script changes cwd which could affect downstream scripts in chezmoi chain.

**Recommendation:** Use subshell or pushd/popd:

```bash
(cd "$CLAUDE_CONFIG_DIR" && git pull --rebase) || echo "Warning: git pull failed" >&2
```

## Medium Priority

### 4. Inconsistent Error Handling Strategy

- CLI install: "Warning" on failure, continues
- git pull: "Warning" on failure, continues
- git clone: No try/catch, would exit on failure (set -e)

**Impact:** Inconsistent behavior - some failures are soft, others hard.

**Recommendation:** Be explicit about what's critical vs optional:

```bash
# Critical - must succeed
git clone "$CLAUDE_CONFIG_REPO" "$CLAUDE_CONFIG_DIR" || { echo "Error: Clone failed" >&2; return 1; }

# Optional - nice to have
git pull --rebase 2>/dev/null || echo "Note: git pull failed, using cached config" >&2
```

### 5. SSH URL Hardcoded (No HTTPS Fallback)

```bash
CLAUDE_CONFIG_REPO="git@github.com:schmas/claude-config.git"
```

**Impact:** Fails silently if SSH keys not configured (fresh system bootstrap).

**Recommendation:** Add HTTPS fallback or check SSH agent:

```bash
if ssh-add -l >/dev/null 2>&1; then
  CLAUDE_CONFIG_REPO="git@github.com:schmas/claude-config.git"
else
  CLAUDE_CONFIG_REPO="https://github.com/schmas/claude-config.git"
fi
```

### 6. Missing Quotes in Comparisons

```bash
[ $attempt -le $max_attempts ]  # mise-install.sh pattern
```

Not in these scripts but noted as comparison - the reviewed scripts properly quote variables.

## Low Priority

### 7. No Version Check for Claude CLI

Scripts check existence but not version. Won't auto-update.

**Recommendation:** Accept for now; user can run installer manually to update.

### 8. Plugin Instructions Reference Wrong Command

```bash
echo "  /install claude-plugins-official"
```

Plan document says `/plugin install`, script says `/install`. Verify correct command.

### 9. Redundant Comment in Standalone Script

```bash
# Standalone script for manual execution (also embedded in chezmoi run_once script)
```

This comment is misleading if scripts are deduplicated.

## Positive Observations

1. **Strict Mode:** Both scripts use `set -euo pipefail` - excellent
2. **Idempotent:** Safe to run multiple times; checks existing state
3. **Backup Strategy:** Creates timestamped backup before overwriting non-git dirs
4. **PATH Awareness:** Chezmoi script checks both `command -v` and direct path (handles partial PATH loading)
5. **Consistent Structure:** Functions are well-named and single-purpose
6. **Clear Output:** Good user feedback with echo statements
7. **Executable Check:** Properly handles non-executable setup.sh with `bash` fallback

## Edge Cases Found

| Case | Handled | Notes |
|------|---------|-------|
| Claude CLI already installed | Yes | Skips installation |
| ~/.claude exists as git repo | Yes | Pulls latest |
| ~/.claude exists but not git | Yes | Backs up and clones |
| ~/.claude doesn't exist | Yes | Clones fresh |
| setup.sh doesn't exist | Yes | Prints note, continues |
| setup.sh exists but not executable | Yes | Falls back to `bash setup.sh` |
| No network connection | Partial | curl has -f flag but no retry |
| SSH keys not loaded | No | Will fail on git clone |

## Recommended Actions

1. **[High]** Refactor to eliminate duplication - chezmoi script should call standalone script
2. **[Medium]** Use subshells for `cd` to preserve working directory
3. **[Medium]** Add HTTPS fallback for fresh system bootstrap
4. **[Low]** Verify correct plugin install command syntax
5. **[Low]** Update plan.md success criteria checkboxes to reflect completion

## Metrics

| Metric | Value |
|--------|-------|
| Lines of Code | 143 |
| Functions | 8 (4 unique, 4 duplicated) |
| Duplicate Code | ~55 lines (75%) |
| Error Handling | Inconsistent |
| Shellcheck | Not available (not installed) |

## Unresolved Questions

1. Is `/install` or `/plugin install` the correct Claude Code command for plugins?
2. Should the scripts support private repos that require auth tokens instead of SSH?
3. Should there be a `--force` flag to re-clone even if git repo exists?
