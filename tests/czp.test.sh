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

finish
