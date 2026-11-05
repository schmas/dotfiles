# shellcheck shell=bash
# Minimal assert helpers for the plain-bash tests in tests/.
# Each assert prints "ok" or "FAIL" with its label; finish exits 1 if any failed.

_ASSERT_FAILED=0
_ASSERT_COUNT=0

_assert_pass() { _ASSERT_COUNT=$((_ASSERT_COUNT + 1)); printf 'ok   %s\n' "$1"; }
_assert_fail() {
  _ASSERT_COUNT=$((_ASSERT_COUNT + 1))
  _ASSERT_FAILED=$((_ASSERT_FAILED + 1))
  printf 'FAIL %s\n' "$1"
  shift
  [ $# -gt 0 ] && printf '     %s\n' "$@"
  return 0
}

# assert_eq <expected> <actual> <label>
assert_eq() {
  if [ "$1" = "$2" ]; then
    _assert_pass "$3"
  else
    _assert_fail "$3" "expected: [$1]" "actual:   [$2]"
  fi
}

# assert_contains <haystack> <needle> <label>
assert_contains() {
  case "$1" in
    *"$2"*) _assert_pass "$3" ;;
    *) _assert_fail "$3" "missing: [$2]" "in:      [$1]" ;;
  esac
}

# assert_status <expected-code> <label> -- <cmd...>
assert_status() {
  local expected="$1" label="$2" code=0
  shift 2
  [ "${1:-}" = "--" ] && shift
  "$@" >/dev/null 2>&1 || code=$?
  if [ "$code" = "$expected" ]; then
    _assert_pass "$label"
  else
    _assert_fail "$label" "expected exit $expected, got $code: $*"
  fi
}

# fail <label>
fail() { _assert_fail "$1"; }

finish() {
  printf '%d asserts, %d failed\n' "$_ASSERT_COUNT" "$_ASSERT_FAILED"
  [ "$_ASSERT_FAILED" -eq 0 ] || exit 1
  exit 0
}
