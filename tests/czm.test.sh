#!/usr/bin/env bash
# Tests for home/bin/executable_czm.
# shellcheck source=SCRIPTDIR/lib/assert.sh
. "$(dirname "$0")/lib/assert.sh"
CZM="$(dirname "$0")/../home/bin/executable_czm"
assert_eq "$(chezmoi --version)" "$("$CZM" --version 2>&1)" "czm passes args to chezmoi"
COMP="$(dirname "$0")/../home/dot_config/private_bash/completions/czm.bash"
for sh in /bin/bash bash; do
  # shellcheck disable=SC2016 # expands in the child shell
  v="$("$sh" -c 'echo ${BASH_VERSINFO[0]}')"
  assert_eq "complete -o default -F __start_chezmoi czm" \
    "$("$sh" --norc -c ". '$COMP'; declare -F __start_chezmoi >/dev/null && complete -p czm")" \
    "bash $v: czm completion loads chezmoi's completion"
done
finish
