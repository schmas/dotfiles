# Google Workspace CLI multi-account profiles
gws-personal() { GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/personal" command gws "$@"; }
gws-marcelle() { GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/marcelle" command gws "$@"; }
