# Open the tv `x-commands` channel: fuzzy-search every executable/script on PATH
# and insert the choice at the cursor (e.g. to build `zmx attach dev <cmd>`).
# Bound to Ctrl-Alt-E.
function _tv_command_picker --description "Pick an executable via tv, insert at cursor"
    if not command -q tv
        return
    end
    set -l selected (tv x-commands)
    if test -n "$selected"
        commandline -i -- $selected
    end
    commandline -f repaint
end
