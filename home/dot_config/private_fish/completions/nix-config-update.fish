# Completions for nix-config-update
complete -c nix-config-update -f # -f means it's not a file completion

# Show these options with just tab or after typing part of the option
complete -c nix-config-update -n "not __fish_seen_subcommand_from --help -h --test" -a --help -d "Show help message"
complete -c nix-config-update -n "not __fish_seen_subcommand_from --help -h --test" -a -h -d "Show help message"
complete -c nix-config-update -n "not __fish_seen_subcommand_from --help -h --test" -a --test -d "Use test configuration"
