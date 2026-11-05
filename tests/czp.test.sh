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

# --- install ----------------------------------------------------------------

assert_eq foo "$(czp _name git@github.com:someone/dotfiles-foo.git)" "name: ssh URL"
assert_eq bar "$(czp _name https://github.com/someone/dotfiles-bar)" "name: https URL without .git"
assert_eq demo "$(czp _name "file:///some path/dotfiles-demo.git/")" "name: file URL with a trailing slash"
assert_status 1 "name: rejects main" -- czp _name git@github.com:me/dotfiles-main.git

make_home; repo="$(make_remote_pack demo x)"; fake_op signed-in
czp install "$repo" >/dev/null 2>&1
assert_eq "hello" "$(cat "$HOME/.x" 2>/dev/null)" "install: applies the pack"
assert_eq demo "$(czp list --names)" "install: pack is listed"
cfg="$HOME/.config/chezmoi-demo/chezmoi.toml"
assert_contains "$(cat "$cfg" 2>/dev/null)" "sourceDir = \"$HOME/.local/share/chezmoi-demo\"" "install: config has sourceDir"
assert_contains "$(cat "$cfg" 2>/dev/null)" "persistentState = \"$HOME/.config/chezmoi-demo/chezmoistate.boltdb\"" "install: config has its own state file"
assert_eq yes "$([ -f "$HOME/.config/chezmoi-demo/chezmoistate.boltdb" ] && echo yes || echo no)" "install: state file is in the pack config dir"
assert_status 1 "install: stops if the pack exists" -- czp install "$repo"

make_home; repo="$(make_remote_pack demo x)"; fake_op signed-in
czp install --no-apply "$repo" >/dev/null 2>&1
assert_eq no "$([ -e "$HOME/.x" ] && echo yes || echo no)" "install --no-apply: nothing applied"
assert_eq demo "$(czp list --names)" "install --no-apply: pack is installed"

make_home; repo="$(make_remote_pack demo x)"; fake_op signed-out
assert_status 1 "install: stops when op is signed out" -- czp install "$repo"
assert_eq no "$([ -d "$HOME/.local/share/chezmoi-demo" ] && echo yes || echo no)" "install: nothing cloned when op is signed out"
assert_contains "$(czp install "$repo" 2>&1)" "op signin" "install: says how to sign in"

make_home; fake_op signed-in
assert_status 1 "install: stops on an unreachable URL" -- czp install "file:///nope/dotfiles-nope.git"
assert_eq no "$([ -d "$HOME/.local/share/chezmoi-nope" ] && echo yes || echo no)" "install: nothing cloned for an unreachable URL"

make_home; repo="$(make_remote_pack demo x)"; fake_op signed-in; add_public x
assert_status 1 "install: stops on an overlap" -- czp install "$repo"
assert_eq no "$([ -e "$HOME/.x" ] && echo yes || echo no)" "install: nothing applied on an overlap"
assert_eq demo "$(czp list --names)" "install: pack stays cloned for inspection"

make_home; repo="$(make_remote_pack demo x)"; fake_op signed-in; add_public x
code=0; out="$(czp install --no-apply "$repo" 2>&1)" || code=$?
assert_eq 0 "$code" "install --no-apply: overlap is reported, exit 0"
assert_contains "$out" "/.x: main demo" "install --no-apply: prints the overlap"

make_home; repo="$(make_remote_pack demo x)"; fake_op signed-in
printf 'onepassword:\n  command: "%s"\n' "$HOME/bin/op" >>"$HOME/.config/chezmoi/chezmoi.yaml"
czp install --no-apply "$repo" >/dev/null 2>&1
assert_contains "$(cat "$HOME/.config/chezmoi-demo/chezmoi.toml" 2>/dev/null)" "command = \"$HOME/bin/op\"" "install: copies onepassword.command from the main config"

make_home; repo="$(make_remote_pack demo x)"; fake_op signed-in
czp install --no-apply "$repo" >/dev/null 2>&1
assert_eq 0 "$(grep -c onepassword "$HOME/.config/chezmoi-demo/chezmoi.toml")" "install: no onepassword section for the default op"

make_home; repo="$(make_remote_pack demo x)"; fake_op signed-in
printf 'onepassword:\n  command: "%s"\n  prompt: false\n' "$HOME/bin/op" >>"$HOME/.config/chezmoi/chezmoi.yaml"
czp install --no-apply "$repo" >/dev/null 2>&1
assert_contains "$(cat "$HOME/.config/chezmoi-demo/chezmoi.toml" 2>/dev/null)" "prompt = false" "install: copies onepassword.prompt = false from the main config"
assert_eq yes "$(chezmoi --config "$HOME/.config/chezmoi-demo/chezmoi.toml" execute-template '{{ .chezmoi.config.onepassword.prompt }}' 2>/dev/null | grep -qx false && echo yes || echo no)" "install: the pack config parses with prompt = false"

# --- update: overlap that arrives with the pull ------------------------------

make_home; add_public y; git_public; repo="$(make_remote_pack demo x)"; fake_op signed-in
czp install "$repo" >/dev/null 2>&1
push_to_pack "$repo" y pack
code=0; out="$(czp update 2>&1)" || code=$?
assert_eq 1 "$code" "update: an overlap pulled from upstream exits 1"
assert_contains "$out" "/.y: main demo" "update: prints the pulled overlap"
assert_eq no "$([ "$(cat "$HOME/.y" 2>/dev/null)" = pack ] && echo yes || echo no)" "update: pack does not overwrite the public target"

make_home; git_public
assert_status 0 "update: no packs updates main only" -- czp update

finish
