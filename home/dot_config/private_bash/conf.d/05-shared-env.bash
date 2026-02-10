#!/usr/bin/env bash
# Source all POSIX .env files from ~/.config/env/
set -a
for f in "$HOME"/.config/env/*.env; do [ -f "$f" ] && . "$f"; done
set +a
