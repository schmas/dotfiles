# czp: chezmoi on the public dotfiles and every installed pack.
complete -c czp -f
complete -c czp -n __fish_use_subcommand -a install -d 'Clone a pack, check overlaps, apply'
complete -c czp -n __fish_use_subcommand -a list -d 'List the installed packs'
complete -c czp -n __fish_use_subcommand -a check -d 'Fail if two instances manage the same target'
complete -c czp -n __fish_use_subcommand -a update -d 'chezmoi update on every instance'
complete -c czp -n __fish_use_subcommand -a apply -d 'chezmoi apply on every instance'
complete -c czp -n __fish_use_subcommand -a diff -d 'chezmoi diff on every instance'
complete -c czp -n __fish_use_subcommand -a status -d 'chezmoi status on every instance'
complete -c czp -n '__fish_seen_subcommand_from install' -l no-apply -d 'Clone and check, do not apply'
complete -c czp -n '__fish_seen_subcommand_from list' -l names -d 'Print pack names only'
