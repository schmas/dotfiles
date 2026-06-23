# Open the tv channel browser (all channels), then insert the picked result at
# the cursor. Channels with execute actions (e.g. zmx attach) run directly.
# Bound to Ctrl-Alt-R.
function _tv_channel_picker --description "Open the tv channel browser, insert result at cursor"
    if not command -q tv
        return
    end
    _tv_paste_selection (tv channels)
end
