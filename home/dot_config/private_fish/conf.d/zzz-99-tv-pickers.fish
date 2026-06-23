if status is-interactive; and command -q tv
    # tv-powered pickers. Bound in conf.d (not fish_user_key_bindings) so they
    # register reliably alongside the other plugin bindings (fzf.fish, atuin).
    #   Ctrl+Alt+Z  zmx session picker (attach / kill / preview scrollback)
    #   Ctrl+Alt+E  command picker (search PATH executables, insert at cursor)
    #   Ctrl+Alt+B  git branch picker (insert at cursor; replaces fzf.fish git-branch)
    #   Ctrl+Alt+R  tv channel browser (open any tv channel)
    # Ctrl+R stays with Atuin history search.
    for mode in default insert
        bind --mode $mode ctrl-alt-z _zmx_session_picker
        bind --mode $mode ctrl-alt-e _tv_command_picker
        bind --mode $mode ctrl-alt-b _tv_branch_picker
        bind --mode $mode ctrl-alt-r _tv_channel_picker
    end
end
