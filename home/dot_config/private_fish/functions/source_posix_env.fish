function source_posix_env --description "Source a POSIX KEY=VALUE .env file into fish environment"
    test -f $argv[1]; or return 1
    while read -l line
        string match -qr '^\s*(#|$)' -- $line; and continue
        set -l kv (string match -r '^([A-Za-z_]\w*)=(.*)$' -- $line)
        test (count $kv) -ge 3; or continue
        set -l val (string replace -r '^["\'](.*)["\']$' '$1' -- $kv[3])
        set -l val (string replace -a '$HOME' "$HOME" -- $val)
        set -gx $kv[2] $val
    end < $argv[1]
end
