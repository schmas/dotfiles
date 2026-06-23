# Open the tv `zmx-sessions` channel. Enter pastes the session name at the
# cursor; Ctrl-A attaches, Ctrl-D kills (handled inside the channel). Bound to
# Ctrl-Alt-Z.
function _zmx_session_picker --description "Pick a zmx session via tv (Enter=paste name, Ctrl-A=attach)"
    if not command -q tv; or not command -q zmx
        return
    end
    set -l selected (tv zmx-sessions)
    if test -n "$selected"
        commandline -i -- $selected
    end
    commandline -f repaint
end
