if status is-interactive; and command -q atuin
    # set -gx ATUIN_NOBIND "true"
    atuin init fish --disable-up-arrow | source

    # Ctrl+R is already bound to atuin search by `atuin init fish` above.
    # Ctrl+Alt+R is intentionally left free for the tv channel picker
    # (bound in functions/fish_user_key_bindings.fish).
end
