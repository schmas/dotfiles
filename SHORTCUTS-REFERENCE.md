# Shortcuts Reference

Quick reference for terminal keyboard shortcuts across tools.

## Table of Contents

- [Fish Shell](#fish-shell)
- [fzf.fish & fifc](#fzffish--fifc)
- [zmx & tv](#zmx--tv)
- [Zsh / Bash (Readline)](#zsh--bash-readline)
- [FZF (vanilla)](#fzf-vanilla)
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
| `Ctrl+R` | Atuin history search |
| `Ctrl+Alt+R` | Open tv channel browser |
| `Alt+↑` | Fish token-prefix history search |

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

## fzf.fish & fifc

> Active fish fuzzy bindings. Vanilla fzf shell widgets are overridden by these.

### fzf.fish plugin

| Key | Action |
| --- | ------ |
| `Ctrl+Alt+F` | Search directory (files/folders) |
| `Ctrl+Alt+L` | Search git log |
| `Ctrl+Alt+S` | Search git status |
| `Ctrl+Alt+B` | Search git branches |
| `Ctrl+Alt+P` | Search running processes |
| `Ctrl+V` | Search shell variables |
| `Tab` | Search completions |

> History is handled by Atuin on `Ctrl+R` (see Fish » History).

### fifc (fzf tab completion)

| Key | Action |
| --- | ------ |
| `Tab` | fzf-driven completion menu (context-aware) |
| `Ctrl+X` | fifc completion menu (alternate trigger) |

---

## zmx & tv

> Session manager (zmx) + fuzzy finder (tv) custom pickers.

### Pickers (keybindings)

| Key | Action |
| --- | ------ |
| `Ctrl+Alt+Z` | zmx session picker — fuzzy list + scrollback preview |
| `Ctrl+Alt+E` | Command picker — search PATH executables, insert at cursor |
| `Ctrl+Alt+R` | tv channel browser — open any tv channel |
| `?` | Open this cheatsheet in tv (fuzzy search) |

### In the zmx picker

| Key | Action |
| --- | ------ |
| `Enter` | Paste session name at cursor |
| `Ctrl+A` | Attach to selected session |
| `Ctrl+D` | Kill selected session |

### zmx CLI

| Key | Action |
| --- | ------ |
| `zmx ls` | List sessions |
| `zmx attach <name> [cmd]` | Attach (create if new), optionally run a command |
| `zmx history <name>` | Print session scrollback |
| `zmx kill <name>` | Kill a session |

### tv CLI

| Key | Action |
| --- | ------ |
| `tv` | Pick a channel, then search it |
| `tv <channel>` | Open a channel (our custom ones use the `x-` prefix, e.g. `tv x-zmx-sessions`, `tv x-commands`, `tv x-git-branch`) |
| `shortcuts [section] [query]` | Render this cheatsheet in the terminal (no-tv fallback) |

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

## FZF (vanilla)

> In-picker navigation (applies inside any fzf UI). Shell widgets like `Ctrl+T`
> may be overridden by fzf.fish — see the fzf.fish & fifc section.

| Key | Action |
| --- | ------ |
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
