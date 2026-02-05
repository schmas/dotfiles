# Plan: Migrate from Nix to Homebrew + Chezmoi

## Status: pending

## Overview

Consolidate system setup from two repos (nix-config + chezmoi) into single chezmoi repo. Replace Nix package management with Homebrew Brewfile. Convert nix-darwin macOS settings to shell scripts.

**Goal:** Two-step setup on any platform:
```bash
# 1. Bootstrap prerequisites (public gist)
curl -fsSL https://gist.githubusercontent.com/schmas/a604b0d433a836c5af8a877a3d0f37df/raw/bootstrap-chezmoi.sh | bash

# 2. Sign in to 1Password & apply dotfiles
op signin
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply schmas
```

## Phases

| Phase | Description                         | Status  | File                                                    |
| ----- | ----------------------------------- | ------- | ------------------------------------------------------- |
| 01    | Create feature branch               | pending | [phase-01](./phase-01-create-feature-branch.md)         |
| 02    | Add Brewfile with packages          | pending | [phase-02](./phase-02-add-brewfile-with-packages.md)    |
| 03    | Create macOS defaults script        | pending | [phase-03](./phase-03-create-macos-defaults-script.md)  |
| 04    | Create Linux/WSL setup script       | pending | [phase-04](./phase-04-create-linux-wsl-setup-script.md) |
| 05    | Add Homebrew + pre-chezmoi scripts  | pending | [phase-05](./phase-05-add-homebrew-bootstrap-script.md) |
| 06    | Documentation and cleanup           | pending | [phase-06](./phase-06-documentation-and-cleanup.md)     |
| 07    | Testing and validation (manual)     | pending | [phase-07](./phase-07-testing-and-validation.md)        |

## Migration Summary

| Source (nix-config)                        | Target (chezmoi)                                   |
| ------------------------------------------ | -------------------------------------------------- |
| `packages.nix` (~60 CLI tools)             | `home/Brewfile` brews section                      |
| `packages-darwin.nix` casks (~40 GUI apps) | `home/Brewfile` casks section                      |
| `settings.nix` (macOS defaults)            | `run_once_after_00-darwin-system-defaults.sh.tmpl` |
| `dock/default.nix` (Dock items)            | Part of macOS defaults script                      |
| Touch ID sudo                              | `run_once_after_00-darwin-touch-id-sudo.sh.tmpl`   |
| N/A (new)                                  | `run_once_after_00-linux-system-setup.sh.tmpl`     |

## Target File Structure

```
# Standalone pre-chezmoi bootstrap (run before `chezmoi init`)
bin/bootstrap-chezmoi.sh                        # NEW - Install prerequisites

home/
├── Brewfile                                    # All packages (brews + casks)
├── .chezmoiscripts/
│   ├── 00-run-before/
│   │   ├── run_before_00_configure_1password.sh           # Existing
│   │   ├── run_before_01-install-homebrew-on-macos.sh.tmpl    # NEW
│   │   └── run_before_02-install-packages-from-brewfile.sh.tmpl # NEW
│   └── 01-common/
│       ├── run_once_after_00-darwin-system-defaults.sh.tmpl   # NEW
│       ├── run_once_after_00-darwin-touch-id-sudo.sh.tmpl     # NEW
│       ├── run_once_after_00-linux-system-setup.sh.tmpl       # NEW
│       ├── run_once_after_01-mise-install.sh.tmpl             # Existing
│       └── ...
```

## Why This Approach

1. **Single repo** - One `chezmoi apply` does everything
2. **Brewfile is declarative** - Same benefits as Nix package list
3. **Faster setup** - No Nix builds, direct package downloads
4. **True cross-platform** - Works on macOS, Linux, and WSL
5. **Simpler maintenance** - One mental model, one toolchain

## Dependencies

- Homebrew (installed by bootstrap script)
- 1Password CLI (for secrets, already configured)
- dockutil (for Dock management, installed via Brewfile)
- mise (for dev runtimes, already in place)

## Success Criteria

- [ ] `chezmoi init --apply schmas` on fresh macOS installs all packages + configures system
- [ ] Same command on Linux/WSL installs appropriate packages
- [ ] macOS system preferences match current nix-darwin config
- [ ] Dock items configured correctly
- [ ] Fish shell set as default
- [ ] No manual intervention required
- [ ] nix-config repo archived with deprecation notice

## Reports

- [Brainstorm Summary](./reports/brainstorm-260205-1055-nix-to-homebrew-chezmoi-migration.md)
