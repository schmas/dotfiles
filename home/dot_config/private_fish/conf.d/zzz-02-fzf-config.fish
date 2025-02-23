if status is-interactive
    ###############################################################################
    # fzf
    ###############################################################################
    set -gx FZF_DEFAULT_COMMAND "fd --hidden --strip-cwd-prefix --exclude .git"
    set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
    set -gx FZF_ALT_C_COMMAND "fd --type=d --hidden --strip-cwd-prefix --exclude .git"

    set -gx FZF_DEFAULT_OPTS '--cycle --height 50% --layout=reverse --border --color=hl:#2dd4bf --preview-window=wrap --marker="*"'

    # Setup fzf previews
    set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always -n --line-range :500 {}'"
    set -gx FZF_ALT_C_OPTS "--preview 'eza --icons=auto --tree --color=always {} | head -200'"

    # fzf preview for tmux
    set -gx FZF_TMUX_OPTS " -p90%,70% "

    ###############################################################################
    # https://github.com/Matt-FTW/fzf.fish configs
    ###############################################################################
    set -gx fzf_fd_opts --hidden --strip-cwd-prefix --exclude .git
    set -gx fzf_history_time_format %d-%m-%y
    set -gx fzf_git_log_format "%C(yellow)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset"

    if command -q eza
        set -gx fzf_preview_dir_cmd eza --long --color=always --icons=auto -a --no-permissions --no-user
    end

    if command -q diff-so-fancy
        set -gx fzf_diff_highlighter diff-so-fancy
    end

    if functions -q fzf_configure_bindings
        # Changed history binding to ctrl-alt-r
        fzf_configure_bindings --history=\e\cr || true
    end
end
