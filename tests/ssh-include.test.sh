#!/usr/bin/env bash
# Tests for ssh_top_include in
# home/.chezmoiscripts/01-common/run_onchange_after_00-local-files.sh.tmpl:
# the agent and pack Includes must sit above the first Host or Match block,
# because an Include inside a block applies only to that block.
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$TESTS_DIR/.." && pwd)"
# shellcheck source=SCRIPTDIR/lib/assert.sh
. "$TESTS_DIR/lib/assert.sh"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/ssh-include.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

SCRIPT="$REPO/home/.chezmoiscripts/01-common/run_onchange_after_00-local-files.sh.tmpl"
sed -n '/^# >>> ssh_top_include >>>$/,/^# <<< ssh_top_include <<<$/p' "$SCRIPT" >"$TMP/fn.sh"
# shellcheck source=/dev/null
. "$TMP/fn.sh"
assert_eq yes "$(declare -F ssh_top_include >/dev/null && echo yes || echo no)" "the script defines ssh_top_include"

AGENT="Include ~/.ssh/agent_config"
PACK="Include ~/.ssh/config.d/*"
f="$TMP/config"
both() {
  ssh_top_include "$f" "$AGENT" "# agent comment" || true
  ssh_top_include "$f" "$PACK" "# pack comment" || true
}
first_block() { grep -niE '^[[:space:]]*(host|match)([[:space:]=]|$)' "$f" | head -1 | cut -d: -f1; }
line_of() { grep -nxF "$1" "$f" | cut -d: -f1 | tr '\n' ' ' | sed 's/ $//'; }

# A config merged once: the template (with both Includes) was appended below
# the user's own Host block, so both Includes sit inside that block.
printf 'Host old\n  User me\n\n# chezmoi:merged\n# agent comment\n%s\n\n# pack comment\n%s\n\nHost *\n  ServerAliveInterval 15\n' \
  "$AGENT" "$PACK" >"$f"
both
assert_eq 1 "$(grep -cxF "$AGENT" "$f")" "merged: one agent Include"
assert_eq 1 "$(grep -cxF "$PACK" "$f")" "merged: one pack Include"
a="$(line_of "$AGENT")"; p="$(line_of "$PACK")"; h="$(first_block)"
assert_eq yes "$([ "$a" -lt "$h" ] && [ "$p" -lt "$h" ] && echo yes || echo no)" "merged: both Includes above the first Host ($a, $p < $h)"
assert_eq yes "$([ "$a" -lt "$p" ] && echo yes || echo no)" "merged: agent Include before pack Include"
assert_eq 1 "$(grep -cxF '# agent comment' "$f")" "merged: the old agent comment is not left behind"
assert_eq '  User me' "$(sed -n "$((h + 1))p" "$f")" "merged: the user's Host block is intact"

# Already in place: no change, and the function says so.
before="$(cat "$f")"
assert_status 1 "in place: reports no change" -- ssh_top_include "$f" "$PACK" "# pack comment"
assert_eq "$before" "$(cat "$f")" "in place: file unchanged"

# Missing pack Include: added above the first Host, below the agent Include.
# The comment directly above the first Host stays with it.
printf '# agent comment\n%s\n\n# keepalive\nHost *\n  TCPKeepAlive yes\n' "$AGENT" >"$f"
assert_status 0 "missing: reports a change" -- ssh_top_include "$f" "$PACK" "# pack comment"
assert_eq yes "$([ "$(line_of "$AGENT")" -lt "$(line_of "$PACK")" ] && [ "$(line_of "$PACK")" -lt "$(first_block)" ] && echo yes || echo no)" "missing: agent < pack < first Host"
assert_eq '# keepalive' "$(sed -n "$(($(first_block) - 1))p" "$f")" "missing: the Host comment stays with its Host"

# A Match block counts as a block too; HostName inside a block does not.
printf 'Match host x\n  HostName y\n' >"$f"
ssh_top_include "$f" "$PACK" "# pack comment" || true
assert_eq "$PACK" "$(sed -n 2p "$f")" "Match: Include above the Match block"

# No block at all: the Include is still added.
printf 'ForwardAgent no\n' >"$f"
ssh_top_include "$f" "$PACK" "# pack comment" || true
assert_eq 1 "$(grep -cxF "$PACK" "$f")" "no block: Include added"

assert_eq yes "$([ -n "$(find "$f" -perm 600)" ] && echo yes || echo no)" "the file is mode 600"

finish
