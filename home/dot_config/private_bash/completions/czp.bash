# shellcheck shell=bash
# czp: chezmoi on the public dotfiles and every installed pack.
# The words have no spaces, so the unquoted compgen output is safe (bash 3.2).
# shellcheck disable=SC2207
_czp() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=($(compgen -W "install list check update apply diff status" -- "$cur"))
    return
  fi
  case "${COMP_WORDS[1]}" in
    install) COMPREPLY=($(compgen -W "--no-apply" -- "$cur")) ;;
    list) COMPREPLY=($(compgen -W "--names" -- "$cur")) ;;
  esac
}
complete -F _czp czp
