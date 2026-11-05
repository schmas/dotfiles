#!/usr/bin/env bash
# Tests for the post-start "drop-ins" hook in home/dot_config/worktrunk/config.toml:
# it runs every executable in ~/.config/worktrunk/post-start.d/ with
# <primary_worktree> <worktree>, and fails if one of them fails.
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$TESTS_DIR/.." && pwd)"
# shellcheck source=SCRIPTDIR/lib/assert.sh
. "$TESTS_DIR/lib/assert.sh"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/wt-drop-ins.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

# The hook command, with the worktrunk placeholders filled in.
python3 -I -c '
import sys, tomllib
cmd = tomllib.load(open(sys.argv[1], "rb"))["post-start"]["drop-ins"]
cmd = cmd.replace("{{ primary_worktree_path }}", "/primary").replace("{{ worktree_path }}", "/wt")
print(cmd)
' "$REPO/home/dot_config/worktrunk/config.toml" >"$TMP/hook.sh"

d="$TMP/home/.config/worktrunk/post-start.d"
mkdir -p "$d"
run_hook() { HOME="$TMP/home" sh "$TMP/hook.sh" 2>"$TMP/err"; }

# No drop-ins: success.
assert_status 0 "no drop-ins: exit 0" -- run_hook

# shellcheck disable=SC2016 # expands in the child shell
printf '#!/bin/sh\necho "$1 $2" >>"%s/ran"\n' "$TMP" >"$d/a-ok"
printf '#!/bin/sh\nexit 3\n' >"$d/b-fail"
printf '#!/bin/sh\necho c >>"%s/ran"\n' "$TMP" >"$d/c-ok"
printf 'not executable\n' >"$d/d-plain"
chmod +x "$d/a-ok" "$d/b-fail" "$d/c-ok"

code=0; run_hook || code=$?
assert_eq 1 "$code" "a failing drop-in fails the hook"
assert_contains "$(cat "$TMP/err")" "b-fail" "the failing drop-in is named"
assert_eq "/primary /wt
c" "$(cat "$TMP/ran")" "every drop-in runs, with <primary> <worktree>"

rm "$d/b-fail" "$TMP/ran"
assert_status 0 "all drop-ins pass: exit 0" -- run_hook

finish
