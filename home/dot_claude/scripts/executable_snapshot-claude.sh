#!/usr/bin/env bash
#
# snapshot-claude.sh
#
# Daily compressed snapshot of ~/.claude/ to Google Drive backup folder.
# Excludes high-volume low-value paths (session JSONLs, caches). Atomic write
# via /tmp + mv to avoid partial uploads during Drive sync.
#
# Retention: 7 daily archives + 4 weekly archives.
# Weekly archive is created on Sunday (a copy of that day's daily archive).
#
# Operator commands:
#   bash ~/.claude/scripts/snapshot-claude.sh              # normal run
#   SNAPSHOT_DRY_RUN=1 bash ~/.claude/scripts/snapshot-claude.sh   # dry-run, no side effects
#   launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.schmas.claude-snapshot.plist
#   launchctl bootout   gui/$(id -u) ~/Library/LaunchAgents/com.schmas.claude-snapshot.plist
#   launchctl kickstart -k gui/$(id -u)/com.schmas.claude-snapshot   # trigger once
#   launchctl list | grep claude-snapshot                  # status

set -euo pipefail

# -------- Config ------------------------------------------------------------

SOURCE_DIR="${HOME}/.claude"
DRIVE_DIR="${HOME}/Google Drive/My Drive/06_Sistema/Backups/claude-snapshots"
LOG_FILE="${HOME}/.claude/scripts/snapshot.log"
LOG_MAX_BYTES=$((1024 * 1024))   # 1 MB
KEEP_DAILY=7
KEEP_WEEKLY=4

DATE="$(date +%Y%m%d)"
WEEK="$(date +%Y%V)"
DOW="$(date +%u)"   # 1=Mon ... 7=Sun

TMP_ARCHIVE="/tmp/claude-${DATE}.tar.gz"
DAILY_ARCHIVE="${DRIVE_DIR}/claude-${DATE}.tar.gz"
WEEKLY_ARCHIVE="${DRIVE_DIR}/claude-weekly-${WEEK}.tar.gz"

DRY_RUN="${SNAPSHOT_DRY_RUN:-0}"

# -------- Logging -----------------------------------------------------------

log() {
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "[${ts}] $*" | tee -a "$LOG_FILE" >&2
}

rotate_log() {
  if [[ -f "$LOG_FILE" ]]; then
    local size
    size="$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)"
    if (( size > LOG_MAX_BYTES )); then
      mv "$LOG_FILE" "${LOG_FILE}.1"
      : > "$LOG_FILE"
    fi
  fi
}

# -------- Excludes ----------------------------------------------------------

# These are passed as --exclude='<pattern>' to tar. Patterns are relative to
# SOURCE_DIR. Keep this list in sync with what the snapshot is for: durable
# config, memory, hooks, rules, agents, skills index. Drop volatile caches and
# per-session ephemera.

TAR_EXCLUDES=(
  --exclude='.env'
  --exclude='cache'
  --exclude='paste-cache'
  --exclude='file-history'
  --exclude='shell-snapshots'
  --exclude='usage-data'
  --exclude='telemetry'
  --exclude='*.jsonl'
  --exclude='*.tmp'
  --exclude='.DS_Store'
  --exclude='mcp-needs-auth-cache.json'
  --exclude='stats-cache.json'
  --exclude='mcp-servers-backup.json'
  --exclude='settings.json.tmp'
  --exclude='settings.json.bak'
  --exclude='.venv'
  --exclude='node_modules'
  --exclude='__pycache__'
  --exclude='*.pyc'
  --exclude='plugins/cache'
  --exclude='.git'
)

# -------- Dry-run helper ----------------------------------------------------

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY-RUN: $*"
  else
    eval "$@"
  fi
}

# -------- Main --------------------------------------------------------------

rotate_log

log "snapshot starting: date=${DATE} week=${WEEK} dow=${DOW} dry_run=${DRY_RUN}"
log "source=${SOURCE_DIR}"
log "drive=${DRIVE_DIR}"

# 1. Ensure Drive folder exists.
if [[ "$DRY_RUN" == "1" ]]; then
  log "DRY-RUN: mkdir -p \"${DRIVE_DIR}\""
else
  mkdir -p "$DRIVE_DIR"
fi

# 2. Build the archive in /tmp first (atomic write pattern).
log "creating archive: ${TMP_ARCHIVE}"
if [[ "$DRY_RUN" == "1" ]]; then
  log "DRY-RUN: tar -czf \"${TMP_ARCHIVE}\" ${TAR_EXCLUDES[*]} -C \"$(dirname "$SOURCE_DIR")\" \"$(basename "$SOURCE_DIR")\""
else
  tar -czf "$TMP_ARCHIVE" "${TAR_EXCLUDES[@]}" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"
fi

# 3. Verify archive integrity before moving it into Drive.
if [[ "$DRY_RUN" != "1" ]]; then
  if ! tar -tzf "$TMP_ARCHIVE" > /dev/null 2>&1; then
    log "ERROR: archive integrity check failed for ${TMP_ARCHIVE}"
    rm -f "$TMP_ARCHIVE"
    exit 1
  fi
  SIZE="$(stat -f%z "$TMP_ARCHIVE" 2>/dev/null || stat -c%s "$TMP_ARCHIVE" 2>/dev/null || echo 0)"
  log "archive size: ${SIZE} bytes"
fi

# 4. Atomic move into Drive folder.
log "moving to: ${DAILY_ARCHIVE}"
run "mv \"${TMP_ARCHIVE}\" \"${DAILY_ARCHIVE}\""

# 5. On Sunday, also create a weekly archive (copy, not hard-link — Drive sync
#    can confuse hard links across volume boundaries).
if [[ "$DOW" == "7" ]]; then
  log "Sunday — creating weekly archive: ${WEEKLY_ARCHIVE}"
  run "cp \"${DAILY_ARCHIVE}\" \"${WEEKLY_ARCHIVE}\""
fi

# 6. Retention prune. Run AFTER a successful new snapshot — never delete prior
#    archives if the new one failed to write.
prune() {
  local pattern="$1"
  local keep="$2"
  local files
  files="$(ls -1 "$DRIVE_DIR"/${pattern} 2>/dev/null | sort -r || true)"
  if [[ -z "$files" ]]; then
    return
  fi
  local idx=0
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    idx=$((idx + 1))
    if (( idx > keep )); then
      log "pruning: $f"
      run "rm -f \"$f\""
    fi
  done <<< "$files"
}

log "retention: keep ${KEEP_DAILY} daily, ${KEEP_WEEKLY} weekly"
prune 'claude-2*.tar.gz' "$KEEP_DAILY"
prune 'claude-weekly-*.tar.gz' "$KEEP_WEEKLY"

log "snapshot complete"
