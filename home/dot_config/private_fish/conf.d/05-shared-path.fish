# Load all .path files from ~/.config/path/
# Guard: only run if the dir exists (expected on fresh installs before chezmoi apply)
if test -d $HOME/.config/path
    for f in $HOME/.config/path/*.path
        source_path_file $f
    end
end
