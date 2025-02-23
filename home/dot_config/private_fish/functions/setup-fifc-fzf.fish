function setup-fifc-fzf
  set -Ux fifc_editor nvim

  # Bind fzf completions to ctrl-x
  #  set -U fifc_keybinding \cx

  set -U fifc_bat_opts --style=numbers

  set -U fifc_fd_opts --hidden
end
