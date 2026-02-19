# Shortcuts Reference

Quick reference for terminal keyboard shortcuts across tools.

## Table of Contents

- [Fish Shell](#fish-shell)
- [Zsh / Bash (Readline)](#zsh--bash-readline)
- [FZF](#fzf)
- [Tmux](#tmux)
- [Vim / Neovim](#vim--neovim)

---

## Fish Shell

### Autosuggestions

| Key | Action |
| --- | ------ |
| `→` / `Ctrl+F` | Accept full suggestion |
| `Alt+→` / `Alt+F` | Accept one word/folder at a time |
| `Ctrl+E` | Move cursor to end (accepts inline) |

### Completions (Tab Menu)

| Key | Action |
| --- | ------ |
| `Tab` | Open completion menu / next item |
| `Shift+Tab` | Previous item in menu |
| `Ctrl+S` | Search within completion menu |
| `Escape` | Close menu |

### Navigation

| Key | Action |
| --- | ------ |
| `Ctrl+A` | Move to beginning of line |
| `Ctrl+E` | Move to end of line |
| `Alt+←` / `Alt+B` | Move back one word |
| `Alt+→` / `Alt+F` | Move forward one word |

### Editing

| Key | Action |
| --- | ------ |
| `Ctrl+W` | Delete previous word |
| `Alt+D` | Delete next word |
| `Ctrl+U` | Delete entire line |
| `Ctrl+K` | Delete from cursor to end |
| `Ctrl+Y` | Paste (yank) deleted text |
| `Ctrl+T` | Transpose characters |
| `Alt+T` | Transpose words |
| `Alt+U` | Uppercase word |
| `Alt+L` | Lowercase word |
| `Alt+C` | Capitalize word |

### History

| Key | Action |
| --- | ------ |
| `↑` / `Ctrl+P` | Previous command |
| `↓` / `Ctrl+N` | Next command |
| `Ctrl+R` | Search history (Atuin / pager) |
| `Alt+↑` | Search history with current token as prefix |

### Misc

| Key | Action |
| --- | ------ |
| `Ctrl+L` | Clear screen |
| `Ctrl+D` | Exit / EOF |
| `Ctrl+C` | Cancel current line |
| `Ctrl+Z` | Suspend process |
| `Alt+E` / `Alt+V` | Edit command in `$EDITOR` |
| `Alt+P` | Page output of previous command |
| `Alt+H` | Open man page for current command |
| `Alt+W` | Print short description of current command |

---

## Zsh / Bash (Readline)

### Navigation

| Key | Action |
| --- | ------ |
| `Ctrl+A` | Beginning of line |
| `Ctrl+E` | End of line |
| `Alt+B` | Back one word |
| `Alt+F` | Forward one word |

### Editing

| Key | Action |
| --- | ------ |
| `Ctrl+W` | Delete previous word |
| `Ctrl+U` | Delete to beginning of line |
| `Ctrl+K` | Delete to end of line |
| `Ctrl+Y` | Yank (paste) |
| `Ctrl+_` | Undo |

### History

| Key | Action |
| --- | ------ |
| `Ctrl+R` | Reverse history search |
| `Ctrl+S` | Forward history search |
| `Ctrl+G` | Cancel history search |
| `!!` | Repeat last command |
| `!$` | Last argument of previous command |
| `Alt+.` | Insert last argument (repeatable) |

---

## FZF

| Key | Action |
| --- | ------ |
| `Ctrl+T` | Fuzzy-find files, paste to command line |
| `Ctrl+R` | Fuzzy-search history |
| `Alt+C` | Fuzzy-cd into directory |
| `Tab` | Multi-select item |
| `Shift+Tab` | Deselect item |
| `Ctrl+/` | Toggle preview window |
| `Ctrl+U` / `Ctrl+D` | Half-page up/down in preview |

---

## Tmux

> Prefix: `Ctrl+B`

### Sessions / Windows / Panes

| Key | Action |
| --- | ------ |
| `Prefix + c` | New window |
| `Prefix + ,` | Rename window |
| `Prefix + n` / `p` | Next / previous window |
| `Prefix + 0-9` | Switch to window N |
| `Prefix + %` | Split vertically |
| `Prefix + "` | Split horizontally |
| `Prefix + ←↑↓→` | Navigate panes |
| `Prefix + z` | Toggle pane zoom |
| `Prefix + x` | Kill pane |
| `Prefix + d` | Detach session |
| `Prefix + s` | List sessions (interactive) |
| `Prefix + $` | Rename session |

### Copy Mode

| Key | Action |
| --- | ------ |
| `Prefix + [` | Enter copy mode |
| `Space` | Start selection (vi mode) |
| `Enter` | Copy selection |
| `Prefix + ]` | Paste |

---

## Vim / Neovim

### Navigation

| Key | Action |
| --- | ------ |
| `gg` / `G` | First / last line |
| `0` / `$` | Beginning / end of line |
| `w` / `b` | Next / previous word |
| `Ctrl+D` / `Ctrl+U` | Half page down / up |
| `Ctrl+F` / `Ctrl+B` | Full page down / up |
| `%` | Jump to matching bracket |

### Editing

| Key | Action |
| --- | ------ |
| `ciw` | Change inner word |
| `di"` | Delete inside quotes |
| `yy` / `dd` | Yank / delete line |
| `p` / `P` | Paste after / before |
| `u` / `Ctrl+R` | Undo / redo |
| `.` | Repeat last change |
| `>>`/ `<<` | Indent / de-indent line |

### Search

| Key | Action |
| --- | ------ |
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` / `N` | Next / previous match |
| `*` / `#` | Search word under cursor forward / back |
| `:%s/old/new/g` | Replace all in file |
