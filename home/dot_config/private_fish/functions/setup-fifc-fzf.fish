function setup-fifc-fzf
  set -Ux fifc_editor nvim

  # Bind fzf completions to ctrl-x (uncommented to avoid conflict with carapace)
  set -U fifc_keybinding \cx

  set -U fifc_bat_opts --style=numbers

  # Limit depth to 3 levels for speed, exclude .git
  set -U fifc_fd_opts --max-depth 3 --exclude .git
  
  # Always show hidden files/directories (custom fork feature)
  set -U fifc_show_hidden true
  
  # Case-insensitive completion matching (custom fork feature)
  set -U fifc_case_insensitive true
end
