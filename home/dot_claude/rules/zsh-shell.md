# Bash tool shell: zsh or bash

The Bash tool runs zsh or bash, never fish (the login shell). On macOS it is zsh.
Write commands that work in both shells.

- Quote any word that starts with `=`. zsh reads `=word` as the path of command `word`.
  If no such command exists, zsh stops the whole command line.
  Write `echo '---'` or `echo '==='`, never `echo ===`.
- Do not use fish syntax.
