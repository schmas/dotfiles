# shellcheck shell=bash
# upall-lib.sh — shared runner engine for `upall` and `ck-update`.
#
# Sourced, not executed. Provides a step registry and a natural-flow runner:
# each step prints a banner (index, running glyph, overall progress) then streams
# its output at FULL terminal width/height with native scrollback intact — scroll
# up in your terminal to review anything. Every executed step is also tee'd to
# ~/.cache/upall/<ts>/NN-key.log (newest 10 runs kept) so failures can be paged.
# No scroll region / alternate screen: nothing to break, logs never truncated.
#
# Public API:
#   upall_reset
#   upall_register KEY LABEL GUARD_CMD RUN_FN
#   upall_begin TITLE
#   upall_run_all            # runs every registered step in order
#   upall_end TITLE          # prints summary, review, notify; returns failed count
#   upall_hms SECONDS
#
# Portable to bash 3.2 (macOS): uses $SECONDS, guards empty-array expansion under
# `set -u`, no bash 4+ only builtins, no GNU-only coreutils flags.

UPALL_KEEP="${UPALL_KEEP:-10}"   # how many run-log dirs to retain

# ── Colors (blanked by policy in upall_begin) ─────────────────────────────────
BOLD='\033[1m'; DIM='\033[2m'; GREEN='\033[0;32m'; RED='\033[0;31m'
CYAN='\033[0;36m'; NC='\033[0m'

# ── State ─────────────────────────────────────────────────────────────────────
STEP_KEYS=(); STEP_LABELS=(); STEP_GUARDS=(); STEP_FNS=()
STEP_STATES=(); STEP_DURS=()
UPALL_FAILED=0
UPALL_RUN_DIR=""
UPALL_TITLE="upall"
_UPALL_NESTED=false
_UPALL_WANT_PLAIN="${_UPALL_WANT_PLAIN:-false}"
_UPALL_WIDTH=72

upall_reset() {
  STEP_KEYS=(); STEP_LABELS=(); STEP_GUARDS=(); STEP_FNS=()
  STEP_STATES=(); STEP_DURS=(); UPALL_FAILED=0
}

# upall_register KEY LABEL GUARD_CMD RUN_FN
# GUARD_CMD: shell snippet returning 0 when the step applies (e.g. "command -v brew");
# use "true" for unconditional steps. Stored literally and eval'd at check time.
upall_register() {
  STEP_KEYS+=("$1"); STEP_LABELS+=("$2"); STEP_GUARDS+=("$3"); STEP_FNS+=("$4")
  STEP_STATES+=("pending"); STEP_DURS+=("0")
}

# ── Helpers ───────────────────────────────────────────────────────────────────
# seconds -> "1h2m" / "3m4s" / "5s"
upall_hms() {
  local s=$1
  if [ "$s" -ge 3600 ]; then printf '%dh%dm' $((s/3600)) $(((s%3600)/60))
  elif [ "$s" -ge 60 ]; then printf '%dm%ds' $((s/60)) $((s%60))
  else printf '%ds' "$s"; fi
}

_upall_glyph() {
  case "$1" in
    ok)      printf '%b✓%b' "$GREEN" "$NC" ;;
    fail)    printf '%b✗%b' "$RED" "$NC" ;;
    running) printf '%b▶%b' "$CYAN" "$NC" ;;
    skip)    printf '%b⊘%b' "$DIM" "$NC" ;;
    *)       printf '%b·%b' "$DIM" "$NC" ;;
  esac
}

# Compact "✓✓✓▶·····" line reflecting all steps' current state.
_upall_progress() {
  local i
  [ ${#STEP_KEYS[@]} -gt 0 ] || return 0
  for i in "${!STEP_KEYS[@]}"; do _upall_glyph "${STEP_STATES[i]}"; done
}

_upall_rule() { printf '%b' "$DIM"; printf '─%.0s' $(seq 1 "$_UPALL_WIDTH"); printf '%b\n' "$NC"; }

# Suppress all ANSI when NO_COLOR / non-terminal / --plain.
_upall_apply_color_policy() {
  if [ -n "${NO_COLOR:-}" ] || [ ! -t 1 ] || [ "${_UPALL_WANT_PLAIN:-false}" = true ]; then
    BOLD=''; DIM=''; GREEN=''; RED=''; CYAN=''; NC=''
  fi
}

# ── Run lifecycle ─────────────────────────────────────────────────────────────
upall_begin() {
  UPALL_TITLE="${1:-upall}"
  [ -n "${UPALL_ACTIVE:-}" ] && _UPALL_NESTED=true
  _upall_apply_color_policy
  _UPALL_WIDTH=$( { [ -t 1 ] && tput cols; } 2>/dev/null || echo 72 )
  [ "$_UPALL_WIDTH" -gt 100 ] 2>/dev/null && _UPALL_WIDTH=100
  [ "$_UPALL_WIDTH" -lt 40  ] 2>/dev/null && _UPALL_WIDTH=40
  _upall_init_run_dir
  printf '%b▶ %s%b\n' "$BOLD" "$UPALL_TITLE" "$NC"
}

# upall_exec INDEX
upall_exec() {
  local i="$1" n rc log start
  n=$((i+1))
  # shellcheck disable=SC2086  # GUARD is a trusted literal snippet, not user input
  if ! eval "${STEP_GUARDS[i]}" >/dev/null 2>&1; then
    STEP_STATES[i]="skip"
    printf ' %b[%d/%d]%b %b %b%s%b %b(skipped)%b\n' \
      "$DIM" "$n" "${#STEP_KEYS[@]}" "$NC" "$(_upall_glyph skip)" \
      "$DIM" "${STEP_LABELS[i]}" "$NC" "$DIM" "$NC"
    return 0
  fi

  STEP_STATES[i]="running"
  echo
  _upall_rule
  printf ' %b[%d/%d]%b %b %b%s%b   %s\n' \
    "$BOLD" "$n" "${#STEP_KEYS[@]}" "$NC" "$(_upall_glyph running)" \
    "$BOLD" "${STEP_LABELS[i]}" "$NC" "$(_upall_progress)"
  _upall_rule

  start=$SECONDS
  if $_UPALL_NESTED; then
    # Parent runner already tees our whole output; run direct, no own logfile.
    "${STEP_FNS[i]}" 2>&1
    rc=$?
  else
    log="$UPALL_RUN_DIR/$(printf '%02d' "$n")-${STEP_KEYS[i]}.log"
    "${STEP_FNS[i]}" 2>&1 | tee "$log"
    rc=${PIPESTATUS[0]}
  fi
  STEP_DURS[i]=$(( SECONDS - start ))

  if [ "$rc" -eq 0 ]; then
    STEP_STATES[i]="ok"
    printf ' %b %b%s%b %b(%s)%b\n' "$(_upall_glyph ok)" \
      "$GREEN" "${STEP_LABELS[i]}" "$NC" "$DIM" "$(upall_hms "${STEP_DURS[i]}")" "$NC"
  else
    STEP_STATES[i]="fail"; UPALL_FAILED=$(( UPALL_FAILED + 1 ))
    printf ' %b %b%s%b %b(%s, exit %d)%b\n' "$(_upall_glyph fail)" \
      "$RED" "${STEP_LABELS[i]}" "$NC" "$DIM" "$(upall_hms "${STEP_DURS[i]}")" "$rc" "$NC"
  fi
  return 0
}

upall_run_all() {
  local i
  [ ${#STEP_KEYS[@]} -gt 0 ] || return 0
  for i in "${!STEP_KEYS[@]}"; do upall_exec "$i"; done
}

# ── Logs ──────────────────────────────────────────────────────────────────────
_upall_init_run_dir() {
  if $_UPALL_NESTED; then UPALL_RUN_DIR=""; return 0; fi
  local root="$HOME/.cache/upall"
  UPALL_RUN_DIR="$root/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$UPALL_RUN_DIR"
  ln -sfn "$UPALL_RUN_DIR" "$root/latest" 2>/dev/null || true
  # Rotate: keep the newest $UPALL_KEEP run dirs. `sort -r | tail -n +N` is portable
  # (BSD/macOS `head` has no `-n -N`; a GNU-only form would break stock macOS).
  find "$root" -maxdepth 1 -type d -name '20*' 2>/dev/null \
    | sort -r | tail -n +$(( UPALL_KEEP + 1 )) | while IFS= read -r d; do rm -rf "$d"; done
}

# ── Summary + review + notify ──────────────────────────────────────────────────
upall_end() {
  local title="${1:-upall}" i n icon label passed=0 failed=0 skipped=0 total
  total=${#STEP_KEYS[@]}
  if [ "$total" -gt 0 ]; then
    for i in "${!STEP_STATES[@]}"; do
      case "${STEP_STATES[i]}" in
        ok) passed=$((passed+1)) ;;
        fail) failed=$((failed+1)) ;;
        skip) skipped=$((skipped+1)) ;;
      esac
    done
  fi

  local body=""
  body+="$(printf '%b  %s Summary%b  (%d passed, %d failed, %d skipped, %d total)' \
    "$BOLD" "$title" "$NC" "$passed" "$failed" "$skipped" "$total")"$'\n'
  if [ "$total" -gt 0 ]; then
    for i in "${!STEP_KEYS[@]}"; do
      n=$((i+1))
      case "${STEP_STATES[i]}" in
        ok)   icon="✅"; label="${GREEN}success${NC}" ;;
        fail) icon="❌"; label="${RED}failed${NC}" ;;
        skip) icon="⊘";  label="${DIM}skipped${NC}" ;;
        *)    icon="·";  label="${DIM}pending${NC}" ;;
      esac
      body+="$(printf '  %2d. %-22s %s %b %b%s%b' "$n" "${STEP_LABELS[i]}" "$icon" "$label" \
        "$DIM" "$(upall_hms "${STEP_DURS[i]}")" "$NC")"$'\n'
    done
  fi
  [ -n "$UPALL_RUN_DIR" ] && body+="$(printf '%blogs: %s%b' "$DIM" "$UPALL_RUN_DIR" "$NC")"

  echo
  if command -v gum >/dev/null 2>&1 && [ -t 1 ]; then
    printf '%b\n' "$body" | gum style --border rounded --border-foreground 240 --padding "0 1"
  else
    printf '%b━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%b\n' "$BOLD" "$NC"
    printf '%b\n' "$body"
    printf '%b━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%b\n' "$BOLD" "$NC"
  fi

  if [ "$failed" -gt 0 ]; then
    printf '%b⚠️  %d step(s) failed.%b\n' "$RED" "$failed" "$NC"
    if ! $_UPALL_NESTED; then
      _upall_review_failures
      _upall_notify_failure "$title" "$failed"
    fi
  else
    printf '%b✅ All updates completed successfully!%b\n' "$GREEN" "$NC"
  fi
  return "$failed"
}

# Offer to open the first failed step's log in gum pager (interactive only).
_upall_review_failures() {
  local i first="" log n
  for i in "${!STEP_STATES[@]}"; do
    if [ "${STEP_STATES[i]}" = "fail" ]; then
      n=$((i+1))
      log="$UPALL_RUN_DIR/$(printf '%02d' "$n")-${STEP_KEYS[i]}.log"
      printf '   %b%s%b  %s\n' "$DIM" "${STEP_LABELS[i]}" "$NC" "$log"
      [ -z "$first" ] && first="$log"
    fi
  done
  [ -n "$first" ] || return 0
  if command -v gum >/dev/null 2>&1 && [ -t 0 ] && [ -t 1 ]; then
    if gum confirm "Open first failed log in pager?"; then
      gum pager < "$first"
    fi
  else
    printf '   %breview: less %s%b\n' "$DIM" "$first" "$NC"
  fi
}

_upall_notify_failure() {
  local title="$1" msg="$2 step(s) failed"
  if command -v terminal-notifier >/dev/null 2>&1; then
    terminal-notifier -title "$title" -message "$msg" -sound default >/dev/null 2>&1 || true
  elif command -v osascript >/dev/null 2>&1; then
    osascript -e "display notification \"$msg\" with title \"$title\"" >/dev/null 2>&1 || true
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "$title" "$msg" >/dev/null 2>&1 || true
  fi
}
