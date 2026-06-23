if status is-interactive
    # `?`  -> keybinding cheatsheet.
    #   bare `?`        : tv `shortcuts` channel (built-in fuzzy search), if tv installed
    #   `? fish` / etc  : fall back to the `shortcuts` CLI renderer (section + search args)
    function ? --description "Keybinding cheatsheet (tv fuzzy search, or shortcuts CLI)"
        if command -q tv; and test (count $argv) -eq 0
            # Read-only cheatsheet: discard the selected row (Ctrl-Y copies if needed)
            tv shortcuts >/dev/null
        else
            shortcuts $argv
        end
    end
end
