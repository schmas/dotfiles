#!/usr/bin/env bash
# Manually sync bootstrap-chezmoi.sh to public gist
# Gist: https://gist.github.com/schmas/a604b0d433a836c5af8a877a3d0f37df

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_FILE="$SCRIPT_DIR/bootstrap-chezmoi.sh"
GIST_ID="a604b0d433a836c5af8a877a3d0f37df"

if [[ ! -f "$BOOTSTRAP_FILE" ]]; then
  echo "Error: bootstrap-chezmoi.sh not found at $BOOTSTRAP_FILE"
  exit 1
fi

echo "Syncing bootstrap-chezmoi.sh to gist..."
gh gist edit "$GIST_ID" --filename bootstrap-chezmoi.sh "$BOOTSTRAP_FILE"
echo "Done: https://gist.github.com/schmas/$GIST_ID"
