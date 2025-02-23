#!/usr/bin/env bash

# source all files in the completions directory and its subdirectories
while read -d $'\0' file; do
    source "$file"
done < <(find ${DOTFILES_DIR}/completions -type f -not -path '*/\.*' -print0)
