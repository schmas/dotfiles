#!/usr/bin/env zsh
# Load all .path files from ~/.config/path/

_source_path_file() {
    local file="$1"
    [ -f "$file" ] || return 1
    local line dir token check do_glob do_append
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*(#|$) ]] && continue

        check=0; do_glob=0; do_append=0; dir=""
        for token in ${=line}; do
            case "$token" in
                --check)  check=1 ;;
                --glob)   do_glob=1 ;;
                --append) do_append=1 ;;
                *)
                    dir="${token//\"/}"    # Strip double quotes
                    dir="${dir//\'/}"      # Strip single quotes
                    dir="${dir//\$HOME/$HOME}"  # Expand $HOME
                    ;;
            esac
        done

        [ -z "$dir" ] && continue
        [ "$check" -eq 1 ] && [ ! -d "$dir" ] && continue

        if [ "$do_glob" -eq 1 ]; then
            if [ "$do_append" -eq 1 ]; then
                path+=("$dir")
                for d in "$dir"/*(/-N); do path+=("$d"); done
            else
                for d in "$dir"/*(/-N); do path=("$d" $path); done
                path=("$dir" $path)
            fi
        else
            if [ "$do_append" -eq 1 ]; then
                path+=("$dir")
            else
                path=("$dir" $path)
            fi
        fi
    done < "$file"
}

for f in "$HOME"/.config/path/*.path(N); do
    _source_path_file "$f"
done
unfunction _source_path_file
