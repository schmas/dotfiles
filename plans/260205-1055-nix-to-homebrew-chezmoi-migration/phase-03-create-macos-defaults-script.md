# Phase 03: Create macOS Defaults Script

## Status: pending

## Overview

Convert nix-darwin `settings.nix` to a chezmoi script that applies macOS system preferences via `defaults write` commands.

## Source Analysis

From `~/.config/nix-config/hosts/common/darwin/settings.nix`:

### NSGlobalDomain (System-wide)
- Dark mode enabled
- Scroll bars always visible
- Disable animations
- Expand save/print panels by default
- Disable auto-correct features
- Fast key repeat (2) and initial delay (15)
- Function keys as standard

### Dock
- Autohide enabled
- No recent apps
- No launch animation
- Fast expose animation (0.1)
- Scale minimize effect
- Show hidden apps translucent
- Tile size 64
- No MRU spaces reordering

### Finder
- Show all extensions
- Show POSIX path in title
- No extension change warning
- Quit menu enabled
- List view default
- Show path/status bar
- Auto-remove trash after 30 days
- Search current folder
- Folders on top

### Trackpad
- Tap to click
- Right-click enabled

### Activity Monitor
- Open main window
- CPU icon
- Show all processes
- Sort by CPU

### Touch ID for sudo
- Enabled via PAM

### Dock Entries (via dockutil)
- System Settings, Launchpad, Reminders
- Ghostty
- Downloads folder

## Target File

Create `home/.chezmoiscripts/01-common/run_once_after_00-darwin-system-defaults.sh.tmpl`:

```bash
#!/usr/bin/env bash
{{ if ne .chezmoi.os "darwin" }}
# Skip on non-macOS systems
exit 0
{{ end }}

set -e

echo "Applying macOS system defaults..."

# =============================================================================
# NSGlobalDomain - System-wide preferences
# =============================================================================

# Appearance
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool false
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Animations
defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Save/Print dialogs
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Text correction (disable all)
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Keyboard
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

# =============================================================================
# Dock
# =============================================================================

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock minimize-to-application -bool false
defaults write com.apple.dock mouse-over-hilite-stack -bool true
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock showhidden -bool true
defaults write com.apple.dock tilesize -int 64

# =============================================================================
# Finder
# =============================================================================

defaults write com.apple.finder AppleShowAllExtensions -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder QuitMenuItem -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXRemoveOldTrashItems -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool true
defaults write com.apple.finder NewWindowTarget -string "PfHm"

# =============================================================================
# Trackpad
# =============================================================================

defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# =============================================================================
# Activity Monitor
# =============================================================================

defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
defaults write com.apple.ActivityMonitor IconType -int 5
defaults write com.apple.ActivityMonitor ShowCategory -int 100
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

# =============================================================================
# Chrome
# =============================================================================

defaults write com.google.Chrome AppleLanguages -array "en-US"

# =============================================================================
# Dock Items (requires dockutil)
# =============================================================================

if command -v dockutil &> /dev/null; then
  echo "Configuring Dock items..."

  # Remove all items first
  dockutil --no-restart --remove all

  # Add apps
  dockutil --no-restart --add "/System/Applications/System Settings.app"
  dockutil --no-restart --add "/System/Applications/Launchpad.app"
  dockutil --no-restart --add "/System/Applications/Reminders.app"
  dockutil --no-restart --add "/Applications/Ghostty.app"

  # Add Downloads folder
  dockutil --no-restart --add "$HOME/Downloads" --section others --view list --display folder --sort dateadded
fi

# =============================================================================
# Apply changes
# =============================================================================

echo "Restarting affected applications..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "macOS defaults applied successfully!"
echo "Note: Some changes may require logout/restart to take effect."
```

## Touch ID for sudo

Create separate script `home/.chezmoiscripts/01-common/run_once_after_00-darwin-touch-id-sudo.sh.tmpl`:

```bash
#!/usr/bin/env bash
{{ if ne .chezmoi.os "darwin" }}
exit 0
{{ end }}

set -e

PAM_FILE="/etc/pam.d/sudo_local"

# Check if Touch ID is already configured
if [[ -f "$PAM_FILE" ]] && grep -q "pam_tid.so" "$PAM_FILE"; then
  echo "Touch ID for sudo already configured"
  exit 0
fi

echo "Configuring Touch ID for sudo..."
echo "This requires administrator privileges."

# Create sudo_local if it doesn't exist
if [[ ! -f "$PAM_FILE" ]]; then
  sudo bash -c 'cat > /etc/pam.d/sudo_local << EOF
# sudo_local: local config file which survives system update
auth       sufficient     pam_tid.so
EOF'
  echo "Touch ID for sudo enabled!"
else
  echo "sudo_local exists but pam_tid.so not found. Manual configuration may be needed."
fi
```

## Implementation Steps

1. Create `run_once_after_00-darwin-system-defaults.sh.tmpl`
2. Create `run_once_after_00-darwin-touch-id-sudo.sh.tmpl`
3. Test on current system: `chezmoi apply --dry-run`
4. Apply and verify settings changed

## Notes

- Scripts use `run_once_after_` prefix - runs once after other files applied
- Template guards ensure macOS-only execution
- `killall` commands restart affected apps to apply changes
- Some settings require logout/restart
- dockutil section is conditional on dockutil being installed

## Success Criteria

- [ ] Both scripts created in correct location
- [ ] Scripts only run on macOS (template guard works)
- [ ] `defaults` commands match nix-darwin settings
- [ ] Dock items configured correctly
- [ ] Touch ID sudo works after apply
