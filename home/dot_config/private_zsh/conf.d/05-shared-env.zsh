#!/usr/bin/env zsh
# Source all POSIX .env files from ~/.config/env/
set -a
for f in "$HOME"/.config/env/*.env(N); do . "$f"; done
set +a
