function source_path_file --description "Load a .path file into fish PATH"
    test -f $argv[1]; or return 1
    while read -l line
        # Skip comments and empty lines
        string match -qr '^\s*(#|$)' -- $line; and continue

        # Parse flags and path (path may be quoted and contain spaces)
        set -l check 0
        set -l do_glob 0
        set -l do_append 0
        set -l dir ""

        set -l line (string trim -- $line)
        if string match -qr '^"' -- $line
            set -l parts (string split '"' -- $line)
            set dir $parts[2]
            set line (string trim (string join '"' $parts[3..-1]))
        else if string match -qr "^'" -- $line
            set -l parts (string split "'" -- $line)
            set dir $parts[2]
            set line (string trim (string join "'" $parts[3..-1]))
        else
            set -l parts (string split -m 1 ' ' -- $line)
            set dir $parts[1]
            if test (count $parts) -ge 2
                set line (string trim -- $parts[2])
            else
                set line ""
            end
        end
        set dir (string replace -a '$HOME' "$HOME" -- $dir)

        for token in (string split ' ' -- $line)
            test -n "$token"; or continue
            switch $token
                case '--check'
                    set check 1
                case '--glob'
                    set do_glob 1
                case '--append'
                    set do_append 1
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
