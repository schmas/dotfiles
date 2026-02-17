function source_path_file --description "Load a .path file into fish PATH"
    test -f $argv[1]; or return 1
    while read -l line
        # Skip comments and empty lines
        string match -qr '^\s*(#|$)' -- $line; and continue

        # Parse flags
        set -l check 0
        set -l do_glob 0
        set -l do_append 0
        set -l dir ""

        for token in (string split ' ' -- $line)
            switch $token
                case '--check'
                    set check 1
                case '--glob'
                    set do_glob 1
                case '--append'
                    set do_append 1
                case '*'
                    # Path token — strip quotes, expand $HOME
                    set dir (string replace -r '^["\'](.*)["\']$' '$1' -- $token)
                    set dir (string replace -a '$HOME' "$HOME" -- $dir)
            end
        end

        test -n "$dir"; or continue

        # --check: skip if dir doesn't exist
        if test $check -eq 1 -a ! -d "$dir"
            continue
        end

        # Build list of dirs to add
        set -l dirs $dir
        if test $do_glob -eq 1
            for subdir in $dir/*/
                set -a dirs $subdir
            end
        end

        # Add to PATH
        if test $do_append -eq 1
            fish_add_path --global --append $dirs
        else
            fish_add_path --global $dirs
        end
    end < $argv[1]
end
