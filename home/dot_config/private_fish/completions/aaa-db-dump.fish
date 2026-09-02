# aaa-db-dump completions for fish
# Regenerate with: aaa-db-dump completion fish

set -l __add_stages dump fetch push restore clean run status list completion
set -l __add_takes_alias dump fetch push restore clean run status

complete -c aaa-db-dump -f
complete -c aaa-db-dump -n "not __fish_seen_subcommand_from $__add_stages" \
    -a "$__add_stages"
complete -c aaa-db-dump -n "__fish_seen_subcommand_from $__add_takes_alias" \
    -a "(aaa-db-dump list --aliases-only)" -d "source alias"
complete -c aaa-db-dump -n "__fish_seen_subcommand_from completion" \
    -a "fish bash zsh" -d shell
complete -c aaa-db-dump -l to -x -a "(aaa-db-dump list --targets-only)" \
    -d "restore destination"
complete -c aaa-db-dump -l db -x -d "database name inside the destination"
complete -c aaa-db-dump -l redo -x -a "dump fetch push restore clean"
complete -c aaa-db-dump -l stop-after -x -a "dump fetch push restore clean"
complete -c aaa-db-dump -l dry-run -d "print commands, execute nothing"
complete -c aaa-db-dump -l yes -d "confirm a destructive restore"
complete -c aaa-db-dump -l follow -d "tail progress"
complete -c aaa-db-dump -l no-follow -d "do not tail"
complete -c aaa-db-dump -l force-dump -d "dump despite a running pg_dump"
complete -c aaa-db-dump -l force-clean -d "clean despite a failed restore"
complete -c aaa-db-dump -n "__fish_seen_subcommand_from list" \
    -l aliases-only -l targets-only
