# Open the tv `x-git-branch` channel and insert the picked branch name at the
# cursor (e.g. to build `git rebase <branch>`). Ctrl-S cycles All/Local/Remote,
# Ctrl-O checks out, Ctrl-Y copies the name. Bound to Ctrl-Alt-B.
function _tv_branch_picker --description "Pick a git branch via tv, insert at cursor"
    if not command -q tv; or not command -q git
        return
    end
    _tv_paste_selection (tv x-git-branch)
end
