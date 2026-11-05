# shellcheck shell=bash
# czm wraps chezmoi; reuse chezmoi's completion (it calls `czm __complete`).
if command -v chezmoi >/dev/null 2>&1; then
  declare -F __start_chezmoi >/dev/null || source <(chezmoi completion bash)
  complete -o default -F __start_chezmoi czm
fi
