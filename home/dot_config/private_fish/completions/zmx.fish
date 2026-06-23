# zmx ships its own fish completions; source them dynamically so they always
# match the installed version (completes subcommands + live session names).
# Ref: https://zmx.sh/#fish-1
if type -q zmx
    zmx completions fish | source
end
