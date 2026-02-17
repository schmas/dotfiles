# Phase 03: Remove Old Files + Chezmoi Cleanup

## Context Links
- Parent: [plan.md](./plan.md)
- Depends on: [Phase 02](./phase-02-create-loaders-and-parsers.md) verified working

## Overview
- **Priority:** Medium (after loaders confirmed working)
- **Status:** Complete
- **Description:** Delete the 9 old per-shell path config files from chezmoi source and clean up generated files in target directory.

## Key Insights
- Chezmoi tracks managed files. Deleting source files means `chezmoi apply` won't regenerate them, but **existing target files persist** until explicitly removed.
- Use `chezmoi forget` or `chezmoi destroy` to remove target files, OR add entries to `.chezmoiremove`.
- Safest approach: delete source files, then run `chezmoi apply` to verify, then manually remove stale target files.

## Requirements
- Remove 9 source template files from chezmoi repo
- Clean stale generated files from target directories
- No orphan configs left in `~/.config/{fish,zsh,bash}/conf.d/`

## Related Code Files

### Files to Delete (chezmoi source)
| File | Target Path |
|------|-------------|
| `home/dot_config/private_fish/conf.d/10-common.path.fish.tmpl` | `~/.config/fish/conf.d/10-common.path.fish` |
| `home/dot_config/private_fish/conf.d/20-os.darwin.path.fish.tmpl` | `~/.config/fish/conf.d/20-os.darwin.path.fish` |
| `home/dot_config/private_fish/conf.d/20-os.linux.path.fish.tmpl` | `~/.config/fish/conf.d/20-os.linux.path.fish` |
| `home/dot_config/private_zsh/conf.d/10-common.path.zsh.tmpl` | `~/.config/zsh/conf.d/10-common.path.zsh` |
| `home/dot_config/private_zsh/conf.d/20-os.darwin.path.zsh.tmpl` | `~/.config/zsh/conf.d/20-os.darwin.path.zsh` |
| `home/dot_config/private_zsh/conf.d/20-os.linux.path.zsh.tmpl` | `~/.config/zsh/conf.d/20-os.linux.path.zsh` |
| `home/dot_config/private_bash/conf.d/10-common.path.bash.tmpl` | `~/.config/bash/conf.d/10-common.path.bash` |
| `home/dot_config/private_bash/conf.d/20-os.darwin.path.bash.tmpl` | `~/.config/bash/conf.d/20-os.darwin.path.bash` |
| `home/dot_config/private_bash/conf.d/20-os.linux.path.bash.tmpl` | `~/.config/bash/conf.d/20-os.linux.path.bash` |

## Implementation Steps

### 1. Delete source files from chezmoi repo

```bash
cd ~/.local/share/chezmoi

# Fish
rm home/dot_config/private_fish/conf.d/10-common.path.fish.tmpl
rm home/dot_config/private_fish/conf.d/20-os.darwin.path.fish.tmpl
rm home/dot_config/private_fish/conf.d/20-os.linux.path.fish.tmpl

# Zsh
rm home/dot_config/private_zsh/conf.d/10-common.path.zsh.tmpl
rm home/dot_config/private_zsh/conf.d/20-os.darwin.path.zsh.tmpl
rm home/dot_config/private_zsh/conf.d/20-os.linux.path.zsh.tmpl

# Bash
rm home/dot_config/private_bash/conf.d/10-common.path.bash.tmpl
rm home/dot_config/private_bash/conf.d/20-os.darwin.path.bash.tmpl
rm home/dot_config/private_bash/conf.d/20-os.linux.path.bash.tmpl
```

### 2. Remove stale target files

```bash
# Remove old generated files from target dirs
rm -f ~/.config/fish/conf.d/10-common.path.fish
rm -f ~/.config/fish/conf.d/20-os.darwin.path.fish
rm -f ~/.config/fish/conf.d/20-os.linux.path.fish

rm -f ~/.config/zsh/conf.d/10-common.path.zsh
rm -f ~/.config/zsh/conf.d/20-os.darwin.path.zsh
rm -f ~/.config/zsh/conf.d/20-os.linux.path.zsh

rm -f ~/.config/bash/conf.d/10-common.path.bash
rm -f ~/.config/bash/conf.d/20-os.darwin.path.bash
rm -f ~/.config/bash/conf.d/20-os.linux.path.bash
```

### 3. Verify chezmoi state

```bash
chezmoi status          # Should show no orphan entries
chezmoi managed | grep path  # Only new path files should appear
chezmoi verify          # No errors
```

## Todo List
- [ ] Confirm Phase 02 loaders work correctly (prerequisite)
- [ ] Delete 9 source template files
- [ ] Remove 9 stale target files
- [ ] Run `chezmoi status` — verify clean state
- [ ] Run `chezmoi managed | grep path` — only new files listed

## Success Criteria
- No old `*path*` files in `~/.config/{fish,zsh,bash}/conf.d/`
- `chezmoi status` clean
- New `~/.config/path/*.path` files managed by chezmoi

## Risk Assessment
- **Stale files cause double PATH entries:** Mitigated by explicitly removing targets in step 2.
- **Accidental deletion:** All files are in git — easily recoverable.

## Security Considerations
- None — only deleting config files, no secrets involved.

## Next Steps
- Phase 04: Test PATH output across all shells
