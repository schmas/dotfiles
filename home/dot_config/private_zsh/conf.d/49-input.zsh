#!/usr/bin/env zsh

#########################
#         Other         #
#########################
bindkey -e                  # EMACS bindings
setopt no_beep              # don't beep on error
setopt auto_cd              # If you type foo, and it isn't a command, and it is a directory in your cdpath, go there
setopt multios              # perform implicit tees or cats when multiple redirections are attempted
setopt prompt_subst         # enable parameter expansion, command substitution, and arithmetic expansion in the prompt
setopt interactive_comments # Allow comments even in interactive shells (especially for Muness)
setopt pushd_ignore_dups    # don't push multiple copies of the same directory onto the directory stack
setopt auto_pushd           # make cd push the old directory onto the directory stack
setopt pushdminus           # swapped the meaning of cd +1 and cd -1; we want them to mean the opposite of what they mean

## History command configuration
setopt append_history       # Allow multiple terminal sessions to all append to one zsh command history
setopt hist_ignore_all_dups # delete old recorded entry if new entry is a duplicate.
setopt share_history

# Turn off all beeps
# unsetopt BEEP

# Turn off autocomplete beeps
# unsetopt LIST_BEEP

# Disabling Autocorrect in Zsh
# unsetopt correct_all
