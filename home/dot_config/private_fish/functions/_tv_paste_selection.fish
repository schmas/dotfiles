# Insert tv selection(s) at the cursor, space-joined inline on a single line.
# tv stores multi-selections (Tab) in a HashSet, so it emits them in arbitrary
# order; sort for a stable, predictable result and join with spaces instead of
# pasting one name per line. Shared by the _tv_*_picker / _zmx_session_picker
# functions. Single selections pass through unchanged.
function _tv_paste_selection --description "Insert tv selection(s) inline at the cursor"
    if test (count $argv) -gt 0
        commandline -i -- (string join ' ' (printf '%s\n' $argv | sort))
    end
    commandline -f repaint
end
