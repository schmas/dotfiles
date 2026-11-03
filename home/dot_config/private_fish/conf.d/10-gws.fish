# Google Workspace CLI multi-account profiles
function gws-personal --wraps gws --description 'Run gws with personal account profile'
    env GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/personal" gws $argv
end

function gws-marcelle --wraps gws --description 'Run gws with marcelle account profile'
    env GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/marcelle" gws $argv
end
