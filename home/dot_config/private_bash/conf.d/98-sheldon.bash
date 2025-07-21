#!/usr/bin/env bash

export SHELDON_CONFIG_DIR="${DOTFILES_DIR}/etc/sheldon"
export SHELDON_DATA_DIR="${SHELDON_CONFIG_DIR}"

# Sheldon
if [[ ! "$(command -v sheldon)" ]]; then
  print -P "%F{33}▓▒░ %F{220}Installing sheldon…%f"
  command curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin &&
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f" ||
    print -P "%F{160}▓▒░ The clone has failed.%f"
fi
eval "$(sheldon source)"

# Prompt Theme
# Don't load starship if DISABLE_STARSHIP is 1
if [[ "$DISABLE_STARSHIP" != "1" ]]; then
    if [[ ! "$(command -v starship)" ]]; then
      print -P "%F{33}▓▒░ %F{220}Installing starship…%f"
      curl -sS https://starship.rs/install.sh | sh
    fi
    if command -v starship >/dev/null 2>&1; then
        eval "$(starship init bash)"
    fi
fi

# plugins additional configs

# laggardkernel/git-ignore plugin
# alias gi="git-ignore"

##############################
# update plugin manager alias
##############################
alias upzshplugin="sheldon lock --update"
