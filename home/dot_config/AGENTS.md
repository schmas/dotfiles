# DOT_CONFIG — Application Configurations

19 app configs, 120 files. Deploys to `~/.config/`. Template files (`.tmpl`) processed by chezmoi at apply time.

## STRUCTURE

```
dot_config/
├── private_fish/           # Fish shell (34 files: conf.d, functions, completions)
├── private_zsh/            # Zsh shell (33 files: conf.d, functions, etc/sheldon)
├── private_bash/           # Bash shell (17 files: conf.d, etc/sheldon)
├── private_env/            # Centralized env vars (5 .env.tmpl files, sourced by ALL shells)
├── git/                    # Git: config.main.tmpl, config.aaa.tmpl, aliases.tmpl, ignore
├── tmux/                   # oh-my-tmux framework (1,891 lines) — edit tmux.conf.local ONLY
├── zellij/                 # Zellij multiplexer (365 lines KDL config)
├── starship.toml           # Prompt (184 lines, custom palette)
├── atuin/                  # Shell history sync (269 lines, secret filtering)
├── mise/                   # Runtime manager: 22 tools (Node, Python, Go, Java, Rust, etc.)
├── ghostty/                # Terminal emulator config
├── lazygit/                # Git UI with custom commands (aicommit2)
├── yazi/                   # File manager + theme
├── lvim/                   # LunarVim editor (Lua)
├── zed/                    # Zed editor (JSON settings)
├── nushell/                # Nushell (3 lines, experimental)
├── private_karabiner/      # macOS keyboard: Citrix remapping (6 complex mods)
├── private_1Password/      # SSH agent config: 3 vaults (Private, Dotfiles, AAA)
└── etc/                    # Templates: gitconfig, ssh_config, gpg-agent, npmrc, maxfiles.plist
```

## SHELL ARCHITECTURE

All 3 shells follow identical `conf.d/` pattern with numeric prefix load order:

```
00-*  Homebrew init          │ 05-*  Source ~/.config/env/*.env
10-*  Common env, PATH       │ 20-*  OS-specific (darwin/linux)
49-*  Input (Zsh only)       │ 50-*  Completions
70-*  Tool init (Starship)   │ 98-*  Plugin managers
99-*  Aliases (last)         │ zzz-* Late-load (Mise, FZF, Atuin)
```

**Cross-shell consistency:**
- `private_env/` — POSIX `.env` files sourced by all shells (single source of truth)
- Zsh/Bash aliases in `99-aliases.*.tmpl` — MUST be identical
- Fish uses abbreviations in `10-abbr.fish` (functionally equivalent)
- Plugin managers: Fisher (Fish), Sheldon (Zsh/Bash)
- All shells init Starship prompt, Mise runtimes

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add shared env var | `private_env/10-shared.env.tmpl` | POSIX format, all shells |
| Add API token | `private_env/15-services.env.tmpl` | Use `onepasswordRead` |
| Add AI config | `private_env/30-ai-config.env.tmpl` | AI tool env vars |
| Modify Fish abbreviations | `private_fish/conf.d/10-abbr.fish` | Update SHELL-REFERENCE.md |
| Modify Zsh/Bash aliases | `private_{zsh,bash}/conf.d/99-aliases.*.tmpl` | Keep in sync! |
| Add Fish function | `private_fish/functions/{name}.fish` | Auto-loaded by Fish |
| Add Zsh function | `private_zsh/functions/{name}` | Auto-loaded via fpath |
| Add Fish plugin | `private_fish/fish_plugins` | One plugin per line |
| Add Zsh plugin | `private_zsh/etc/sheldon/plugins.toml` | TOML format |
| Modify Git identity | `git/config.main.tmpl` or `git/config.aaa.tmpl` | Profile-specific |
| Modify Git aliases | `git/aliases.tmpl` | Also has custom git subcommands in `bin/git-scripts/` |
| Customize Tmux | `tmux/tmux.conf.local` | Never edit `tmux.conf` (framework file) |
| Modify prompt | `starship.toml` | Starship cross-shell prompt |

## 1PASSWORD SECRETS

9 files reference `op://` secrets:
- `git/config.main.tmpl`, `git/config.aaa.tmpl` — Git identity + signing
- `private_env/15-services.env.tmpl` — 8 API keys (GitHub, Gemini, Context7, MXBAI)
- `etc/npmrc.template.tmpl` — GitHub registry token
- `private_1Password/private_ssh/private_agent.toml.tmpl` — SSH vault config

Vaults: `op://dotfiles/`, `op://Dotfiles/`, `op://Private/`, `op://AAA/`

## ANTI-PATTERNS

- **NEVER** edit `tmux/tmux.conf` directly — it's the oh-my-tmux framework; use `tmux.conf.local`
- **NEVER** duplicate env vars across shells — add to `private_env/*.env.tmpl` instead
- **NEVER** add shell aliases to only one shell — Zsh/Bash must stay in sync
- OS-specific code goes in `20-os.{darwin,linux}.*` files, never in common files
