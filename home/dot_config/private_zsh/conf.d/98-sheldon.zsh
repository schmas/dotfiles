#!/usr/bin/env zsh

export SHELDON_CONFIG_DIR="${DOTFILES_DIR}/etc/sheldon"
export SHELDON_DATA_DIR="${SHELDON_CONFIG_DIR}"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Sheldon
if [[ ! "$(command -v sheldon)" ]]; then
  print -P "%F{33}▓▒░ %F{220}Installing sheldon…%f"
  command curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin &&
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f" ||
    print -P "%F{160}▓▒░ The clone has failed.%f"
fi
eval "$(sheldon source)"

# Prompt Theme
if [[ ! "$(command -v starship)" ]]; then
  print -P "%F{33}▓▒░ %F{220}Installing starship…%f"
  curl -sS https://starship.rs/install.sh | sh
fi
eval "$(starship init zsh)"

# plugins additional configs

# laggardkernel/git-ignore plugin
alias gi="git-ignore"

# fzf
# $(brew --prefix)/opt/fzf/install

# hlissner/zsh-autopair
bindkey "^H" backward-kill-word

# zsh-users/zsh-autosuggestions
bindkey "^f" vi-forward-word
bindkey "^e" end-of-line

# zsh-users/zsh-history-substring-search
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

##############################
# update plugin manager alias
##############################
alias upzshplugin="sheldon lock --update"
