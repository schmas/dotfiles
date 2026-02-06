# Brainstorm: macOS Format Backup Strategy

## Problem

Preparing for macOS format. Need to backup customized preferences (especially keyboard shortcuts) that aren't captured by existing chezmoi/backup infrastructure.

## Current Infrastructure

| Layer | File | Status |
|-------|------|--------|
| Chezmoi defaults | `run_once_after_00-darwin-system-defaults.sh.tmpl` (136 lines) | Active, ~50 settings |
| Standalone defaults | `bin/macos/executable_setup-macos-pref.sh` (958 lines) | Legacy Mathias Bynens fork |
| App plist backup | `bin/macos/executable_macos-backup-apps-config` | 9 app plists |

## Gaps Identified

1. **Keyboard shortcuts** - not backed up anywhere
2. **Defaults script divergence** - two scripts, different settings, no single source of truth
3. **No visibility into customizations** - can't see what's custom vs default

## Agreed Approach (3 Actions)

### Action 1: Dump Keyboard Shortcuts (PRIORITY - do now)
- Script to export customized shortcuts in readable format
- System shortcuts: filter `com.apple.symbolichotkeys` entries with `value` dicts
- App shortcuts: scan all domains for `NSUserKeyEquivalents`
- Decode modifier flags to human-readable (Cmd+Shift+X)
- Output to reviewable markdown

### Action 2: Consolidate Defaults Scripts (later)
- Merge chezmoi + standalone into one canonical script in `bin/macos/`
- Chezmoi script calls the consolidated one
- Remove obsolete entries (Dashboard, SizeUp, Tweetbot, Twitter, etc.)

### Action 3: Keyboard Shortcuts Backup/Restore (later)
- `defaults export/import com.apple.symbolichotkeys`
- Store in chezmoi repo or `~/Documents/00_Backups/apps/`
- Add restore to chezmoi post-apply script

## Limitations

- "Only non-default" detection ~90% accurate via `value` dict heuristic
- Some macOS version-specific shortcut IDs may vary
- `defaults import` restore is reliable but requires logout/restart

## Decision

User chose: **Dump shortcuts now** - create readable export of customized keyboard shortcuts before format.
