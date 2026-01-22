# Scout Report: Shell Configurations

## Overview
Analyzed three distinct shell configurations (Fish, Zsh, Bash) in chezmoi dotfiles repository. Each shell has modular structure with conf.d/ (configuration), functions/, and template files. Common theme: consistent aliases across shells, multiple plugin managers (Fisher for Fish, Sheldon for Zsh/Bash), and shared tool integrations (fzf, atuin, mise, starship, zoxide).

---

## Fish Shell (`private_fish/`)

### Files
**Entry points:**
- `config.fish` - Main initialization file, sources config_local.fish
- `config_local.template.fish` - Template for user-local config
- `fish_plugins` - Plugin manifest for Fisher

**Configuration modules** (conf.d/):
- `00-install_fisher.fish` - Fisher plugin manager auto-installation
- `00-load-homebrew.fish.tmpl` - Homebrew initialization (macOS conditional)
- `10-common.env.fish.tmpl` - Locale and editor settings (LANG, VISUAL, EDITOR)
- `10-common.path.fish.tmpl` - PATH setup ($HOME/bin/ and $HOME/.local/bin)
- `10-colors.fish` - EZA_COLORS configuration
- `10-abbr.fish` - Comprehensive abbreviations (~230 lines, largest)
- `20-os.darwin.env.fish.tmpl` - macOS-specific env vars
- `20-os.darwin.path.fish.tmpl` - macOS-specific PATH
- `20-os.linux.env.fish.tmpl` - Linux-specific env vars
- `20-os.linux.path.fish.tmpl` - Linux-specific PATH
- `70-zellij.fish` - Terminal multiplexer Zellij auto-start (conditional on iTerm)
- `70-starship-init.fish` - Starship prompt initialization
- `zzz-01-carapace.fish` - Carapace completion system
- `zzz-02-fzf-config.fish` - FZF configuration with fd integration
- `zzz-97-atuin-history.fish` - Atuin history search (Ctrl-Alt-R binding)
- `zzz-98-mise-config.fish` - Mise runtime manager activation

**Functions** (functions/):
- `fish_user_key_bindings.fish` - VI mode + fifc tab completion setup
- `setup-fifc-fzf.fish` - FIFC (fzf tab completion) configuration (case-insensitive, hidden files, depth=3)
- `yy.fish` - Yazi file manager navigation wrapper
- `multicd.fish` - Multi-level cd abbreviation (... -> cd ../../)
- `multicd2.fish` - Alternative multi-level cd variant
- `ls.fish` - Custom ls function
- `clear_fish_welcome_message.fish` - Suppress welcome message
- `fish_customization_setup.fish` - Setup utilities
- `has_aws_token_expired.fish` - AWS token validation
- `install-fisher.fish` - Fisher installation utility
- `install-rust.fish` - Rust installation wrapper
- `my_fish_setup.fish` - General setup function

**Completions** (completions/):
- `nix-config-update.fish` - Nix config completion

### Key Functions
- **multicd**: Regex-based cd depth expansion (.. -> ../, ... -> ../../)
- **yy**: Yazi file manager chdir integration
- **fish_user_key_bindings**: VI mode with emacs bindings, Tab=fifc, Ctrl-X=fifc alternate
- **setup-fifc-fzf**: Configures custom fifc fork with case-insensitive matching, hidden files visibility

### Dependencies
**Plugin Manager:** Fisher (auto-installs in config)
**Plugins:** (from fish_plugins)
- brgmnn/fish-docker-compose
- edheltzel/fisher-plugin-macos
- jorgebucaran/autopair.fish (auto-pairing)
- jorgebucaran/fish-bax (bash/zsh integration)
- kidonng/zoxide.fish (smart cd)
- meaningful-ooo/sponge (purge on exit)
- nickeb96/puffer-fish
- oh-my-fish/plugin-thefuck
- schmas/fifc (custom fork, fzf tab completion)
- schmas/fzf.fish (custom fork, fzf integration)
- ryotako/fish-completion-generator

**External Tools:**
- Starship (prompt)
- Mise (runtime manager)
- Atuin (history search)
- FZF (fuzzy finding)
- fd (find replacement)
- bat (syntax highlighting)
- eza (ls replacement with icons)
- Zellij (terminal multiplexer, optional)
- Yazi (file manager)

### Notable Features
- **1OP tokens embedded**: MISE_GITHUB_TOKEN, HOMEBREW_GITHUB_TOKEN via 1password (onepasswordRead)
- **Sponge integration**: `sponge_purge_only_on_exit=true` (clean history only on exit)
- **Extensive abbreviations**: 230 lines covering git, npm, maven, cargo, chezmoi, docker, homebrew
- **Custom keybindings**: Alt-R for Atuin history, Tab/Ctrl-X for fifc
- **OS-conditional loading**: Separate darwin/linux env and path configs
- **FIFC customization**: Hidden files, case-insensitive, limited depth for performance

---

## Zsh Shell (`private_zsh/`)

### Files
**Entry points:**
- `zshrc` - Main initialization, profiling setup, autoload functions
- `zshenv` - Environment-only file (currently minimal)
- `zshrc_local.template` - User-local overrides template

**Configuration modules** (conf.d/):
- `10-common.env.zsh.tmpl` - Locale, editor, history, ASDF, ZSH options (82 lines)
- `10-common.path.zsh.tmpl` - Not found in reads but listed in glob
- `20-os.darwin.env.zsh.tmpl` - macOS env
- `20-os.darwin.path.zsh.tmpl` - macOS PATH
- `20-os.linux.env.zsh.tmpl` - Linux env
- `20-os.linux.path.zsh.tmpl` - Linux PATH
- `49-input.zsh` - Keybindings (Emacs mode, beep settings, pushd behavior)
- `50-completions.zsh` - Fuzzy completion config, fzf-tab setup (88 lines)
- `98-sheldon.zsh` - Plugin manager + Starship initialization
- `99-aliases.zsh.tmpl` - Full alias set (~353 lines, comprehensive)

**Functions** (functions/):
- `@shexit` - Exit handler (referenced but see trap comment)
- `__dircycle_update_cycled` - Directory cycle management
- `__sudo` - Sudo wrapper
- `d` - Directory function
- `fix_zsh_insecure` - Permissions fix
- `fp` - File picker
- `get_os` - OS detection
- `history-stat` - History analysis
- `is_archlinux`, `is_cygwin`, `is_osx`, `is_ubuntu` - OS checks
- `prompt_term_program_p10k` - Terminal detection for p10k
- `start_tmux` - Tmux session wrapper
- `zicompinit_fast` - Fast completion initialization
- `zinit_cleanup` - Plugin manager cleanup

**Plugin Configuration** (etc/sheldon/plugins.toml):
- Sheldon TOML manifest (detailed below)

### Key Functions
- **zicompinit_fast**: Optimized completion init (faster startup)
- **start_tmux**: Session management utility
- **Directory functions**: `d`, `__dircycle_update_cycled` for smart navigation
- **OS detection**: `is_osx`, `is_ubuntu`, `is_archlinux` - conditional setup

### Dependencies
**Plugin Manager:** Sheldon (auto-installs if missing)

**Sheldon Plugins** (27 configured):
1. oh-my-zsh - Plugin suite (1password, colorize, docker-compose, git, gradle, maven, pip, sudo, aws, extract)
2. fzf-tab - FZF completion tabulation
3. zoxide - Smart cd (z/zi commands)
4. base16-shell - Color schemes
5. zpm-zsh-colors - Color system
6. dircolors-neutral - Custom dir colors (schmas fork)
7. asdf - Runtime version manager
8. yarn-completion - Yarn completions
9. zsh-better-npm-completion - npm completion enhancements
10. pnpm-shell-completion - pnpm completions
11. nx-completion - Nx monorepo completions
12. git-ignore - Git ignore helper
13. zsh-diff-so-fancy - Diff formatting
14. git-fuzzy - Fuzzy git UI
15. forgit - Forgit (git integration)
16. git-open - Open git repo in browser
17. git-extras-completion - Git extras completions
18. gita-completion - Gita VCS completions
19. github-copilot-cli - Copilot auto-install hook
20. zsh-thefuck - Command correction
21. zsh-autopair - Auto-pairing brackets
22. fast-syntax-highlighting - Syntax highlighting
23. zsh-autosuggestions - Command suggestions
24. history-search-multi-word - Multi-word history search
25. zsh-history-substring-search - Substring history search
26. zsh-completions - Additional completions

**External Tools:**
- Starship (prompt)
- Mise (runtime manager)
- Sheldon (plugin manager)
- FZF with fzf-tab
- fd, bat, eza (ls alternative)
- git-fuzzy, git-open, git-ignore
- delta (diff viewer)
- thefuck (command correction)
- Atuin (history)

### Notable Features
- **fzf-tab previews**: Git diffs with delta, logs, git show, status with intelligent grouping
- **Keybindings**: Ctrl-Right/Left word navigation, Ctrl-Del kill word, custom history keys
- **Completion system**: Fuzzy matching, 3-level depth approximation, git checkout sort disabled
- **Sheldon templates**: OMZPATH, OMZP for plugin orchestration
- **ZSH_CACHE_DIR**: Dedicated ~/.zcompcache for completion caching
- **History config**: 1000 size, shared across terminals, append mode
- **Aliases**: Git, npm, maven, cargo, docker, tmux, chezmoi, homebrew, nix

---

## Bash Shell (`private_bash/`)

### Files
**Entry points:**
- `bashrc` - Main initialization, sources conf.d/ files
- `bashrc_local.template` - User-local template

**Configuration modules** (conf.d/):
- `10-common.env.bash.tmpl` - Locale, editor, history, ASDF (32 lines, minimal)
- `10-common.path.bash.tmpl` - PATH setup
- `20-os.darwin.env.bash.tmpl` - macOS env
- `20-os.darwin.path.bash.tmpl` - macOS PATH
- `20-os.linux.env.bash.tmpl` - Linux env
- `20-os.linux.path.bash.tmpl` - Linux PATH
- `50-completions.bash` - Bash completion sourcing
- `98-sheldon.bash` - Sheldon + Starship initialization
- `99-aliases.bash.tmpl` - Alias definitions (same as zsh)

**Plugin Configuration** (etc/sheldon/plugins.toml):
- Sheldon TOML for bash (simpler, 6 plugins)

**Functions:** (functions/.keep - no functions defined)

### Key Functions
None explicitly defined; relies on Sheldon plugins.

### Dependencies
**Plugin Manager:** Sheldon (auto-installs if missing)

**Sheldon Plugins** (6 configured):
1. asdf - Runtime manager
2. zoxide-loader - Smart cd init
3. thefuck - Command correction
4. fzf-loader - FZF initialization
5. fzf-bash-completion - Tab completion with fzf

**External Tools:**
- Starship (prompt)
- Mise (runtime manager)
- Sheldon (plugin manager)
- FZF with fzf-tab-completion
- fd, bat (preview)
- zoxide (smart cd)
- thefuck

### Notable Features
- **Minimal setup**: Only 26 lines in 10-common.env.bash.tmpl vs 82 in zsh
- **No custom functions**: Bash shell kept lean
- **fzf binding**: `bind -x '"\t": fzf_bash_completion'` for tab completion
- **Aliases**: Same comprehensive set as zsh (imported from zsh/99-aliases.zsh.tmpl logic)
- **Starship prompt**: Auto-install if missing

---

## Cross-Shell Patterns

### Shared Architecture
shell_config/
├── config.{shell}        - Entry point
├── {shell}rc_local.template - User overrides
├── conf.d/               - Modular configs (alphabetically ordered)
├── functions/            - Shell-specific functions
├── completions/          - Shell-specific completions
└── etc/sheldon/plugins.toml - Sheldon config (zsh/bash)

### Configuration Naming Convention
- `00-*.fish/.zsh/.bash` - Installation/loading order (Fisher, Homebrew)
- `10-*.tmpl` - Common env/path (locale, editor, dotfiles bin)
- `20-os.{darwin,linux}.*` - OS-specific configs
- `49-*.zsh` - Zsh input/keybindings
- `50-*.{zsh,bash}` - Completions
- `70-*.fish` - Fish-specific tools (Zellij, Starship)
- `98-sheldon.{zsh,bash}` - Plugin manager
- `99-aliases.*` - Aliases (always last)
- `zzz-*.fish` - Fish late-loading (carapace, fzf, atuin, mise)

### Shared Aliases/Abbreviations
All shells implement identical sets:
- **Git**: g, gaa, gc, gcm, gco, gsw, gp, gpl, gd, gs, lzg
- **npm**: ni, nis, nr, nrs, nrt, nrb, nup, nrm
- **maven**: mc, mp, mi, mt, mci, mcp
- **cargo**: cgr, cgt, cgb, cgc
- **tmux**: amux, tkill, nmux, st
- **Chezmoi**: czm, czmcd, czma, czmu
- **Docker**: dspall, lzd
- **Homebrew**: bi, brews, casks
- **IDEs**: ij (idea), ws (webstorm), rr (rustrover)
- **Directories**: home, configd, locald, fishd, chezmoid
- **Directory navigation**: cd.. -> cd .., ... -> cd ../.., etc.

### Shared Tool Integrations
1. **Starship**: All shells initialize if DISABLE_STARSHIP ≠ 1
2. **FZF**: All shells configure FZF_DEFAULT_COMMAND with fd, FZF_DEFAULT_OPTS, previews
3. **Mise**: All shells activate mise if available
4. **Zoxide**: Fish plugin, Zsh plugin, Bash plugin for smart cd
5. **Atuin**: Fish custom binding (Alt-R), not explicitly in Zsh/Bash but plugin available
6. **1Password**: Tokens from 1password (Fish env), op signin abbreviations (Fish/Zsh)
7. **Thefuck**: Fish plugin, Zsh plugin, Bash plugin

### Environment Variables Across Shells
- LANG, LANGUAGE, LC_TIME - All set to en_US.UTF-8
- VISUAL/EDITOR - All default to nvim (bash uses vim in template)
- SYSTEMD_EDITOR - All set to EDITOR
- CLICOLOR - All set to 1
- GPG_TTY - All set to $(tty)
- OPENCV_LOG_LEVEL - All set to ERROR
- Tokens: MISE_GITHUB_TOKEN, HOMEBREW_GITHUB_TOKEN (1password in Fish)

### Key Differences

| Aspect | Fish | Zsh | Bash |
|--------|------|-----|------|
| Plugin Manager | Fisher | Sheldon | Sheldon |
| Plugins Count | 13 | 27 | 6 |
| Prompt | Starship | Starship (p10k instant) | Starship |
| Functions | 13 custom | 8 custom | 0 |
| Abbreviations | 230+ abbr | Aliases | Aliases |
| Keybindings | Tab=fifc, VI mode | Emacs + history, Ctrl-Right word | Standard |
| Completion | Carapace, fifc (custom) | fzf-tab, oh-my-zsh | fzf-tab-completion |
| History Search | Atuin (Alt-R) | Substring search, multi-word | Standard |
| Template Vars | 1password tokens | Minimal | Minimal |
| OS Config | Separate files | Separate files | Separate files |

### Template Files
- Fish: `10-common.env.fish.tmpl`, `10-common.path.fish.tmpl`, `00-load-homebrew.fish.tmpl`, `20-os.*.fish.tmpl` use Chezmoi templating
- Zsh: `10-common.env.zsh.tmpl`, `10-common.path.zsh.tmpl`, `20-os.*.zsh.tmpl`, `99-aliases.zsh.tmpl` with conditional os/release templating
- Bash: `10-common.env.bash.tmpl`, `10-common.path.bash.tmpl`, `20-os.*.bash.tmpl`, `99-aliases.bash.tmpl` with conditional os/release templating

### Security Considerations
- Fish template extracts 1password secrets for tokens (checked during chezmoi apply)
- Bash sheldon has zoxide inline plugin (command -v check)
- All shells source local config templates (bashrc_local, zshrc_local, config_local.fish) if present
- Sudo alias enabled across shells ('sudo ' allows sudo to use aliases)

---

## Unresolved Questions

1. **FIFC custom fork features**: The custom schmas/fifc fork in Fish shell has `case_insensitive` and `show_hidden` features - are these merged upstream or proprietary enhancements?

2. **Sheldon vs Fisher migration path**: Fish uses Fisher, while Zsh/Bash use Sheldon. Is there a plan to unify on Sheldon, or will Fisher remain the primary for Fish?

3. **Atuin configuration**: Atuin binding exists in Fish (Alt-R), but no explicit initialization in Zsh/Bash sheldon. Is Atuin only used in Fish or disabled elsewhere?

4. **p10k instant prompt in Zsh**: 98-sheldon.zsh sources p10k instant prompt from cache, but Starship is the main prompt. Is p10k still in use or deprecated?

5. **Bash minimal setup reason**: Why are only 6 sheldon plugins for Bash vs 27 for Zsh? Intentional simplification or incomplete migration?

6. **Local config templates vs actual files**: Are bashrc_local, zshrc_local, config_local.fish actively used? Template-only suggests they may be user-created post-setup.

7. **OMZP plugin selection**: The Zsh oh-my-zsh plugin list (1password, colorize, etc.) is hardcoded in template. How are plugin changes deployed without re-templating?

8. **Dircolors-neutral fork**: What enhancements does the schmas/dircolors-neutral fork have? Standard fork or heavily customized?

