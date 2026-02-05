# Phase 07: Documentation and Cleanup

## Status: pending

## Overview

Update documentation to reflect new setup process and archive the nix-config repo.

## Documentation Updates

### 1. Update chezmoi README.md

Add/update sections:
- Fresh machine setup instructions
- Brewfile management (adding/removing packages)
- macOS defaults customization
- Linux/WSL setup notes

### 2. Update CLAUDE.md

Reflect new package management approach:
- Remove Nix references
- Add Brewfile editing instructions
- Update common commands

### 3. Update deployment-guide.md

New quick start:
```bash
# macOS / Linux / WSL
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply schmas
```

## nix-config Repository

### Option A: Archive (Recommended)
1. Add deprecation notice to README
2. Archive repo on GitHub (Settings → Archive)
3. Keep for reference but prevent changes

### Option B: Delete
Only if you're certain you won't need to reference it.

### Deprecation Notice

Add to `~/.config/nix-config/README.md`:

```markdown
# ⚠️ DEPRECATED

This repository is deprecated. System configuration has been consolidated into the chezmoi dotfiles repository.

**New setup:** https://github.com/schmas/dotfiles

## Why?
- Simplified to single repository
- Faster setup (Homebrew vs Nix builds)
- Better cross-platform support (macOS/Linux/WSL)

## Migration Date
February 2026
```

## Cleanup Tasks

### In chezmoi repo
- [ ] Remove any Nix-related files if present
- [ ] Update .gitignore if needed
- [ ] Commit all changes to feature branch
- [ ] Create PR for review

### On local machine (after merge)
- [ ] Uninstall Nix (optional, can keep for other projects)
- [ ] Remove nix-config from rebuild aliases
- [ ] Update shell aliases if any reference Nix

### Uninstall Nix (if desired)

```bash
# Determinate Systems Nix uninstaller
/nix/nix-installer uninstall

# Or manual cleanup
sudo rm -rf /nix
sudo rm -rf /etc/nix
sudo rm -rf ~/.nix-*
# Remove Nix lines from /etc/zshrc, /etc/bashrc, /etc/bash.bashrc
```

## PR Checklist

Before merging `feat/nix-to-homebrew-migration`:

- [ ] All phases completed
- [ ] Testing passed on fresh environments
- [ ] Documentation updated
- [ ] No sensitive data in commits
- [ ] Commit history is clean

## Post-Merge

1. Merge PR to main
2. Test: `chezmoi update` on current machine
3. Archive nix-config repo
4. Celebrate simplified setup 🎉

## Success Criteria

- [ ] README updated with new setup instructions
- [ ] CLAUDE.md reflects new approach
- [ ] nix-config repo has deprecation notice
- [ ] PR created and ready for review
- [ ] All documentation accurate and complete
