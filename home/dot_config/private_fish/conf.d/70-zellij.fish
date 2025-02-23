if string match -q "*iTerm*" -- $TERM_PROGRAM
    set ZELLIJ_ENABLED false
end

if status is-interactive; and command -q zellij
    and type -q zellij
    and test "$ZELLIJ_ENABLED" = true

    eval (zellij setup --generate-auto-start fish | string collect)
end
