#!/usr/bin/env bash
# Tests for home/bin/executable_czp. Plain bash; run: bash tests/czp.test.sh
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=SCRIPTDIR/lib/assert.sh
. "$TESTS_DIR/lib/assert.sh"
# shellcheck source=SCRIPTDIR/lib/fixtures.sh
. "$TESTS_DIR/lib/fixtures.sh"
CZP="$TESTS_DIR/../home/bin/executable_czp"
# CZP_BASH=/bin/bash runs czp with another bash (for example macOS bash 3.2).
czp() { "${CZP_BASH:-bash}" "$CZP" "$@"; }

# --- list / check -----------------------------------------------------------

make_home
assert_eq "" "$(czp list --names)" "list: no packs"

make_home; make_pack a x; mkdir -p "$HOME/.config/chezmoi-b"
assert_eq "a" "$(czp list --names)" "list: ignores a pack dir without chezmoi.toml"

make_home; make_pack b x; make_pack a y
assert_eq "a b" "$(czp list --names | paste -sd' ' -)" "list: name order"

make_home; make_pack a x; printf 'command=czm-aa\n' >"$HOME/.local/share/chezmoi-a/.czp"; make_pack b y
out="$(czp list)"
assert_contains "$out" "czm-aa" "list: shows the command from .czp"
assert_contains "$out" "$HOME/.local/share/chezmoi-a" "list: shows the source path"

make_home
assert_status 0 "check: no packs is ok" -- czp check
assert_contains "$(czp check)" "no overlaps (1 instances)" "check: ok message"

make_home; make_pack a x; add_public y
assert_status 0 "check: no overlap" -- czp check

make_home; make_pack a x; add_public x
out="$(czp check)"
assert_status 1 "check: overlap exits 1" -- czp check
assert_contains "$out" "/.x: main a" "check: names both instances"

make_home; make_pack a x y; make_pack b x; add_public z
out="$(czp check)"
assert_contains "$out" "/.x: a b" "check: overlap between two packs"

assert_status 2 "unknown subcommand exits 2" -- czp nope

# --- fan-out: update / apply / diff / status --------------------------------

make_home; make_pack b x; make_pack a y
out="$(czp apply 2>&1)"
assert_eq "== main ==|== a ==|== b ==" "$(grep '^==' <<<"$out" | paste -sd'|' -)" "apply: main first, then packs in name order"
assert_eq "hello" "$(cat "$HOME/.x" 2>/dev/null)" "apply: writes pack b's target"
assert_eq "hello" "$(cat "$HOME/.y" 2>/dev/null)" "apply: writes pack a's target"

make_home; make_pack a x; make_pack b y; break_pack a
code=0; out="$(czp apply 2>&1)" || code=$?
assert_eq 1 "$code" "apply: one failed instance exits 1"
assert_contains "$out" "czp: failed: a" "apply: names the failed instance"
assert_eq "hello" "$(cat "$HOME/.y" 2>/dev/null)" "apply: b still applied after a failed"

make_home; make_pack a x; add_public x
assert_status 1 "apply: blocked by an overlap" -- czp apply
assert_eq "no" "$([ -e "$HOME/.x" ] && echo yes || echo no)" "apply: nothing applied on an overlap"
assert_status 1 "update: blocked by an overlap" -- czp update

make_home
assert_status 0 "diff: no packs is ok" -- czp diff
assert_status 0 "status: no packs is ok" -- czp status
make_home; make_pack a x
assert_contains "$(czp diff 2>&1)" "== a ==" "diff: runs on the pack"
assert_contains "$(czp status 2>&1)" ".x" "status: shows the pack's pending target"

finish
