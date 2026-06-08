#!/usr/bin/env bash
# Manually sync the bootstrap scripts to the public gist
# Gist: https://gist.github.com/schmas/a604b0d433a836c5af8a877a3d0f37df

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIST_ID="a604b0d433a836c5af8a877a3d0f37df"

for name in bootstrap-chezmoi.sh bootstrap-wsl.sh; do
  file="$SCRIPT_DIR/$name"
  if [[ ! -f "$file" ]]; then
    echo "Error: $name not found at $file"
    exit 1
  fi
  echo "Syncing $name to gist..."
  gh gist edit "$GIST_ID" --filename "$name" "$file"
done

echo "Done: https://gist.github.com/schmas/$GIST_ID"
