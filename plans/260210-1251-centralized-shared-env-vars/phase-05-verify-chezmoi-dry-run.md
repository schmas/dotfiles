# Phase 5: Verify with Chezmoi Dry-Run

## Context

- Parent plan: [plan.md](plan.md)
- Depends on: Phase 1, 2, 3, 4 (all must be complete)

## Overview

- **Priority:** High (gate before apply)
- **Status:** complete
- **Description:** Validate all changes via chezmoi dry-run, grep for duplicate vars, test in live shell

## Implementation Steps

### 1. Chezmoi dry-run

```bash
chezmoi apply --dry-run --verbose
```

Verify:
- New files created under `~/.config/env/`
- Modified shell conf.d files show expected diffs
- No template errors

### 2. Template output check

```bash
chezmoi cat ~/.config/env/10-shared.env
chezmoi cat ~/.config/env/20-os-darwin.env
chezmoi cat ~/.config/env/20-os-linux.env
```

Verify: clean KEY=VALUE output, no template artifacts, tokens resolved.

### 3. Grep for duplicate definitions

```bash
# In chezmoi source dir, search for vars that should only be in ~/.config/env/ now
grep -r "MISE_GITHUB_TOKEN" home/dot_config/private_{fish,zsh,bash}/conf.d/
grep -r "HOMEBREW_GITHUB_API_TOKEN" home/dot_config/private_{fish,zsh,bash}/conf.d/
grep -r "GEMINI_API_KEY" home/dot_config/private_{fish,zsh,bash}/conf.d/
grep -r "GITHUB_TOKEN" home/dot_config/private_{fish,zsh,bash}/conf.d/
grep -r "XDG_CONFIG_HOME" home/dot_config/private_{fish,zsh,bash}/conf.d/
```

Expected: zero matches (all moved to `private_env/`).

### 4. Apply and test

```bash
chezmoi apply
```

Open new shell sessions (fish, zsh, bash) and verify:
```bash
echo $MISE_GITHUB_TOKEN
echo $XDG_CONFIG_HOME
echo $GEMINI_API_KEY
```

### 5. Test extensibility

```bash
echo "TEST_VAR=hello_world" > ~/.config/env/90-local.env
```

Open new shell — verify `echo $TEST_VAR` returns `hello_world` without modifying any loader.

## Todo

- [x] Run `chezmoi apply --dry-run --verbose` — no errors
- [x] Verify `chezmoi cat` output for all 3 env files
- [x] Grep confirms no duplicate var definitions in conf.d
- [x] Apply and test in fish, zsh, bash
- [x] Test extensibility with `90-local.env`
- [x] Clean up test file

## Success Criteria

- `chezmoi apply` completes without errors
- All shells load centralized vars correctly
- No duplicate definitions remain
- Drop-in `90-local.env` works without loader changes
- `~/.claude/.env` unchanged and functional
