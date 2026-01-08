function setup-fzf-completions
  set -Ux fzf_completions_editor nvim

  # Bind fzf completions to ctrl-x (uncommented to avoid conflict with carapace)
  set -U fzf_completions_keybinding \cx

  set -U fzf_completions_bat_opts --style=numbers

  # Limit depth to 3 levels for speed, exclude large directories
  set -U fzf_completions_fd_opts --max-depth 3 --exclude .git --exclude node_modules --exclude .cache --exclude target --exclude build
  
  # Show hidden files/directories but exclude the large ones above
  set -U fzf_completions_show_hidden true
end
