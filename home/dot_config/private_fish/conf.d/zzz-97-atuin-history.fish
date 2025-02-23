if status is-interactive; and command -q atuin
    # set -gx ATUIN_NOBIND "true"
    atuin init fish --disable-up-arrow | source

    # bind to ctrl-r in normal and insert mode, add any other bindings you want here too
    # bind \cr _atuin_search
    # bind -M insert \cr _atuin_search

    # bind to ctrl-alt-r in normal and insert mode
    bind \e\cr _atuin_bind_up
    bind -M insert \e\cr _atuin_bind_up
end
