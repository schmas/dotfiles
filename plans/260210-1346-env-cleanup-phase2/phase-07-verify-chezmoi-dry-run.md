# Phase 7: Verify with chezmoi dry-run

## Context
- Parent: [plan.md](plan.md)
- Depends on: All previous phases (1-6)

## Overview
- **Priority**: Critical
- **Status**: pending
- **Description**: Run `chezmoi apply --dry-run --verbose` to verify no template errors or missing files.

## Implementation Steps

1. Run `chezmoi apply --dry-run --verbose` — check for errors
2. Run `chezmoi diff` — review all changes match expectations
3. Spot-check key files:
   - `chezmoi execute-template < home/dot_config/private_env/10-shared.env.tmpl`
   - `chezmoi execute-template < home/dot_config/private_env/15-services.env.tmpl`
4. If clean: `chezmoi apply` to apply changes
5. Open a new shell (fish/zsh/bash) and verify:
   - `echo $LANG` → `en_US.UTF-8`
   - `echo $EDITOR` → `nvim`
   - `echo $GITHUB_TOKEN` → (token value)
   - `echo $DOTFILES_BIN` → `/Users/schmas/bin`
   - `echo $GPG_TTY` → (tty path)

## Todo
- [ ] `chezmoi apply --dry-run --verbose` shows no errors
- [ ] `chezmoi diff` shows expected changes only
- [ ] Template execution produces valid output
- [ ] Apply and verify in live shell

## Success Criteria
- Zero chezmoi errors
- All centralized vars available in all shells
- No duplicate env var definitions
- Shell startup time not degraded
