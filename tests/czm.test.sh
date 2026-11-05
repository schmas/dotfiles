#!/usr/bin/env bash
# Tests for home/bin/executable_czm.
. "$(dirname "$0")/lib/assert.sh"
CZM="$(dirname "$0")/../home/bin/executable_czm"
assert_eq "$(chezmoi --version)" "$("$CZM" --version 2>&1)" "czm passes args to chezmoi"
finish
