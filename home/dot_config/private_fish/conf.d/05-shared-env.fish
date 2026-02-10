# Source all POSIX .env files from ~/.config/env/
for f in $HOME/.config/env/*.env
    source_posix_env $f
end
