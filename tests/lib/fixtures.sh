# shellcheck shell=bash
# Fixtures for the czp tests: a throw-away HOME with a public chezmoi source
# and optional packs. HOME has a space in its path on purpose.

# Never touch the real XDG directories from a test.
unset XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME XDG_STATE_HOME XDG_BIN_HOME XDG_RUNTIME_DIR

_FIXTURE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/czp-test.XXXXXX")"
trap 'rm -rf "$_FIXTURE_ROOT"' EXIT
_FIXTURE_N=0

# make_home: new empty HOME with a public source and its config.
make_home() {
  _FIXTURE_N=$((_FIXTURE_N + 1))
  export HOME="$_FIXTURE_ROOT/home $_FIXTURE_N"
  mkdir -p "$HOME/.local/share/chezmoi" "$HOME/.config/chezmoi"
  printf 'sourceDir: "%s"\n' "$HOME/.local/share/chezmoi" >"$HOME/.config/chezmoi/chezmoi.yaml"
}

# add_public <file>...: the public instance manages ~/.<file> ("hello").
add_public() {
  local f
  for f in "$@"; do printf 'hello\n' >"$HOME/.local/share/chezmoi/dot_$f"; done
}

# make_pack <name> <file>...: an installed pack that manages ~/.<file> ("hello").
make_pack() {
  local name="$1" f
  shift
  local src="$HOME/.local/share/chezmoi-$name" cfg="$HOME/.config/chezmoi-$name"
  mkdir -p "$src" "$cfg"
  for f in "$@"; do printf 'hello\n' >"$src/dot_$f"; done
  printf 'sourceDir = "%s"\n' "$src" >"$cfg/chezmoi.toml"
}

# break_pack <name>: add a template that fails to execute.
break_pack() {
  printf '{{ .nope.nope }}\n' >"$HOME/.local/share/chezmoi-$1/dot_broken.tmpl"
}

# make_remote_pack <name> <file>...: a bare git repo "dotfiles-<name>"; prints its file:// URL.
make_remote_pack() {
  local name="$1" f
  shift
  local work="$_FIXTURE_ROOT/work-$name-$_FIXTURE_N" bare="$_FIXTURE_ROOT/remote $_FIXTURE_N/dotfiles-$name.git"
  mkdir -p "$work" "${bare%/*}"
  for f in "$@"; do printf 'hello\n' >"$work/dot_$f"; done
  git -C "$work" init -q -b main
  git -C "$work" add -A
  git -C "$work" -c user.name=t -c user.email=t@t -c commit.gpgsign=false commit -q -m init
  git clone -q --bare "$work" "$bare"
  printf 'file://%s\n' "$bare"
}

# fake_op signed-in|signed-out: put a fake `op` first in PATH.
fake_op() {
  local bin="$_FIXTURE_ROOT/bin-$_FIXTURE_N"
  mkdir -p "$bin"
  if [ "$1" = signed-in ]; then
    printf '#!/bin/sh\necho "URL: my.1password.com"\nexit 0\n' >"$bin/op"
  else
    printf '#!/bin/sh\necho "[ERROR] account is not signed in" >&2\nexit 1\n' >"$bin/op"
  fi
  chmod +x "$bin/op"
  case ":$PATH:" in *":$bin:"*) ;; *) export PATH="$bin:$PATH" ;; esac
}

# git_public: make the public source a clone of a bare repo, so `chezmoi update` can pull.
git_public() {
  local src="$HOME/.local/share/chezmoi" bare="$_FIXTURE_ROOT/remote $_FIXTURE_N/public.git"
  mkdir -p "${bare%/*}"
  git -C "$src" init -q -b main
  git -C "$src" add -A
  git -C "$src" -c user.name=t -c user.email=t@t -c commit.gpgsign=false commit -q --allow-empty -m init
  git clone -q --bare "$src" "$bare"
  git -C "$src" remote add origin "file://$bare"
  git -C "$src" fetch -q origin
  git -C "$src" branch -q -u origin/main
}

# push_to_pack <repo-url> <file> <content>: commit ~/.<file> to the pack's remote.
push_to_pack() {
  local work="$_FIXTURE_ROOT/push-$_FIXTURE_N"
  rm -rf "$work"
  git clone -q "$1" "$work"
  printf '%s\n' "$3" >"$work/dot_$2"
  git -C "$work" add -A
  git -C "$work" -c user.name=t -c user.email=t@t -c commit.gpgsign=false commit -q -m "add $2"
  git -C "$work" push -q origin HEAD
}
