if status --is-interactive
    # Don't load starship if DISABLE_STARSHIP is 1
    if test "$DISABLE_STARSHIP" != "1"
        if type -q starship
            starship init fish | source
        end
    end
end
