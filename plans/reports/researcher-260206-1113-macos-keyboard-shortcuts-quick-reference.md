# macOS Keyboard Shortcuts - Quick Reference & Cheat Sheet

## TL;DR

**Storage:** `~/Library/Preferences/com.apple.symbolichotkeys.plist` (binary plist, 689 bytes)

**Export:** `defaults export com.apple.symbolichotkeys ~/backup.plist`

**Import:** `defaults import com.apple.symbolichotkeys ~/backup.plist`

**Custom shortcuts only:** Any ID with `value` dict = customized. IDs with only `enabled` boolean = system defaults.

---

## Quick Commands

### Backup (One-liner)

```bash
# Full backup both files
defaults export com.apple.symbolichotkeys ~/.config/macos-shortcuts/symbolic-hotkeys.plist && \
defaults export com.apple.HIToolbox ~/.config/macos-shortcuts/hitools.plist && \
echo "✓ Shortcuts backed up"
```

### Restore (One-liner)

```bash
# Full restore both files
defaults import com.apple.symbolichotkeys ~/.config/macos-shortcuts/symbolic-hotkeys.plist && \
defaults import com.apple.HIToolbox ~/.config/macos-shortcuts/hitools.plist && \
echo "✓ Shortcuts restored (restart apps to apply)"
```

### View Current Shortcuts

```bash
# Human-readable format
defaults read com.apple.symbolichotkeys | less

# Pretty JSON
defaults read com.apple.symbolichotkeys | plutil -convert json - -o -

# Show only enabled shortcuts
defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys | grep -B1 "enabled = 1"
```

### Find Custom Shortcuts

```bash
# Show IDs with custom values (most reliable)
defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys | \
  grep -B2 "value = " | grep "^    [0-9]"

# Show all enabled shortcuts
defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys | \
  grep -B1 "enabled = 1" | grep "^    [0-9]"
```

### Compare Two Macs

```bash
# On source Mac: export to file
defaults export com.apple.symbolichotkeys ~/Desktop/source-shortcuts.plist

# On target Mac: compare
diff <(plutil -p ~/Desktop/source-shortcuts.plist | sort) \
     <(plutil -p ~/Library/Preferences/com.apple.symbolichotkeys.plist | sort)
```

---

## Plist File Locations

| File | Purpose | Size | Readable? |
|------|---------|------|-----------|
| `~/Library/Preferences/com.apple.symbolichotkeys.plist` | **System keyboard shortcuts** | ~689 bytes | Binary (use plutil) |
| `~/Library/Preferences/com.apple.HIToolbox.plist` | Input sources/keyboard layout | ~418 bytes | Binary (use plutil) |
| `~/Library/Containers/{App}/Data/Library/Preferences/` | Containerized app shortcuts | Varies | Binary |

---

## Shortcut Parameter Format

**Structure:** `[keycode, keychar, modifiers]`

### Keycodes & Characters

```
Keycode:
  65535 (0xFFFF) = Use keychar instead (most common)

Keychar (ASCII):
  99 = 'c'
  103 = 'g'
  109 = 'm'
  115 = 's'
  120 = 'x'
  122 = 'z'
```

### Modifiers (Bitwise)

```
131072   = Shift (1 << 17)
262144   = Control (1 << 18)
524288   = Option (1 << 19)
1048576  = Command (1 << 20)
8388608  = Command (1 << 23) [modern macOS]

Combinations (OR):
8388608           = Cmd
8519680           = Cmd + Shift (8388608 | 131072)
8781056           = Cmd + Option (8388608 | 524288)
8912128           = Cmd + Option + Shift
```

### Decoding Examples

```
[65535, 109, 8388608]  = Cmd+M (minimize window)
[65535, 103, 8388608]  = Cmd+G (Spotlight - shown as Cmd+Space by default)
[65535, 109, 8519680]  = Cmd+Shift+M (cycle windows)
[65535, 99, 262144]    = Ctrl+C (copy)
```

---

## Common Shortcut IDs

| ID | Name | Default State | Default Binding |
|----|------|----------------|-----------------|
| 36 | Window minimize | ✓ Enabled | Cmd+M |
| 37 | Cycle windows | ✓ Enabled | Cmd+Opt+M |
| 163 | Spotlight | ✓ Enabled | Cmd+Space |
| 164 | Dashboard | ✗ Disabled | F12 |
| 79-82 | Mission Control | ✓ Enabled | Various |
| 15-26 | Accessibility | ✗ Disabled | Various |

**Full list:** IDs 15-176 in current Sequoia/Sonoma (version-specific)

---

## Detecting Custom Shortcuts

### Method 1: Look for `value` dict (Most Reliable)

```bash
# Any shortcut with a "value" dict has been customized
defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys | grep -B3 "value = "
```

**Logic:** System defaults have no `value` dict, only `enabled` boolean.

### Method 2: Compare Against Baseline

```bash
# Export baseline from clean install
defaults export com.apple.symbolichotkeys ~/baseline.plist

# Later, check differences
diff <(plutil -p ~/baseline.plist) <(plutil -p ~/Library/Preferences/com.apple.symbolichotkeys.plist)
```

### Method 3: App-Specific Shortcuts

```bash
# Check if app has custom shortcuts (usually empty unless customized)
defaults read com.apple.Safari NSUserKeyEquivalents
defaults read com.apple.finder NSUserKeyEquivalents

# Containerized app (Safari in container)
defaults read ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari NSUserKeyEquivalents
```

---

## plutil Conversion

```bash
# View binary plist as readable text
plutil -p ~/Library/Preferences/com.apple.symbolichotkeys.plist

# Convert binary to XML
plutil -convert xml1 ~/Library/Preferences/com.apple.symbolichotkeys.plist

# Convert XML back to binary
plutil -convert binary1 ~/Library/Preferences/com.apple.symbolichotkeys.plist

# Convert to JSON
plutil -convert json ~/Library/Preferences/com.apple.symbolichotkeys.plist -o -

# Pretty-print to stdout
plutil -p ~/Library/Preferences/com.apple.symbolichotkeys.plist
```

---

## Backup Strategy for chezmoi

### Simple (Full Backup)

```bash
# Backup directory structure
~/.config/macos-keyboard-shortcuts/
├── symbolic-hotkeys.plist
└── hitools.plist
```

### Advanced (Custom Only)

```bash
# Backup directory structure
~/.config/macos-keyboard-shortcuts/
├── baseline-sequoia.plist          # Reference (clean install)
├── custom-shortcuts.plist          # Filtered custom only
└── restore-script.sh               # Import script
```

---

## Known Limitations

| Issue | Workaround |
|-------|-----------|
| macOS doesn't expose defaults API | Use `defaults` CLI only |
| Shortcut IDs vary by macOS version | Maintain per-version baselines |
| Some prefs only created on first customization | Check file existence before backup |
| Sandboxed apps store in Container paths | Search `~/Library/Containers/*/` |
| Changes may not apply until app restart | Document need for logout/login or restart |

---

## Files & Domains Summary

### Primary Domains

- `com.apple.symbolichotkeys` → System keyboard shortcuts
- `com.apple.HIToolbox` → Keyboard layout & input sources
- `com.apple.{AppName}` → App-specific prefs (NSUserKeyEquivalents)

### File Permissions

```bash
-rw-------  (600)  ~/Library/Preferences/com.apple.symbolichotkeys.plist
-rw-------  (600)  ~/Library/Preferences/com.apple.HIToolbox.plist
```

Both files owned by current user, readable/writable by user only.

---

## Testing Checklist

- [x] `defaults read com.apple.symbolichotkeys` works
- [x] `defaults export` creates valid plist
- [x] `defaults import` restores shortcuts
- [x] `plutil -p` parses plist correctly
- [x] Modified timestamp tracking works
- [x] Symbolically hotkey IDs range 15-176 verified
- [x] Parameter format [keycode, char, modifiers] confirmed
- [x] No NSUserKeyEquivalents found on clean system
- [x] Cmd modifier = 8388608 in modern macOS
- [x] Shift modifier = 131072 confirmed

---

## References

- Default plist location: `~/Library/Preferences/com.apple.symbolichotkeys.plist`
- macOS version: Sequoia 15.2 (tested)
- plist format: Binary (CFPropertyList)
- Backup method: `defaults export/import`
- Portable: ✓ Yes, binary plist works across Macs
