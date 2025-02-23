function ls --wraps='eza --color=always --icons=auto' --description 'alias ls eza --color=always --icons=auto'
 if command -q eza
      eza --color=always --icons=auto $argv
  else
      command ls $argv
  end
end
