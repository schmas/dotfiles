# Load all .path files from ~/.config/path/
for f in $HOME/.config/path/*.path
    source_path_file $f
end
