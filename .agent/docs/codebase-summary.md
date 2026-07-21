# Codebase Summary

Navigation only. This maps concerns to their owning location so you can jump to
the right place; it does not describe files individually (that drifts) or restate
architecture (see [System Architecture](./system-architecture.md)).

## Source root

`home/` is the chezmoi source root (named by the repo-root `.chezmoiroot`).
Everything below is
relative to it. Applied targets land in `$HOME`; `README.md` and `docs/` are
excluded from apply (`home/.chezmoiignore`).

## Where things live

| Concern | Location |
|---|---|
| Init prompts, profile/OS/WSL gates | `.chezmoi.yaml.tmpl` |
| Apply-time setup scripts (before/after) | `.chezmoiscripts/` |
| Fetched artifacts (e.g. `upall`) | `.chezmoiexternal.toml` |
| Platform / repo-only exclusions | `.chezmoiignore`, `.chezmoiremove` |
| Shared template snippets | `.chezmoitemplates/` |
| Shared env vars (all shells) | `dot_config/private_env/` |
| Shared `PATH` (all shells) | `dot_config/private_path/` |
| Fish config & modules | `dot_config/private_fish/` |
| Zsh config & modules | `dot_config/private_zsh/` |
| Bash config & modules | `dot_config/private_bash/` |
| Fisher plugin list | `dot_config/private_fish/fish_plugins` |
| Sheldon plugin lists | `dot_config/private_{zsh,bash}/etc/sheldon/plugins.toml` |
| Package manifest (brews + casks) | `dot_config/etc/Brewfile.tmpl` |
| Other app configs (git, tmux, zellij, atuin, …) | `dot_config/` |
| Utility scripts | `bin/` (macOS-only in `bin/macos/`) |
| Editor configs (IdeaVim, Vim, Zed, LVim) | `dot_ideavimrc`, `dot_vimrc`, `dot_config/zed`, `dot_config/lvim` |
| Secrets (SSH, GPG agent, gitconfig) | `dot_config/etc/*.tmpl`, `private_dot_ssh/` |

## Aliases, functions, shortcuts

Do not enumerate these here — they are maintained in
[SHELL-REFERENCE.md](../SHELL-REFERENCE.md) (aliases/functions) and
[SHORTCUTS-REFERENCE.md](../SHORTCUTS-REFERENCE.md) (keybindings).
