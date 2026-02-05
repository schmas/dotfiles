# Brainstorm: Nix to Homebrew + Chezmoi Migration

## Problem Statement

User formats MacBook 1-2x/year and wants:
- Quick fresh machine setup with minimal manual steps
- Easy maintenance over time
- Cross-platform support (macOS primary, Linux/WSL secondary)

**Current state:** Two repos (nix-config + chezmoi dotfiles) with overlapping responsibilities.

## Requirements Gathered

| Requirement | Priority |
|-------------|----------|
| Quick setup on format | High |
| Easy maintenance | High |
| Cross-platform (macOS/Linux/WSL) | High |
| Declarative package list | High |
| macOS system automation (Dock, defaults) | Medium |
| Reproducibility/rollback | Low |

## Approaches Evaluated

### Option A: Pure Homebrew + Chezmoi (CHOSEN)
**Simplify to single repo with Brewfile**

Pros:
- Single source of truth (chezmoi)
- `Brewfile` is declarative - retains package list
- Faster installs (no Nix builds)
- Native Linux support via chezmoi scripts
- WSL works identically to native Linux

Cons:
- No atomic rollback
- Package versions drift (minimal concern for personal use)

### Option B: Keep Current Split
Nix for macOS, chezmoi scripts for Linux/WSL.

Rejected: Adds complexity, two different mental models.

### Option C: Home Manager Only
Drop nix-darwin, use Home Manager everywhere.

Rejected: Still has Nix build times, complexity remains.

## Final Recommendation

**Consolidate everything into chezmoi repo.**

### Migration Scope

| Source (Nix) | Target (Chezmoi) |
|--------------|------------------|
| `packages.nix` (~60 CLI) | `Brewfile` brews |
| `packages-darwin.nix` casks (~40 GUI) | `Brewfile` casks |
| `settings.nix` (macOS defaults) | `run_once_darwin-defaults.sh.tmpl` |
| `dock/default.nix` | `dockutil` in defaults script |

### Repo Organization Decision

**Combined (chezmoi)** over separate repos:
- Single `chezmoi apply` installs everything
- Profile system already supports different setups
- `run_onchange_` triggers on Brewfile changes

## Implementation Considerations

1. Branch work for review before merging to main
2. Place scripts in `home/.chezmoiscripts/` (per .chezmoiroot)
3. Use OS detection templates for cross-platform
4. Install Homebrew on Linux for CLI tool consistency
5. Keep `mise` for dev runtimes (already in place)

## Success Criteria

- [ ] Fresh macOS: `chezmoi init --apply` installs all packages + configures system
- [ ] Fresh Linux/WSL: Same command installs appropriate packages
- [ ] Brewfile contains all previously Nix-managed packages
- [ ] macOS defaults script replicates nix-darwin settings
- [ ] No manual steps required post-apply

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Homebrew package name differences | Document mappings during migration |
| Linux package availability | Use Homebrew on Linux + mise for dev tools |
| macOS defaults not persisting | Test on fresh VM/partition before full migration |

## Next Steps

Create detailed implementation plan with phases:
1. Create feature branch
2. Add Brewfile with all packages
3. Create macOS defaults script
4. Create Linux/WSL setup script
5. Add package install scripts
6. Test on fresh environment
7. Archive/deprecate nix-config repo
