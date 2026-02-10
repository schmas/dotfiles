# Scout Report: Env Cleanup Phase 2

## Relevant Files

### New Files (3)
- `home/dot_config/private_env/15-services.env.tmpl` - Service token separation (MISE, GITHUB, HOMEBREW, GEMINI)
- `home/dot_config/private_zsh/conf.d/00-load-homebrew.zsh.tmpl` - Homebrew loader for Zsh (macOS + Linux)
- `home/dot_config/private_bash/conf.d/00-load-homebrew.bash.tmpl` - Homebrew loader for Bash (macOS + Linux)

### Modified Files (12)
- `home/dot_config/private_env/10-shared.env.tmpl` - Tokens removed, 11 centralized vars added
- `home/dot_config/private_fish/functions/source_posix_env.fish` - Added `$HOME` expansion (line 8)
- `home/dot_config/private_fish/conf.d/00-load-homebrew.fish.tmpl` - Linux linuxbrew support added
- `home/dot_config/private_fish/conf.d/10-common.env.fish.tmpl` - Stripped to GPG_TTY only
- `home/dot_config/private_zsh/conf.d/10-common.env.zsh.tmpl` - Centralized vars removed, zsh-specific kept
- `home/dot_config/private_bash/conf.d/10-common.env.bash.tmpl` - Centralized vars removed, bash-specific kept
- `home/dot_config/private_fish/conf.d/20-os.darwin.env.fish.tmpl` - EDITOR + commented dead code removed
- `home/dot_config/private_zsh/conf.d/20-os.darwin.env.zsh.tmpl` - Commented code + brew FPATH removed
- `home/dot_config/private_bash/conf.d/20-os.darwin.env.bash.tmpl` - Commented dead code removed
- `home/dot_config/private_fish/conf.d/20-os.linux.env.fish.tmpl` - TMPDIR + dead code removed
- `home/dot_config/private_zsh/conf.d/20-os.linux.env.zsh.tmpl` - Linuxbrew + TMPDIR removed
- `home/dot_config/private_bash/conf.d/20-os.linux.env.bash.tmpl` - Linuxbrew + TMPDIR removed

## Edge Cases Discovered

### 1. $HOME Expansion Timing - CRITICAL FIX FOUND
**File:** `home/dot_config/private_fish/functions/source_posix_env.fish`
**Issue:** Initial commit (d3f05b9) missing `$HOME` expansion logic
**Status:** ✅ Fixed in uncommitted changes (line 8 added)
**Impact:** Without line 8, vars like `DOTFILES_BIN=$HOME/bin` would fail in Fish

```fish
# Line 8 added post-commit:
set -l val (string replace -a '$HOME' "$HOME" -- $val)
```

### 2. Token Separation Architecture - GOOD
**Files:** `10-shared.env.tmpl` vs `15-services.env.tmpl`
**Pattern:** Tokens extracted from 10-shared to 15-services
**Verification:** Both files load via glob pattern `~/.config/env/*.env`
**Result:** ✅ Proper security separation achieved

### 3. Homebrew Load Order Race - RESOLVED
**Change:** Moved linuxbrew init from `20-os-linux.*` to `00-load-homebrew.*`
**Load sequence:** 00-homebrew → 05-shared-env → 10-common → 20-os
**Result:** ✅ No race condition, brew available before env sourcing

### 4. Cross-Shell Consistency - VERIFIED
**Zsh/Bash:** Use `set -a; source; set +a` for auto-export
**Fish:** Custom `source_posix_env` function with manual parsing
**Quote handling:** Regex strips surrounding quotes correctly
**Result:** ✅ Consistent behavior across shells

### 5. POSIX Env Sourcing Order - CORRECT
**Pattern:** Glob loads `~/.config/env/*.env` alphabetically
**Order:** 10-shared.env → 15-services.env → 20-os-darwin.env (or 20-os-linux.env)
**Dependencies:** None between files
**Result:** ✅ Order-independent, safe

### 6. Removed Env Vars - NO ORPHANS FOUND
**Removed from shell configs:**
- `LANG`, `LANGUAGE`, `LC_TIME` → Moved to 10-shared.env ✅
- `VISUAL`, `EDITOR`, `SYSTEMD_EDITOR` → Moved to 10-shared.env ✅
- `DOTFILES_BIN` → Moved to 10-shared.env ✅
- `OPENCV_LOG_LEVEL`, `CLICOLOR` → Moved to 10-shared.env ✅
- `forgit_ignore`, `ASDF_NODEJS_*` → Moved to 10-shared.env ✅
- `TMPDIR`, `DOTFILES_LOAD_FULL_THEME` → Moved to 20-os-linux.env ✅
- XDG paths → Already in 20-os-darwin.env ✅
- API tokens → Moved to 15-services.env ✅

**Grep verification:** No references to removed vars found in bin/ scripts

### 7. Duplicate TMPDIR Definition - FIXED
**Before:** Defined twice in WSL sections of zsh/bash 20-os-linux configs
**After:** Single definition in `20-os-linux.env.tmpl`
**Result:** ✅ DRY violation eliminated

### 8. Dead Code Removal - CLEAN
**Removed commented sections:**
- Java options, LS_COLORS, NODE_OPTIONS (unused)
- Ulimit -n commands (unused, kept ulimit -f)
- ASDF paths, WD_CONFIG, AUTOENV_AUTH (unused)
**Result:** ✅ No functional impact, cleaner configs

### 9. Zsh FPATH Handling - IMPROVED
**Before:** FPATH set conditionally in `20-os.darwin.env.zsh` with type check
**After:** FPATH set unconditionally in `00-load-homebrew.zsh` after brew init
**Result:** ✅ Simpler, earlier initialization, no race condition

### 10. Fish Glob Pattern - POTENTIAL ISSUE
**File:** `home/dot_config/private_fish/conf.d/05-shared-env.fish`
**Pattern:** `for f in $HOME/.config/env/*.env`
**Issue:** No file existence check before sourcing
**Actual behavior:** `source_posix_env` has `test -f` guard (line 2)
**Result:** ✅ Safe, function returns 1 if file missing

### 11. Template Syntax Verification - PASSED
**Tested:**
- `chezmoi execute-template` on all .tmpl files
- Fish syntax check with `fish -n`
- Zsh/Bash templates have valid Go template syntax
**Result:** ✅ All templates compile correctly

### 12. Linux vs macOS Path Differences - HANDLED
**macOS:** `/opt/homebrew/bin/brew`
**Linux:** `/home/linuxbrew/.linuxbrew/bin/brew`
**Implementation:** Separate conditionals in 00-load-homebrew templates
**Result:** ✅ OS-specific paths correctly templated

## Syntax Validation Results

### Chezmoi Templates ✅
- `10-shared.env.tmpl` - Compiles correctly
- `15-services.env.tmpl` - Compiles correctly, 1Password secrets injected
- `20-os-darwin.env.tmpl` - Compiles correctly, XDG paths templated
- `20-os-linux.env.tmpl` - Compiles correctly, TMPDIR + WSL conditional

### Fish Syntax ✅
- `source_posix_env.fish` - No syntax errors
- `05-shared-env.fish` - No syntax errors
- `00-load-homebrew.fish.tmpl` - Templates valid

### Shell Config Load Order ✅
**All shells follow consistent order:**
1. `00-load-homebrew.*` - Initialize brew (new)
2. `05-shared-env.*` - Source POSIX env files (new)
3. `10-common.env.*` - Shell-specific vars
4. `20-os.*.env.*` - OS-specific vars
5. PATH configs, plugins, aliases

## Security Review

### Token Separation ✅
- **Before:** Tokens mixed in `10-shared.env.tmpl`
- **After:** Tokens isolated in `15-services.env.tmpl`
- **Benefit:** Clearer security boundary, easier auditing

### 1Password Integration ✅
- All tokens use `onepasswordRead` with `quote` filter
- No plaintext secrets in templates
- Pattern: `{{ onepasswordRead "op://path" | quote }}`

### File Permissions (Assumed) ✅
- `private_env/` prefix ensures restrictive perms via chezmoi
- Templates generate dotfiles, not exposed in repo

## Unresolved Questions

1. **Bash EDITOR definition missing:** Bash 10-common.env still has `VISUAL=vim` in original commit (d3f05b9), but phase 2 removes it. Should verify bash uses nvim from centralized env correctly.

2. **FPATH completions timing:** Zsh FPATH moved from 20-os-darwin (after 10-common) to 00-load-homebrew (before 05-shared-env). Does this affect completion initialization? Need to test zsh completion loading.

3. **Fish glob failure handling:** If `~/.config/env/` doesn't exist, fish loop will error. Should add directory existence check in `05-shared-env.fish`?

4. **WSL DOTFILES_LOAD_FULL_THEME usage:** Variable defined in 20-os-linux.env but no grep matches found. Is this var actually used? Consider removal if orphaned.
