# fish automatically executes this

function fish_user_key_bindings
    # Execute this once per mode that emacs bindings should be used in
    fish_default_key_bindings -M insert

    # Then execute the vi-bindings so they take precedence when there's a conflict.
    # Without --no-erase fish_vi_key_bindings will default to
    # resetting all bindings.
    # The argument specifies the initial mode (insert, "default" or visual).
    fish_vi_key_bindings --no-erase insert

    # Bind fzf completions (fzf tab completion) for both default and insert modes
    if functions -q _fzf_search_completions
        for mode in default insert
            bind --mode $mode \t _fzf_search_completions
            bind --mode $mode \cx _fzf_search_completions
        end
    end
end
