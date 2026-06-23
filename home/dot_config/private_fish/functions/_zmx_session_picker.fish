# Open the tv `x-zmx-sessions` channel. Enter pastes the session name at the
# cursor; Ctrl-A attaches, Ctrl-D kills (handled inside the channel). Bound to
# Ctrl-Alt-Z.
function _zmx_session_picker --description "Pick a zmx session via tv (Enter=paste name, Ctrl-A=attach)"
    if not command -q tv; or not command -q zmx
        return
    end
    _tv_paste_selection (tv x-zmx-sessions)
end
