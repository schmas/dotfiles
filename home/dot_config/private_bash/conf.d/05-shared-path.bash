#!/usr/bin/env bash
# Load all .path files from ~/.config/path/

_source_path_file() {
    local file="$1"
    [ -f "$file" ] || return 1
    local line dir token check do_glob do_append
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*(#|$) ]] && continue

        check=0; do_glob=0; do_append=0; dir=""
        for token in $line; do
            case "$token" in
                --check)  check=1 ;;
                --glob)   do_glob=1 ;;
                --append) do_append=1 ;;
                *)
                    dir="${token//\"/}"
                    dir="${dir//\'/}"
                    dir="${dir//\$HOME/$HOME}"
                    ;;
            esac
        done

        [ -z "$dir" ] && continue
        [ "$check" -eq 1 ] && [ ! -d "$dir" ] && continue

        if [ "$do_glob" -eq 1 ]; then
            if [ "$do_append" -eq 1 ]; then
                PATH="$PATH:$dir"
                for d in "$dir"/*/; do [ -d "$d" ] && PATH="$PATH:$d"; done
            else
                for d in "$dir"/*/; do [ -d "$d" ] && PATH="$d:$PATH"; done
                PATH="$dir:$PATH"
            fi
        else
            if [ "$do_append" -eq 1 ]; then
                PATH="$PATH:$dir"
            else
                PATH="$dir:$PATH"
            fi
        fi
    done < "$file"
}

for f in "$HOME"/.config/path/*.path; do
    [ -f "$f" ] && _source_path_file "$f"
done
unset -f _source_path_file

# Deduplicate PATH (preserve order, keep first occurrence)
PATH=$(printf '%s' "$PATH" | awk -v RS=: -v ORS=: '!seen[$0]++' | sed 's/:$//')
export PATH
