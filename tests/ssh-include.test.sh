#!/usr/bin/env bash
# Tests for ssh_top_include in
# home/.chezmoiscripts/01-common/run_onchange_after_00-local-files.sh.tmpl:
# the config.d Include must sit above the first Host or Match block,
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
assert_eq yes "$(declare -F ssh_top_include >/dev/null && declare -F ssh_drop_include >/dev/null && echo yes || echo no)" "the script defines ssh_top_include and ssh_drop_include"

OTHER="Include ~/.ssh/other_config"
PACK="Include ~/.ssh/config.d/*"
f="$TMP/config"
both() {
  ssh_top_include "$f" "$OTHER" "# other comment" || true
  ssh_top_include "$f" "$PACK" "# pack comment" || true
}
first_block() { grep -niE '^[[:space:]]*(host|match)([[:space:]=]|$)' "$f" | head -1 | cut -d: -f1; }
line_of() { grep -nxF "$1" "$f" | cut -d: -f1 | tr '\n' ' ' | sed 's/ $//'; }

# A config merged once: the template (with both Includes) was appended below
# the user's own Host block, so both Includes sit inside that block.
printf 'Host old\n  User me\n\n# chezmoi:merged\n# other comment\n%s\n\n# pack comment\n%s\n\nHost *\n  ServerAliveInterval 15\n' \
  "$OTHER" "$PACK" >"$f"
both
assert_eq 1 "$(grep -cxF "$OTHER" "$f")" "merged: one other Include"
assert_eq 1 "$(grep -cxF "$PACK" "$f")" "merged: one pack Include"
a="$(line_of "$OTHER")"; p="$(line_of "$PACK")"; h="$(first_block)"
assert_eq yes "$([ "$a" -lt "$h" ] && [ "$p" -lt "$h" ] && echo yes || echo no)" "merged: both Includes above the first Host ($a, $p < $h)"
assert_eq yes "$([ "$a" -lt "$p" ] && echo yes || echo no)" "merged: the first Include stays first"
assert_eq 1 "$(grep -cxF '# other comment' "$f")" "merged: the old comment is not left behind"
assert_eq '  User me' "$(sed -n "$((h + 1))p" "$f")" "merged: the user's Host block is intact"

# Already in place: no change, and the function says so.
before="$(cat "$f")"
assert_status 1 "in place: reports no change" -- ssh_top_include "$f" "$PACK" "# pack comment"
assert_eq "$before" "$(cat "$f")" "in place: file unchanged"

# Missing pack Include: added above the first Host, below an earlier Include.
# The comment directly above the first Host stays with it.
printf '# other comment\n%s\n\n# keepalive\nHost *\n  TCPKeepAlive yes\n' "$OTHER" >"$f"
assert_status 0 "missing: reports a change" -- ssh_top_include "$f" "$PACK" "# pack comment"
assert_eq yes "$([ "$(line_of "$OTHER")" -lt "$(line_of "$PACK")" ] && [ "$(line_of "$PACK")" -lt "$(first_block)" ] && echo yes || echo no)" "missing: other < pack < first Host"
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


# The old agent Include (~/.ssh/agent_config) is removed with its comment
# lines and the blank line after it. The hosts now come from config.d/00-machine.
OLD="Include ~/.ssh/agent_config"
printf '%s\n%s\n%s\n\n%s\n%s\n\nHost *\n  TCPKeepAlive yes\n' \
  "# Hosts on the per-machine agent key. Keep this above every Host block: ssh" \
  "# keeps the first value it reads, so it wins over a later IdentityAgent." \
  "$OLD" "# pack comment" "$PACK" >"$f"
assert_status 0 "old agent Include: reports a change" -- ssh_drop_include "$f" "$OLD"
assert_eq "# pack comment
$PACK

Host *
  TCPKeepAlive yes" "$(cat "$f")" "old agent Include: removed with its comment and blank line"
assert_status 1 "old agent Include: second run reports no change" -- ssh_drop_include "$f" "$OLD"

# The repo side: the machine key hosts live in config.d/00-machine, the old file is
# removed, and nothing writes the old Include any more.
SRC="$REPO/home"
assert_eq yes "$([ -f "$SRC/private_dot_ssh/private_config.d/private_00-machine.tmpl" ] && [ ! -e "$SRC/private_dot_ssh/private_agent_config.tmpl" ] && echo yes || echo no)" "machine key hosts are in config.d/00-machine"
for old in .ssh/agent_config .ssh/id_agent .ssh/id_agent.pub; do
  assert_eq 1 "$(grep -cxF "$old" "$SRC/.chezmoiremove")" ".chezmoiremove removes ~/$old"
done
assert_eq "" "$(grep -rlE 'id_agent|agent-key-item|op://Agent/' "$SRC" | grep -v '\.chezmoiremove$')" "no template uses the old agent key names"
assert_eq 0 "$(grep -c 'agent_config' "$SRC/dot_config/etc/private_ssh_config.template.tmpl")" "the SSH template has no agent_config Include"

# ssh reads the config.d files in name order and keeps the first value, so
# 00-machine wins over a pack file that names the same host.
d="$TMP/ssh.d"; mkdir -p "$d"
printf 'Host x\n  User machine\n' >"$d/00-machine"
printf 'Host x\n  User pack\n' >"$d/pack"
printf 'Include %s/*\n' "$d" >"$TMP/ssh_config"
assert_eq "user machine" "$(ssh -G -F "$TMP/ssh_config" x 2>/dev/null | grep '^user ')" "ssh: 00-machine wins over a pack file"


# ssh_replace_line: an exact old comment line is replaced; nothing else changes.
printf '# old text\n%s\n# old text here too\n' "$PACK" >"$f"
assert_status 0 "replace: reports a change" -- ssh_replace_line "$f" "# old text" "# new text"
assert_eq "# new text
$PACK
# old text here too" "$(cat "$f")" "replace: only the exact line changes"
assert_status 1 "replace: second run reports no change" -- ssh_replace_line "$f" "# old text" "# new text"

finish
