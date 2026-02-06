# macOS Keyboard Shortcuts Storage & Export Research Report

**Date:** 2026-02-06 | **System:** macOS Sequoia/Sonoma | **Status:** Complete

## Executive Summary

macOS stores keyboard shortcuts in **plist files** under `~/Library/Preferences/`. The primary file is `com.apple.symbolichotkeys.plist` containing system-wide shortcut bindings identified by numeric IDs. Shortcuts are fully exportable via `defaults export` command and portable across machines. Detecting custom (non-default) shortcuts requires comparison against a baseline since macOS doesn't expose public defaults.

## 1. Storage Locations & File Structure

### Primary Files

| File | Domain | Purpose | Contents |
|------|--------|---------|----------|
| `com.apple.symbolichotkeys.plist` | `com.apple.symbolichotkeys` | **System keyboard shortcuts** | Numeric ID keys (36, 37, 163, 164, etc.) with enabled/disabled state + custom key bindings |
| `com.apple.HIToolbox.plist` | `com.apple.HIToolbox` | Input sources & layout | Current keyboard layout, enabled input methods, IME settings |

### Directory Structure

```
~/Library/Preferences/
├── com.apple.symbolichotkeys.plist          # Main shortcuts (binary plist)
├── com.apple.HIToolbox.plist                # Input sources (binary plist)
└── {app-bundle-id}.plist                    # App-specific NSUserKeyEquivalents
```

### Plist Structure Example

```xml
<!-- com.apple.symbolichotkeys.plist structure -->
<dict>
  <key>AppleSymbolicHotKeys</key>
  <dict>
    <key>163</key>  <!-- Spotlight search -->
    <dict>
      <key>enabled</key>
      <true/>
      <key>value</key>
      <dict>
        <key>parameters</key>
        <array>
          <integer>65535</integer>    <!-- keycode (65535 = use char) -->
          <integer>103</integer>       <!-- keychar (g) -->
          <integer>8388608</integer>   <!-- modifiers (Cmd) -->
        </array>
        <key>type</key>
        <string>standard</string>
      </dict>
    </dict>
  </dict>
</dict>
```

## 2. Keyboard Shortcut Parameter Format

Each shortcut contains: **[keycode, keychar, modifiers]**

### Keycode & Keychar

- **65535 (0xFFFF):** Special marker meaning "use keychar instead of keycode"
- **Keychar:** ASCII value of pressed key (99=c, 103=g, 109=m, 115=s, 120=x, 122=z, etc.)
- **Regular keycodes:** Used for function keys, arrows, etc. (less common in modern macOS)

### Modifier Flags (Bitwise Flags)

| Value | Modifier | Hex | Shift By |
|-------|----------|-----|----------|
| 131072 | Shift | 0x20000 | 1 << 17 |
| 262144 | Control | 0x40000 | 1 << 18 |
| 524288 | Option/Alt | 0x80000 | 1 << 19 |
| 1048576 | Command | 0x100000 | 1 << 20 |
| **8388608** | **Command (Alt)** | **0x800000** | **1 << 23** |

**Combinations (bitwise OR):**
- 8388608 = Command
- 8519680 = Command + Shift (8388608 | 131072)
- 8781056 = Command + Option (8388608 | 524288)
- 8912128 = Command + Option + Shift

### Real Examples from Current System

| ID | Name | Enabled | Parameters | Decoded |
|----|----|---------|-----------|---------|
| 36 | Window minimize | ✓ | [65535, 109, 8388608] | **Cmd+M** |
| 37 | Cycle windows | ✓ | [65535, 109, 8519680] | **Cmd+Shift+M** |
| 163 | Spotlight search | ✓ | [65535, 103, 8388608] | **Cmd+G** |
| 164 | Dashboard | ✗ | [65535, 65535, 0] | (Disabled, default F12) |
| 176 | Keyboard nav | ✗ | (empty) | (Disabled) |

## 3. Symbolic Hotkey IDs (Known on Sequoia/Sonoma)

### System Hotkeys Registry

| ID Range | Category | Default State | Notes |
|----------|----------|----------------|-------|
| 15-26 | Accessibility/Universal Access | Disabled | Accessibility features, zoom, etc. |
| 36-37 | Window management | Enabled | Minimize, cycle windows (Cmd+M, Cmd+Opt+M) |
| 60-65 | Dashboard/Spaces | Disabled | Deprecated features, mostly disabled |
| 79-82 | Mission Control | Enabled | Mission Control, show desktop, App Exposé |
| 163 | Spotlight search | Enabled | Global search (Cmd+Space by default) |
| 164 | Dashboard toggle | Disabled | Toggle dashboard (F12 by default) |
| 176 | Keyboard navigation | Context | Full keyboard access for dialogs |

**Full ID listing:** IDs from 15-176 exist; not all have values. IDs can vary by macOS version.

## 4. Detecting Custom (Non-Default) Shortcuts

### Challenge
macOS **does not ship** public default keyboard shortcut mappings. System defaults are hardcoded in frameworks.

### Solution Approaches

#### A. Enabled-based Detection (Simple but Unreliable)
```bash
# Show only enabled shortcuts (most likely custom or key system settings)
defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys | \
  grep -B1 "enabled = 1"
```
**Limitation:** Some enabled shortcuts are system defaults (36, 37, 79-82, 163)

#### B. Value-based Detection (More Accurate)
```bash
# Show only entries with custom parameter values
defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys | \
  grep -A5 "value = " | grep -E "(parameters|type)"
```
**Logic:** Any ID with a `value` dict means user customized it (system defaults have no value)

#### C. Comparison Against Baseline (Most Reliable)
1. Create snapshot on clean macOS install (baseline)
2. Export current user's shortcuts
3. Diff against baseline
4. Remaining IDs = custom user shortcuts

```bash
# Export baseline on fresh install
defaults export com.apple.symbolichotkeys ~/baseline-sequoia.plist

# Later, compare current against baseline
diff <(defaults read -d ~/baseline-sequoia.plist com.apple.symbolichotkeys) \
     <(defaults read com.apple.symbolichotkeys)
```

#### D. Metadata-based (Partial Solution)
```bash
# Check plist modification time
mdls -name kMDItemContentModificationDate ~/Library/Preferences/com.apple.symbolichotkeys.plist
```
**Limitation:** Only shows if plist was modified, not which shortcuts changed.

## 5. App-Specific Keyboard Shortcuts

### NSUserKeyEquivalents Pattern

App-specific custom shortcuts stored in app preference files:

```bash
# Check if app has custom shortcuts
defaults read com.apple.Safari NSUserKeyEquivalents

# Common app domains where NSUserKeyEquivalents appears
- com.apple.Safari
- com.apple.finder
- com.apple.TextEdit
- {third-party app bundle IDs}
```

**Tested Results on Current System:**
- ✗ No NSUserKeyEquivalents found in standard apps (clean defaults)
- Only created when user customizes app menu shortcuts
- Stored as dictionary: `{ "Menu Item Title" = "Key Equivalent"; }`

### Containerized App Shortcuts

Sandboxed apps store preferences in container paths:

```bash
~/Library/Containers/{BundleID}/Data/Library/Preferences/
```

Example: Safari in container
```bash
~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari.plist
```

## 6. Export & Backup Methods

### A. defaults export (BEST - Tested & Working)

**Command:**
```bash
defaults export com.apple.symbolichotkeys ~/backup-shortcuts.plist
defaults export com.apple.HIToolbox ~/backup-hitools.plist
```

**Advantages:**
- ✓ Creates portable binary plist
- ✓ Can be imported on other Macs: `defaults import com.apple.symbolichotkeys ~/backup-shortcuts.plist`
- ✓ Handles format conversion automatically
- ✓ Tested working on current system

**Limitations:**
- Creates binary plist (not human-readable)
- Imports ALL shortcuts (no filtering)

### B. plutil Conversion

**Command:**
```bash
# Export to binary
cp ~/Library/Preferences/com.apple.symbolichotkeys.plist ~/backup.plist

# Convert to XML (human-readable)
plutil -convert xml1 ~/backup.plist

# Convert back to binary
plutil -convert binary1 ~/backup.plist
```

**Advantages:**
- ✓ Human-readable intermediate XML format
- ✓ Can edit manually before importing
- ✓ Easy to filter/merge

**Limitations:**
- Requires explicit format conversion
- Need to convert back before importing

### C. defaults read (Text Export)

**Command:**
```bash
defaults read com.apple.symbolichotkeys > ~/shortcuts-dump.txt
defaults read com.apple.symbolichotkeys | plutil -convert json - > ~/shortcuts.json
```

**Advantages:**
- ✓ Human-readable
- ✓ Easy to review/compare

**Limitations:**
- ✗ Cannot be directly imported back
- Requires parsing/conversion
- Not ideal for automation

### D. Binary Plist Direct Copy

**Command:**
```bash
cp ~/Library/Preferences/com.apple.symbolichotkeys.plist ~/backup.plist
# Can be restored by copying back, or imported via defaults
```

**Note:** Binary plist can be imported via defaults on destination Mac.

## 7. Concrete Commands & Examples

### Export Current Shortcuts

```bash
# Export as portable plist (binary)
defaults export com.apple.symbolichotkeys ~/.config/macos-shortcuts/symbolic-hotkeys.plist

# Also backup input sources
defaults export com.apple.HIToolbox ~/.config/macos-shortcuts/hitools.plist

# Or combine with timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
defaults export com.apple.symbolichotkeys \
  ~/.config/macos-shortcuts/symbolic-hotkeys-${TIMESTAMP}.plist
```

### Import Shortcuts on Destination

```bash
# Import from backup
defaults import com.apple.symbolichotkeys \
  ~/.config/macos-shortcuts/symbolic-hotkeys.plist

defaults import com.apple.HIToolbox \
  ~/.config/macos-shortcuts/hitools.plist

# Restart affected applications or log out/in for changes to take effect
killall Finder
killall Dock
```

### Detect Custom Shortcuts Only

```bash
#!/bin/bash
# Export all enabled shortcuts with values

echo "=== Custom Keyboard Shortcuts ==="
defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys | \
  awk '
    /^    [0-9]+ = \{/ { id=$1; getline; }
    /enabled = 1/ { has_enabled=1; }
    /value = \{/ { has_value=1; }
    /\};$/ { 
      if (has_enabled && has_value) {
        print "ID " id ": Custom (enabled with value)"
      } else if (has_enabled) {
        print "ID " id ": System default (enabled, no value)"
      }
      has_enabled=0; has_value=0;
    }
  '
```

### Compare Shortcuts Across Macs

```bash
# On machine A (source)
defaults export com.apple.symbolichotkeys ~/a-shortcuts.plist

# Copy to machine B via USB/network
# On machine B (destination)
diff <(plutil -p ~/a-shortcuts.plist) <(plutil -p ~/Library/Preferences/com.apple.symbolichotkeys.plist)

# Or more detailed:
diff <(defaults export com.apple.symbolichotkeys /dev/stdin | plutil -p -) \
     <(plutil -p ~/Library/Preferences/com.apple.symbolichotkeys.plist)
```

## 8. Known Limitations & Caveats

| Limitation | Impact | Workaround |
|-----------|--------|-----------|
| **No public API** | Cannot query defaults programmatically | Use `defaults read` command-line tool |
| **Version-specific IDs** | Shortcut IDs vary by macOS (Sequoia ≠ Sonoma ≠ Ventura) | Maintain separate baseline files per macOS version |
| **Hidden defaults** | Prefs only created when user customizes | Check for file existence before exporting |
| **Containerized apps** | Sandboxed app shortcuts in container paths, not main plist | Search `~/Library/Containers/*/Data/Library/Preferences/` |
| **Third-party tools** | Karabiner, Alfred, etc. have own config | Export from their own preference domains separately |
| **Input method shortcuts** | IME/keyboard input shortcuts stored separately in HIToolbox or app-specific | HIToolbox handles layout, not custom shortcuts |
| **Requires restart** | Changes may not apply until app restart or logout/login | Document need for user action after import |

## 9. Plist Files to Monitor

### For Keyboard Shortcuts Backup in chezmoi

```
Priority 1 (Must backup):
  ~/Library/Preferences/com.apple.symbolichotkeys.plist

Priority 2 (Optional - input sources):
  ~/Library/Preferences/com.apple.HIToolbox.plist

Priority 3 (App-specific - if user customized):
  ~/Library/Preferences/com.apple.Safari.plist (if NSUserKeyEquivalents exists)
  ~/Library/Preferences/com.apple.finder.plist (if NSUserKeyEquivalents exists)
  ~/Library/Containers/{app-bundle-id}/Data/Library/Preferences/*.plist (containerized apps)
```

## 10. Recommended Implementation Strategy for chezmoi

### Phase 1: Capture & Store

```bash
# In chezmoi script or bin/
#!/bin/bash
BACKUP_DIR="$HOME/.config/macos-keyboard-shortcuts"
mkdir -p "$BACKUP_DIR"

# Export with timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
defaults export com.apple.symbolichotkeys \
  "$BACKUP_DIR/symbolic-hotkeys-${TIMESTAMP}.plist"
defaults export com.apple.HIToolbox \
  "$BACKUP_DIR/hitools-${TIMESTAMP}.plist"

echo "Keyboard shortcuts backed up to $BACKUP_DIR"
```

### Phase 2: Store in chezmoi

```
home/
├── dot_config/
│   └── macos-keyboard-shortcuts/
│       ├── symbolic-hotkeys.plist        # Latest export (binary)
│       └── hitools.plist                 # Input sources
```

### Phase 3: Restore on New Machine

```bash
# In .chezmoiscripts/run_once_macos-keyboard-shortcuts.sh
#!/bin/bash
if [[ "$OSTYPE" == "darwin"* ]]; then
  defaults import com.apple.symbolichotkeys \
    ~/.config/macos-keyboard-shortcuts/symbolic-hotkeys.plist
  defaults import com.apple.HIToolbox \
    ~/.config/macos-keyboard-shortcuts/hitools.plist
  
  # Notify user to restart apps
  echo "Keyboard shortcuts imported. Restart applications for changes to take effect."
fi
```

### Phase 4: Filter Custom Shortcuts Only (Optional)

If you want to backup ONLY custom shortcuts:

```python
#!/usr/bin/env python3
import subprocess
import plistlib

# Load baseline (from clean install snapshot)
with open('baseline-sequoia.plist', 'rb') as f:
    baseline = plistlib.load(f)

# Load current user shortcuts
result = subprocess.run(['defaults', 'export', 'com.apple.symbolichotkeys', '/dev/stdin'],
                       capture_output=True)
current = plistlib.loads(result.stdout)

# Find differences
custom_keys = set(current.keys()) - set(baseline.keys())
for key in custom_keys:
    if current[key] != baseline.get(key):
        print(f"Custom shortcut ID {key}: {current[key]}")
```

## Files Referenced in Research

- `~/Library/Preferences/com.apple.symbolichotkeys.plist`
- `~/Library/Preferences/com.apple.HIToolbox.plist`
- `/System/Library/Frameworks/Carbon.framework/...` (hardcoded defaults - not accessible)

## Testing Summary

| Test | Result | Command |
|------|--------|---------|
| Read symbolic hotkeys | ✓ Pass | `defaults read com.apple.symbolichotkeys` |
| Read HIToolbox | ✓ Pass | `defaults read com.apple.HIToolbox` |
| Export plist | ✓ Pass | `defaults export com.apple.symbolichotkeys test.plist` |
| Parse with plutil | ✓ Pass | `plutil -p ~/Library/Preferences/com.apple.symbolichotkeys.plist` |
| Check app shortcuts | ✓ Pass (No custom found) | `defaults read com.apple.Safari NSUserKeyEquivalents` |

## Unresolved Questions

1. **Exact macOS version mapping:** Which specific shortcut IDs are added/removed in each macOS version (Ventura → Sonoma → Sequoia)?
   - *Impact:* Affects baseline comparison approach
   - *Resolution needed:* Snapshot fresh installs of each version

2. **Programmatic defaults query:** Can `OSSystemPreferences` framework expose defaults without `defaults` CLI?
   - *Impact:* Could enable native app-based export
   - *Resolution needed:* Investigate Swift/Objective-C APIs

3. **Karabiner-Elements integration:** Does Karabiner override symbolichotkeys or run parallel?
   - *Impact:* May need separate backup of Karabiner config
   - *Current state:* Karabiner has own plist config (separate)

4. **App sandboxing & NSUserKeyEquivalents:** Why aren't app-specific shortcuts found on clean install?
   - *Impact:* Unclear if all apps support NSUserKeyEquivalents or if only visible when customized
   - *Likely answer:* Only created when user customizes (dynamic creation)
