# Phase 07: Testing and Validation (Manual)

## Status: pending

## Overview

**Note:** This phase is performed manually by the user after implementation phases 01-06 are complete.

Test the migration on fresh environments before merging to main.

## Testing Strategy

### 1. Local Dry Run (Current Machine)

```bash
cd ~/.local/share/chezmoi
chezmoi apply --dry-run --verbose
```

Check:
- No errors in template rendering
- Scripts would execute in correct order
- Brewfile syntax is valid

### 2. Brewfile Validation

```bash
# Check all packages exist in Homebrew
brew bundle check --file=home/Brewfile

# List what would be installed
brew bundle list --file=home/Brewfile
```

### 3. macOS Fresh VM Test

Using UTM or similar:
1. Create clean macOS VM
2. Run bootstrap: `curl -fsSL https://gist.githubusercontent.com/schmas/a604b0d433a836c5af8a877a3d0f37df/raw/bootstrap-chezmoi.sh | bash`
3. Sign in to 1Password: `op signin`
4. Run chezmoi: `sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply schmas --branch feat/nix-to-homebrew-migration`
4. Verify:
   - Homebrew installed
   - All brew packages installed
   - All casks installed
   - macOS defaults applied
   - Dock configured
   - Fish is default shell
   - Touch ID sudo works

### 4. Linux VM Test

Using UTM, VirtualBox, or WSL:
1. Fresh Ubuntu 22.04+ or Pop!_OS
2. Install only: curl, git
3. Run chezmoi init command
4. Verify:
   - Native packages installed
   - Homebrew Linux installed
   - Brewfile packages installed (minus casks)
   - Fish is default shell

### 5. WSL Test

1. Fresh WSL Ubuntu instance: `wsl --install -d Ubuntu`
2. Run chezmoi init command
3. Verify:
   - All Linux checks pass
   - WSL-specific setup ran (winhome symlink)
   - Git credential helper configured

## Validation Checklist

### macOS
- [ ] `brew --version` works
- [ ] `brew list` shows all expected packages
- [ ] `brew list --cask` shows all expected apps
- [ ] `defaults read com.apple.dock autohide` returns 1
- [ ] `defaults read NSGlobalDomain KeyRepeat` returns 2
- [ ] Dock has correct apps
- [ ] `echo $SHELL` shows fish path
- [ ] `sudo -v` prompts for Touch ID
- [ ] `mise --version` works
- [ ] `chezmoi status` shows no changes

### Linux/WSL
- [ ] `brew --version` works
- [ ] `brew list` shows CLI tools (no casks)
- [ ] `echo $SHELL` shows fish path
- [ ] `mise --version` works
- [ ] `chezmoi status` shows no changes

## Rollback Plan

If issues found:
1. Document the issue
2. Fix in the feature branch
3. Re-test

If migration fails completely:
1. Nix setup still exists in separate repo
2. Can fall back to `darwin-rebuild switch`

## Success Criteria

- [ ] macOS fresh install works end-to-end
- [ ] Linux fresh install works end-to-end
- [ ] WSL fresh install works end-to-end
- [ ] All validation checklist items pass
- [ ] No manual intervention required
