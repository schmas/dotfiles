# shellcheck shell=bash
# aaa-watch-pipeline-lib.sh — shared helpers for `aaa-watch-pipeline`.
#
# Sourced, not executed (mirrors bin/lib/upall-lib.sh). Holds the pure
# rendering/discovery/polling helpers so the main script keeps only arg
# parsing, preflight, PR/branch resolution, notify, the top-level wait loop,
# and the final outcome summary.
#
# The functions read the main script's globals (PR_ID, WS, REPO, BRANCH, SHA,
# RENDER_EVERY, SECONDS, the C_* colors, SONAR_SERVICES, JQ_TIME) as free
# variables — they are defined in the same shell after sourcing, and every
# function is only *called* once those globals exist. Colors and SONAR_SERVICES
# are defined here (not the main script) so they exist the moment the first
# helper runs under `set -u`.
#
# Portable to bash 3.2 (macOS): guards empty-array expansion under `set -u`.

# ── Colors + glyphs, only on a TTY (piped/CI output stays plain) ─────────────
if [ -t 1 ]; then TTY=true; else TTY=false; fi
if [ "$TTY" = true ]; then
  C_RST=$'\033[0m'; C_GRN=$'\033[32m'; C_RED=$'\033[31m'
  C_YEL=$'\033[33m'; C_DIM=$'\033[2m';  C_BLU=$'\033[1;34m'
else
  C_RST=""; C_GRN=""; C_RED=""; C_YEL=""; C_DIM=""; C_BLU=""
fi

# connect-plus-backend's SonarCloud projects, one per microservice (see
# scripts/combine_sonar.sh: `-Dsonar.projectKey=connectplus_$SERVICE_NAME`).
SONAR_SERVICES=(auth-service clb-service config-service db-service
  integration-service member-service note-service report-service service-discovery)

# jq prelude: ISO8601 → epoch (tolerating fractional seconds and a +00:00 offset),
# and seconds → compact "1h2m" / "3m4s" / "5s". Reused for every timing display.
JQ_TIME='
def ep: sub("\\.[0-9]+";"") | sub("\\+00:00$";"Z") | fromdateiso8601;
def hms: floor
  | if . >= 3600 then "\(./3600|floor)h\((.%3600)/60|floor)m"
    elif . >= 60 then "\(./60|floor)m\(.%60)s"
    else "\(.)s" end;'

# Duration string ("30s", "2m", "1h", or bare seconds) → seconds.
to_seconds() {
  case "$1" in
    *h) printf '%d' $(( ${1%h} * 3600 )) ;;
    *m) printf '%d' $(( ${1%m} * 60 )) ;;
    *s) printf '%d' "${1%s}" ;;
    *)  printf '%d' "$1" ;;
  esac
}

# Seconds → "Mm SSs".
fmt_dur() { printf '%dm%02ds' $(( $1 / 60 )) $(( $1 % 60 )); }

# State name → colored status glyph. Handles both build-status states
# (SUCCESSFUL/FAILED/INPROGRESS/STOPPED) and pipeline-step states
# (COMPLETED-resolved-to-result, IN_PROGRESS, PENDING, …).
cglyph() {
  case "$1" in
    SUCCESSFUL)                     printf '%s✓%s' "$C_GRN" "$C_RST" ;;
    FAILED|ERROR)                   printf '%s✗%s' "$C_RED" "$C_RST" ;;
    STOPPED)                        printf '%s■%s' "$C_RED" "$C_RST" ;;
    INPROGRESS|IN_PROGRESS|RUNNING) printf '%s▶%s' "$C_YEL" "$C_RST" ;;
    PENDING|NOT_RUN|PAUSED|HALTED)  printf '%s·%s' "$C_DIM" "$C_RST" ;;
    *)                              printf '?' ;;
  esac
}

# Bitbucket Cloud pipeline URL → "workspace repo build_number" (empty if not one).
pipeline_coords() {
  printf '%s' "$1" \
    | sed -nE 's#^https?://bitbucket\.org/([^/]+)/([^/]+)/pipelines/results/([0-9]+).*#\1 \2 \3#p'
}

# git "origin" remote → "workspace repo" for Bitbucket Cloud (empty otherwise).
# Used to address the raw timing APIs (`bkt api /2.0/repositories/<ws>/<repo>/…`).
bb_coords() {
  local u; u=$(git remote get-url origin 2>/dev/null); u=${u%.git}
  printf '%s' "$u" | sed -nE 's#.*bitbucket\.org[:/]+([^/]+)/([^/]+)$#\1 \2#p'
}

# checks-JSON → coords ("ws repo build") of the latest pipeline (highest build),
# or empty when no pipeline is attached. Reused by render + final summary.
latest_pipeline_coords() {
  printf '%s' "$1" | jq -r '.statuses[]?.url // empty' | while read -r u; do
    c=$(pipeline_coords "$u"); [ -n "$c" ] && printf '%s\n' "$c"
  done | sort -k3 -n | tail -1
}

# ── Sonar summary ─────────────────────────────────────────────────────────────
# print_sonar_summary MODE ID  — MODE is "pr" (ID = PR number) or "branch"
# (ID = branch name). Prints each connect-plus service's SonarCloud quality gate
# + new-code metrics, scoped by the mutually-exclusive `pullRequest=` / `branch=`
# query param. Best-effort: skips quietly if `sonar` isn't installed, and skips a
# service with no analysis for this PR/branch (its API call returns nothing).
# The branch identifier is URL-encoded (@uri) so branch names containing &/=/#
# can't smuggle extra query parameters into the Sonar API call.
print_sonar_summary() {
  command -v sonar >/dev/null 2>&1 || return 0
  local mode="$1" id="$2" param header_id caveat="" enc

  if [ "$mode" = "branch" ]; then
    enc=$(jq -rn --arg b "$id" '$b|@uri')
    param="branch=${enc}"
    header_id="branch ${id}"
    caveat="  ${C_DIM}(new code = the project's configured new-code period, not a PR diff)${C_RST}"
  else
    param="pullRequest=${id}"
    header_id="PR #${id}"
  fi

  printf '\n%sSonar Quality Gate%s (%s)\n' "$C_BLU" "$C_RST" "$header_id"
  [ -n "$caveat" ] && printf '%s\n' "$caveat"

  local svc key resp mresp status conds found=false new acc hs cov dup
  for svc in "${SONAR_SERVICES[@]}"; do
    key="connectplus_${svc}"
    resp=$(sonar api get "/api/qualitygates/project_status?projectKey=${key}&${param}" 2>/dev/null)
    [ -n "$resp" ] || continue
    found=true
    status=$(printf '%s' "$resp" | jq -r '.projectStatus.status // "UNKNOWN"')
    if [ "$status" = "OK" ]; then
      printf '  %s✓%s %s: PASSED\n' "$C_GRN" "$C_RST" "$svc"
    else
      printf '  %s✗%s %s: %s\n' "$C_RED" "$C_RST" "$svc" "$status"
      conds=$(printf '%s' "$resp" | jq -r '
        .projectStatus.conditions[]? | select(.status != "OK")
        | (if .comparator == "LT" then "≥" elif .comparator == "GT" then "≤" else .comparator end) as $op
        | "      \(.metricKey): \(.actualValue // "?") (need \($op) \(.errorThreshold))"')
      [ -n "$conds" ] && printf '%s\n' "$conds"
    fi

    # New-code metrics (Bitbucket's Code Quality panel): New Issues, Accepted
    # Issues, Security Hotspots, Coverage, Duplications. Coverage/duplications
    # are absent from the API when no measurable new lines were touched.
    mresp=$(sonar api get "/api/measures/component?component=${key}&${param}&metricKeys=new_violations,new_accepted_issues,new_security_hotspots,new_coverage,new_duplicated_lines_density" 2>/dev/null)
    read -r new acc hs cov dup <<< "$(printf '%s' "$mresp" | jq -r '
      (.component.measures // []) as $m
      | (($m[] | select(.metric=="new_violations") | .periods[0].value) // "0") as $new
      | (($m[] | select(.metric=="new_accepted_issues") | .periods[0].value) // "0") as $acc
      | (($m[] | select(.metric=="new_security_hotspots") | .periods[0].value) // "0") as $hs
      | (($m[] | select(.metric=="new_coverage") | .periods[0].value) // "n/a") as $cov
      | (($m[] | select(.metric=="new_duplicated_lines_density") | .periods[0].value) // "n/a") as $dup
      | "\($new) \($acc) \($hs) \($cov) \($dup)"' 2>/dev/null)"
    [ "${cov:-n/a}" != "n/a" ] && cov=$(printf '%.1f%%' "$cov")
    [ "${dup:-n/a}" != "n/a" ] && dup=$(printf '%.1f%%' "$dup")
    printf '      New Issues: %s · Accepted: %s · Hotspots: %s · Coverage: %s · Duplications: %s\n' \
      "${new:-0}" "${acc:-0}" "${hs:-0}" "${cov:-n/a}" "${dup:-n/a}"
  done
  if [ "$found" = false ]; then
    if [ "$mode" = "branch" ]; then
      printf '  %s(no Sonar analysis found for branch %s)%s\n' "$C_DIM" "$id" "$C_RST"
    else
      printf '  %s(no Sonar analysis found for this PR)%s\n' "$C_DIM" "$C_RST"
    fi
  fi
}

# ── Per-pipeline detail renderer ─────────────────────────────────────────────
# render_pipeline_detail WS REPO BUILD STATE LABEL
# One pipeline's live block: the header line (glyph, LABEL, #build, overall
# running/ran clock, step tally) then each step indented with its own duration.
# Extracted from render_block's inline loop body so both PR-mode and branch-mode
# render an identical-depth view. STATE feeds the header glyph; LABEL is the
# header text (a PR check name in PR mode, the branch in branch mode).
render_pipeline_detail() {
  local ws="$1" repo="$2" build="$3" state="$4" label="$5"
  local pv uuid enc overall steps_json ok bad run total tail st sname stime

  # Pipeline-level clock: created_on → completed_on (done) or now (running).
  pv=$(bkt pipeline view "$build" --workspace "$ws" --repo "$repo" --json 2>/dev/null)
  # Branch mode passes STATE="" → derive the header glyph state from this same pv
  # (no extra API call). PR mode passes the check's build-status state verbatim,
  # keeping its output byte-identical.
  [ -n "$state" ] || state=$(printf '%s' "$pv" | jq -r '
    .pipeline.state.name as $n
    | (if $n=="COMPLETED" then (.pipeline.state.result.name // "COMPLETED") else $n end) // empty' 2>/dev/null)
  uuid=$(printf '%s' "$pv" | jq -r '.pipeline.uuid // empty')
  overall=$(printf '%s' "$pv" | jq -r "$JQ_TIME"'
    .pipeline | (.created_on|ep) as $c
    | if (.completed_on // "") != "" then "ran " + (((.completed_on|ep) - $c)|hms)
      else "running " + ((now - $c)|hms) end' 2>/dev/null)
  # Per-step state + duration from the raw steps API (pipeline view lacks timing).
  enc=$(printf '%s' "$uuid" | sed 's/{/%7B/g; s/}/%7D/g')
  steps_json=$(bkt api "/2.0/repositories/$ws/$repo/pipelines/$enc/steps/?pagelen=100" 2>/dev/null)
  read -r ok bad run total <<< "$(printf '%s' "$steps_json" | jq -r '
    [.values[]?] as $s
    | ([$s[] | select(.state.name=="COMPLETED" and .state.result.name=="SUCCESSFUL")] | length) as $ok
    | ([$s[] | select(.state.name=="COMPLETED" and (.state.result.name|IN("FAILED","ERROR","STOPPED")))] | length) as $bad
    | ([$s[] | select(.state.name=="IN_PROGRESS")] | length) as $run
    | "\($ok) \($bad) \($run) \($s|length)"' 2>/dev/null)"
  : "${ok:=0}" "${bad:=0}" "${run:=0}" "${total:=0}"
  tail="${ok}/${total} done"
  [ "$run" -gt 0 ] && tail="$tail, $run running"
  [ "$bad" -gt 0 ] && tail="$tail, ${C_RED}${bad} failed${C_RST}"
  printf '%s %s  #%s  %s%s%s  (%s)\n' \
    "$(cglyph "$state")" "$label" "$build" "$C_YEL" "$overall" "$C_RST" "$tail"
  while IFS=$'\t' read -r st sname stime; do
    [ -n "$sname" ] || continue
    printf '    %s %-44s %s%s%s\n' "$(cglyph "$st")" "${sname:0:44}" "$C_DIM" "$stime" "$C_RST"
  done < <(printf '%s' "$steps_json" | jq -r "$JQ_TIME"'
    .values[]? | .state.name as $sn
    | (if $sn == "COMPLETED" then (.state.result.name // "COMPLETED") else $sn end) as $st
    | (if $sn == "COMPLETED" then
         (if (.duration_in_seconds // null) != null then (.duration_in_seconds|hms)
          elif (.started_on and .completed_on) then (((.completed_on|ep) - (.started_on|ep))|hms)
          else "" end)
       elif ($sn == "IN_PROGRESS" and .started_on) then ((now - (.started_on|ep))|hms)
       else "" end) as $t
    | [$st, .name, $t] | @tsv' 2>/dev/null)
}

# ── PR-mode status block ──────────────────────────────────────────────────────
# Render the current PR status block: every top-level check with how long it took
# (or has been running), and for the latest pipeline the per-step breakdown
# beneath it. Reads PR_ID/SHA/WS/REPO/RENDER_EVERY/SECONDS globals.
render_block() {
  local rows state name url t coords ws repo build latest

  printf '%sPR #%s%s  %s elapsed  (refresh %ss, Ctrl-C to stop)\n' \
    "$C_BLU" "$PR_ID" "$C_RST" "$(fmt_dur "$SECONDS")" "$RENDER_EVERY"

  # Check rows as "state<TAB>name<TAB>url<TAB>time". Prefer the commit-statuses
  # API — it carries created_on/updated_on, so each check shows its elapsed time.
  # Fall back to `bkt pr checks` (no timing) when workspace/repo/sha are unknown.
  rows=""
  if [ -n "$SHA" ] && [ -n "$WS" ] && [ -n "$REPO" ]; then
    rows=$(bkt api "/2.0/repositories/$WS/$REPO/commit/$SHA/statuses?pagelen=100" 2>/dev/null | jq -r "$JQ_TIME"'
      .values[]?
      | (if .state == "INPROGRESS" then (now - (.created_on|ep))
         else ((.updated_on|ep) - (.created_on|ep)) end) as $d
      | [.state, .name, (.url // ""), ($d|hms)] | @tsv' 2>/dev/null)
  fi
  [ -n "$rows" ] || rows=$(bkt pr checks "$PR_ID" --json 2>/dev/null \
    | jq -r '.statuses[]? | [.state, .name, (.url // ""), ""] | @tsv' 2>/dev/null)

  # When several pipeline runs are attached (re-runs), only expand the latest
  # (highest build number); older ones collapse to a one-liner.
  latest=$(printf '%s\n' "$rows" | cut -f3 | while read -r u; do
    c=$(pipeline_coords "$u"); [ -n "$c" ] && { read -r _ _ b <<< "$c"; printf '%s\n' "$b"; }
  done | sort -n | tail -1)

  while IFS=$'\t' read -r state name url t; do
    [ -n "$name" ] || continue
    coords=$(pipeline_coords "$url")
    if [ -n "$coords" ]; then
      read -r ws repo build <<< "$coords"
      if [ -n "$latest" ] && [ "$build" != "$latest" ]; then
        printf '%s %s  #%s  [%s] %s(superseded)%s\n' \
          "$(cglyph "$state")" "$name" "$build" "$state" "$C_DIM" "$C_RST"
        continue
      fi
      render_pipeline_detail "$ws" "$repo" "$build" "$state" "$name"
    else
      printf '%s %-44s %s%s%s\n' "$(cglyph "$state")" "${name:0:44}" "$C_DIM" "$t" "$C_RST"
    fi
  done <<< "$rows"

  # Live Sonar quality gate: shown on every refresh once analysis exists,
  # not gated on the checks finishing/passing.
  [ "$REPO" = "connect-plus-backend" ] && print_sonar_summary pr "$PR_ID"
}

# ── Branch-mode discovery ─────────────────────────────────────────────────────
# discover_branch_pipelines WS REPO BRANCH
# Emit TSV rows "build<TAB>state<TAB>created_on<TAB>result" for pipelines whose
# target is BRANCH, most-recent first, from a SINGLE most-recent page
# (pagelen=50, no `.next` pagination — see plan; user accepted the residual risk
# that a match can fall outside the 50-item window). Uses the raw pipelines
# endpoint because bkt's own `pipeline list/view --json` has no usable branch
# field. Returns:
#   0  rows on stdout (>=1 branch match)
#   1  could not fetch the endpoint (auth/network)
#   2  page had pipelines but none matched the branch ("not in the last 50")
#   3  page had zero pipelines at all
discover_branch_pipelines() {
  local ws="$1" repo="$2" branch="$3" resp total rows
  resp=$(bkt api "/2.0/repositories/$ws/$repo/pipelines/?pagelen=50&sort=-created_on" 2>/dev/null) || return 1
  [ -n "$resp" ] || return 1
  total=$(printf '%s' "$resp" | jq -r '(.values // []) | length' 2>/dev/null)
  : "${total:=0}"
  # jq --arg for the branch filter — never interpolate BRANCH into the program
  # (branch names can contain " / backslash). `result` is emitted LAST because
  # it's the only field that can be empty (running/pending pipelines have no
  # result yet): a tab-IFS `read` collapses an empty field only when it sits
  # between two others, so the nullable field must be trailing.
  rows=$(printf '%s' "$resp" | jq -r --arg branch "$branch" '
    (.values // [])
    | map(select(.target.ref_type == "branch" and .target.ref_name == $branch))
    | sort_by(.build_number) | reverse
    | .[]
    | [ (.build_number|tostring),
        (.state.name // ""),
        (.created_on // ""),
        (.state.result.name // "") ] | @tsv' 2>/dev/null)
  if [ -n "$rows" ]; then
    printf '%s\n' "$rows"
    return 0
  fi
  [ "$total" -gt 0 ] && return 2 || return 3
}

# ── Branch-mode single-target poll loop ──────────────────────────────────────
# poll_pipeline WS REPO BUILD TIMEOUT INTERVAL MAX_INTERVAL
# Backgrounded backoff poll of ONE pipeline build. Silent — the foreground
# redraw loop owns the display; this only decides the exit code, mirroring
# `bkt pr checks --wait`'s wait/backoff/timeout contract (bkt has no --wait for
# a bare pipeline). Re-checks the build's live state every tick (the staleness
# safety net: an already-finished build resolves at once, not at timeout).
# Tracks consecutive bkt/jq failures separately from confirmed-pending state so
# a transient hiccup near the timeout boundary isn't misreported as a timeout.
# Exit: 0 SUCCESSFUL · 1 FAILED/STOPPED/ERROR · 8 timeout still pending ·
#       9 died after AAA_POLL_MAX_FAILS consecutive bkt/jq failures.
poll_pipeline() {
  local ws="$1" repo="$2" build="$3" timeout="$4" interval="$5" max_interval="$6"
  local t_secs i_secs max_secs waited=0 fails=0 pv sn res
  t_secs=$(to_seconds "$timeout")
  i_secs=$(to_seconds "$interval"); [ "$i_secs" -lt 1 ] && i_secs=1
  max_secs=$(to_seconds "$max_interval")

  while :; do
    pv=$(bkt pipeline view "$build" --workspace "$ws" --repo "$repo" --json 2>/dev/null)
    sn=$(printf '%s' "$pv" | jq -r '.pipeline.state.name // empty' 2>/dev/null)
    if [ -z "$sn" ]; then
      fails=$((fails + 1))
      [ "$fails" -ge "${AAA_POLL_MAX_FAILS:-3}" ] && return 9
    else
      fails=0
      if [ "$sn" = "COMPLETED" ]; then
        res=$(printf '%s' "$pv" | jq -r '.pipeline.state.result.name // empty' 2>/dev/null)
        case "$res" in
          SUCCESSFUL) return 0 ;;
          *)          return 1 ;;   # FAILED/STOPPED/ERROR or unknown terminal → failure
        esac
      fi
      # PENDING / IN_PROGRESS → keep waiting.
    fi
    # Timeout (0 = no timeout) checked against cumulative wait, not wall SECONDS,
    # so it matches the documented "max time to wait" semantics.
    if [ "$t_secs" -gt 0 ] && [ "$waited" -ge "$t_secs" ]; then
      return 8
    fi
    sleep "$i_secs"
    waited=$((waited + i_secs))
    # Back off toward MAX_INTERVAL (mirrors bkt's 30s→2m backoff).
    if [ "$max_secs" -gt 0 ] && [ "$i_secs" -lt "$max_secs" ]; then
      i_secs=$((i_secs * 2)); [ "$i_secs" -gt "$max_secs" ] && i_secs="$max_secs"
    fi
  done
}

# ── Branch-mode picker (2+ running, no --all) ────────────────────────────────
# run_picker ROW...  (each ROW = "build<TAB>state<TAB>created_on<TAB>result")
# Prints a numbered list of the running pipelines, reads a selection, and sets
# the global PICK_BUILD to the chosen build number. The selection is validated
# as all-digits BEFORE any arithmetic comparison — bash's -ge/-le evaluate their
# operands, so a crafted value could otherwise run embedded $(...) from stdin.
run_picker() {
  local -a rows=("$@")
  # BRANCH is a main-script global; PICK_BUILD is consumed by the caller there.
  # shellcheck disable=SC2153
  printf '%s%d running pipelines on %s%s — pick one to watch:\n' \
    "$C_BLU" "${#rows[@]}" "$BRANCH" "$C_RST"
  local i=1 row build state created result age
  for row in "${rows[@]}"; do
    IFS=$'\t' read -r build state created result <<< "$row"
    age=$(printf '%s' "$created" | jq -rR "$JQ_TIME"'(now - (.|ep))|hms' 2>/dev/null)
    printf '  %d) #%s  (started %s ago)\n' "$i" "$build" "${age:-?}"
    i=$((i + 1))
  done
  printf 'Selection [1-%d]: ' "${#rows[@]}"
  local choice
  read -r choice
  [[ "$choice" =~ ^[0-9]+$ ]] || die "invalid selection: '$choice'"
  { [ "$choice" -ge 1 ] && [ "$choice" -le "${#rows[@]}" ]; } || die "selection out of range: $choice"
  # shellcheck disable=SC2034  # PICK_BUILD is read by run_branch_mode in the main script
  IFS=$'\t' read -r PICK_BUILD _ _ _ <<< "${rows[$((choice - 1))]}"
}

# ── Branch-mode macro view (2+ running, --all) ───────────────────────────────
# render_macro_table ROW...  (each ROW = "build<TAB>state<TAB>created_on<TAB>result")
# Compact one-line-per-pipeline table (glyph, build, status, started-ago) — no
# step breakdown, no Sonar. Reads MACRO_BRANCH/RENDER_EVERY/SECONDS globals.
render_macro_table() {
  printf '%sPipelines on %s%s  %s elapsed  (refresh %ss, Ctrl-C to stop)\n' \
    "$C_BLU" "$MACRO_BRANCH" "$C_RST" "$(fmt_dur "$SECONDS")" "$RENDER_EVERY"
  local row build state created result glyph statelbl age
  for row in "$@"; do
    IFS=$'\t' read -r build state created result <<< "$row"
    if [ "$state" = "COMPLETED" ]; then
      glyph=$(cglyph "$result"); statelbl="$result"
    else
      glyph=$(cglyph "$state"); statelbl="$state"
    fi
    age=$(printf '%s' "$created" | jq -rR "$JQ_TIME"'(now - (.|ep))|hms' 2>/dev/null)
    printf '  %s  #%-7s %-11s started %s ago\n' "$glyph" "$build" "$statelbl" "${age:-?}"
  done
}

# run_macro_watch TIMEOUT  — watch every build in the global MACRO_QUEUE array
# (each "build<TAB>state<TAB>created_on<TAB>result"), re-polling each per tick,
# firing that build's own notification the moment it completes and dropping it
# from the watching set, until the set empties or TIMEOUT (overall) hits.
# The per-tick scan is sequential (N builds = N calls/tick); accepted as a
# documented v1 limitation for a personal tool's realistic pipeline counts.
# Notifications are keyed per build (aaa-pipeline-$REPO-$build) with a per-build
# click-URL so a FAILED pipeline's notification is never silently replaced by a
# later one. Reads WS/REPO/MACRO_BRANCH/RENDER_EVERY globals; needs notify()/die.
run_macro_watch() {
  local timeout="$1" t_secs
  t_secs=$(to_seconds "$timeout")
  local -a queue=(${MACRO_QUEUE[@]+"${MACRO_QUEUE[@]}"})
  local prev_lines=0 first=true

  [ "$TTY" = true ] && printf '\033[?25l'
  while [ "${#queue[@]}" -gt 0 ]; do
    local -a next=() display=()
    local row build old_state created pv sn res newrow url group block n
    for row in "${queue[@]}"; do
      IFS=$'\t' read -r build old_state created _ <<< "$row"   # old result unused; re-polled below
      pv=$(bkt pipeline view "$build" --workspace "$WS" --repo "$REPO" --json 2>/dev/null)
      sn=$(printf '%s' "$pv" | jq -r '.pipeline.state.name // empty' 2>/dev/null)
      res=$(printf '%s' "$pv" | jq -r '.pipeline.state.result.name // empty' 2>/dev/null)
      [ -n "$sn" ] || sn="$old_state"   # transient failure → keep last known state
      newrow="${build}"$'\t'"${sn}"$'\t'"${created}"$'\t'"${res}"
      display+=("$newrow")
      if [ "$sn" = "COMPLETED" ]; then
        url="https://bitbucket.org/${WS}/${REPO}/pipelines/results/${build}"
        group="aaa-pipeline-${REPO}-${build}"
        case "$res" in
          SUCCESSFUL) notify "✅ ${REPO} #${build} — pipeline passed" "branch ${MACRO_BRANCH}" "Glass" "$group" "$url" ;;
          FAILED|STOPPED|ERROR) notify "❌ ${REPO} #${build} — pipeline ${res}" "branch ${MACRO_BRANCH}" "Basso" "$group" "$url" ;;
          *) notify "⚠️ ${REPO} #${build} — pipeline done (${res:-?})" "branch ${MACRO_BRANCH}" "Funk" "$group" "$url" ;;
        esac
      else
        next+=("$newrow")
      fi
    done

    block=$(render_macro_table ${display[@]+"${display[@]}"})
    n=$(printf '%s\n' "$block" | wc -l | tr -d ' ')
    if [ "$TTY" = true ]; then
      [ "$first" = false ] && printf '\033[%dA\033[J' "$prev_lines"
    else
      [ "$first" = false ] && printf '\n'
    fi
    printf '%s\n' "$block"
    prev_lines=$n; first=false

    queue=(${next[@]+"${next[@]}"})
    [ "${#queue[@]}" -eq 0 ] && break
    if [ "$t_secs" -gt 0 ] && [ "$SECONDS" -ge "$t_secs" ]; then
      printf '%s(timed out after %s; %d still running)%s\n' "$C_YEL" "$timeout" "${#queue[@]}" "$C_RST"
      break
    fi
    sleep "$RENDER_EVERY"
  done
}
