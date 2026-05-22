# Shell Reference

This document provides a comprehensive reference for all aliases, functions, and scripts defined in this dotfiles repository. Commands are organized by functionality with shell availability indicated.

## Shell Legend

- **F** = Fish (abbreviations)
- **B** = Bash (aliases)
- **Z** = Zsh (aliases)

## Table of Contents

- [File System Navigation](#file-system-navigation)
- [Directory Shortcuts](#directory-shortcuts)
- [Directory Listing](#directory-listing)
- [Chezmoi](#chezmoi)
- [Git](#git)
- [GitHub CLI](#github-cli)
- [Docker](#docker)
- [Package Managers](#package-managers)
- [Maven](#maven)
- [Tmux](#tmux)
- [IDEs](#ides)
- [Shells](#shells)
- [Rust/Cargo](#rustcargo)
- [Nix](#nix)
- [Miscellaneous](#miscellaneous)
- [Shell-Specific Functions](#shell-specific-functions)
- [Scripts](#scripts)

## File System Navigation

| Command    | Full Command                                       | Description                                          | Shells |
| ---------- | -------------------------------------------------- | ---------------------------------------------------- | ------ |
| `lag`      | `la --group-directories-first`                     | List all files with directories first                | F,B,Z  |
| `lat`      | `la --tree --level=2`                              | List all files in a tree view with depth 2           | F,B,Z  |
| `lagt`     | `la --group-directories-first --tree --level=2`    | List all files in a tree view with directories first | F,B,Z  |
| `cd..`     | `cd ..`                                            | Navigate up one directory                            | B,Z    |
| `cd...`    | `cd ../..`                                         | Navigate up two directories                          | B,Z    |
| `cd....`   | `cd ../../..`                                      | Navigate up three directories                        | B,Z    |
| `cd.....`  | `cd ../../../..`                                   | Navigate up four directories                         | B,Z    |
| `cd......` | `cd ../../../../..`                                | Navigate up five directories                         | B,Z    |
| `..`       | `cd ..` (via multicd function in Fish)             | Navigate up one directory                            | F,B,Z  |
| `...`      | `cd ../..` (via multicd function in Fish)          | Navigate up two directories                          | F,B,Z  |
| `....`     | `cd ../../..` (via multicd function in Fish)       | Navigate up three directories                        | F,B,Z  |
| `.....`    | `cd ../../../..` (via multicd function in Fish)    | Navigate up four directories                         | F,B,Z  |
| `......`   | `cd ../../../../..` (via multicd function in Fish) | Navigate up five directories                         | F,B,Z  |
| `-`        | `__dircycle_update_cycled +1`                      | Navigate to previous directory in stack              | B,Z    |
| `+`        | `__dircycle_update_cycled -0`                      | Navigate to next directory in stack                  | B,Z    |

## Directory Shortcuts

| Command    | Path                     | Description                       | Shells |
| ---------- | ------------------------ | --------------------------------- | ------ |
| `home`     | `~/`                     | Shortcut to home directory        | F,B,Z  |
| `configd`  | `~/.config/`             | Shortcut to config directory      | F,B,Z  |
| `locald`   | `~/.local/`              | Shortcut to local directory       | F,B,Z  |
| `fishd`    | `~/.config/fish`         | Shortcut to fish config directory | F,B,Z  |
| `chezmoid` | `~/.local/share/chezmoi` | Shortcut to chezmoi directory     | F,B,Z  |

## Directory Listing

| Command | Full Command | Description                                     | Shells |
| ------- | ------------ | ----------------------------------------------- | ------ |
| `lsa`   | `ls -lah`    | List all files with human-readable sizes        | B,Z    |
| `l`     | `ls -lah`    | List all files with human-readable sizes        | B,Z    |
| `ll`    | `ls -lah`    | List all files with human-readable sizes        | B,Z    |
| `la`    | `ls -lAh`    | List almost all files with human-readable sizes | B,Z    |

#### File System Navigation

| Abbreviation | Command                                         | Description                                          |
| ------------ | ----------------------------------------------- | ---------------------------------------------------- |
| `lag`        | `la --group-directories-first`                  | List all files with directories first                |
| `lat`        | `la --tree --level=2`                           | List all files in a tree view with depth 2           |
| `lagt`       | `la --group-directories-first --tree --level=2` | List all files in a tree view with directories first |
| `home`       | `~/`                                            | Shortcut to home directory                           |
| `configd`    | `~/.config/`                                    | Shortcut to config directory                         |
| `locald`     | `~/.local/`                                     | Shortcut to local directory                          |
| `fishd`      | `~/.config/fish`                                | Shortcut to fish config directory                    |
| `chezmoid`   | `~/.local/share/chezmoi`                        | Shortcut to chezmoi directory                        |
| `dotfiles`   | `webstorm ~/.local/share/chezmoi`               | Open dotfiles in WebStorm                            |
| `dotfilesf`  | `webstorm ~/.config/fish`                       | Open fish config in WebStorm                         |
| `..`         | `cd ../`                                        | Navigate up one directory (via multicd function)     |
| `...`        | `cd ../../`                                     | Navigate up two directories (via multicd function)   |
| `....`       | `cd ../../../`                                  | Navigate up three directories (via multicd function) |

#### Chezmoi

| Abbreviation | Command                              | Description                        |
| ------------ | ------------------------------------ | ---------------------------------- |
| `czm`        | `chezmoi`                            | Shortcut for chezmoi               |
| `czmcd`      | `chezmoi cd`                         | Change to chezmoi source directory |
| `czma`       | `chezmoi apply`                      | Apply chezmoi changes              |
| `czmadd`     | `chezmoi add`                        | Add a file to chezmoi              |
| `czmradd`    | `chezmoi re-add`                     | Re-add a file to chezmoi           |
| `czmi`       | `chezmoi init`                       | Initialize chezmoi                 |
| `czmu`       | `chezmoi update`                     | Update chezmoi                     |
| `czmvc`      | `bat ~/.config/chezmoi/chezmoi.yaml` | View chezmoi config                |

#### Git

| Abbreviation | Command                       | Description                               |
| ------------ | ----------------------------- | ----------------------------------------- |
| `g`          | `git`                         | Shortcut for git                          |
| `gaa`        | `git add -A .`                | Add all changes                           |
| `gdd`        | `git add -A .`                | Add all changes (alias)                   |
| `gadd`       | `git add -A .`                | Add all changes (alias)                   |
| `gc`         | `git commit`                  | Commit changes                            |
| `gcm`        | `git commit -m "%"`           | Commit with message (cursor at %)         |
| `gcmc`       | `git commit -m "chore: %"`    | Commit chore with message                 |
| `gcmr`       | `git commit -m "refactor: %"` | Commit refactor with message              |
| `gcmf`       | `git commit -m "feat: %"`     | Commit feature with message               |
| `gcmi`       | `git commit -m "fix: %"`      | Commit fix with message                   |
| `gcmt`       | `git commit -m "test: %"`     | Commit test with message                  |
| `gcma`       | `git commit --amend`          | Amend previous commit                     |
| `gco`        | `git checkout`                | Checkout branch                           |
| `gcod`       | `git checkout develop`        | Checkout develop branch                   |
| `gcom`       | `git checkout main`           | Checkout main branch                      |
| `gsw`        | `git switch`                  | Switch branch                             |
| `gswd`       | `git switch develop`          | Switch to develop branch                  |
| `gswm`       | `git switch main`             | Switch to main branch                     |
| `gmod`       | `git merge origin/develop`    | Merge origin/develop                      |
| `gmom`       | `git merge origin/main`       | Merge origin/main                         |
| `grod`       | `git rebase origin/develop`   | Rebase on origin/develop                  |
| `grom`       | `git rebase origin/main`      | Rebase on origin/main                     |
| `gd`         | `git d`                       | Git diff (custom alias)                   |
| `gs`         | `git s`                       | Git status (custom alias)                 |
| `gp`         | `git push`                    | Push changes                              |
| `gpl`        | `git pull`                    | Pull changes                              |
| `gpf`        | `git pf`                      | Force push (custom alias)                 |
| `gpfr`       | `git pfr`                     | Force push with lease (custom alias)      |
| `gdg`        | `git del-gone`                | Delete gone branches                      |
| `gcbn`       | `git copy-branch-name`        | Copy branch name to clipboard             |
| `gumd`       | `git up-merge-develop`        | Fetch develop, merge origin/develop       |
| `gumm`       | `git up-merge-main`           | Fetch main, merge origin/main             |
| `gumb`       | `git up-merge-branch`         | Fetch branch, merge origin/<branch>       |
| `gurd`       | `git up-rebase-develop`       | Fetch develop, rebase onto origin/develop |
| `gurm`       | `git up-rebase-main`          | Fetch main, rebase onto origin/main       |
| `gurb`       | `git up-rebase-branch`        | Fetch branch, rebase onto origin/<branch> |
| `gud`        | `git update-develop`          | Fetch develop (refresh origin/develop)    |
| `lzg`        | `lazygit`                     | Launch lazygit                            |

#### GitHub CLI

| Abbreviation | Command                                          | Description                           |
| ------------ | ------------------------------------------------ | ------------------------------------- |
| `ghw`        | `gh repo view --web`                             | Open repository in web browser        |
| `ghpr`       | `gh pr create -a "@me" --fill`                   | Create a PR assigned to yourself      |
| `ghm`        | `gh pr merge % --merge`                          | Merge PR (cursor at %)                |
| `ghr`        | `gh release create v% --generate-notes --latest` | Create release (cursor at %)          |
| `ghcs`       | `gh copilot suggest "%"`                         | Get Copilot suggestion (cursor at %)  |
| `ghce`       | `gh copilot explain "%"`                         | Get Copilot explanation (cursor at %) |

#### Docker

| Abbreviation | Command                                  | Description                |
| ------------ | ---------------------------------------- | -------------------------- |
| `dspall`     | `docker system prune --all --volumes -f` | Prune all Docker resources |
| `lzd`        | `lazydocker`                             | Launch lazydocker          |

#### Yazi

| Abbreviation | Command | Description                                    |
| ------------ | ------- | ---------------------------------------------- |
| `y`          | `yazi`  | Launch yazi (Fish function; Zsh/Bash function) |
| `yy`         | —       | Yazi with cwd on exit (Fish/Zsh/Bash function) |

#### Package Managers

| Abbreviation | Command                             | Description                             |
| ------------ | ----------------------------------- | --------------------------------------- |
| `bi`         | `brew install`                      | Install package with Homebrew           |
| `binfo`      | `brew info`                         | Show package info with Homebrew         |
| `brews`      | `brew list`                         | List installed Homebrew packages        |
| `casks`      | `brew list --cask`                  | List installed Homebrew casks           |
| `ni`         | `npm install`                       | Install npm package                     |
| `nis`        | `npm install --save`                | Install and save npm package            |
| `nisd`       | `npm install --save-dev`            | Install and save npm dev package        |
| `nr`         | `npm run`                           | Run npm script                          |
| `nrs`        | `npm run start`                     | Run npm start script                    |
| `nrsd`       | `npm run start:dev`                 | Run npm start:dev script                |
| `nrt`        | `npm run test`                      | Run npm test script                     |
| `nrtc`       | `npm run test:coverage`             | Run npm test coverage script            |
| `nrc`        | `npm run coverage`                  | Run npm coverage script                 |
| `nrb`        | `npm run build`                     | Run npm build script                    |
| `nru`        | `npm run update`                    | Run npm update script                   |
| `nrdd`       | `npm-run-deploy-dev`                | Run npm deploy dev script               |
| `nout`       | `npm outdated`                      | Show outdated npm packages              |
| `nup`        | `npm update`                        | Update npm packages                     |
| `nupg`       | `npm upgrade`                       | Upgrade npm packages                    |
| `nrm`        | `npm uninstall`                     | Uninstall npm package                   |
| `npb`        | `npm publish`                       | Publish npm package                     |
| `npbb`       | `npm publish --tag beta`            | Publish npm package with beta tag       |
| `nls`        | `npm ls`                            | List npm packages                       |
| `nver`       | `npm version`                       | Show npm version                        |
| `ncache`     | `npm cache clean --force`           | Clean npm cache                         |
| `nsv`        | `npm show % versions`               | Show npm package versions (cursor at %) |
| `nrsb`       | `npm run storybook`                 | Run npm storybook script                |
| `nxsva`      | `npx standard-version --release-as` | Run standard-version                    |
| `nrd`        | `npm run dev`                       | Run npm dev script                      |

#### Maven

| Abbreviation | Command                          | Description                        |
| ------------ | -------------------------------- | ---------------------------------- |
| `mc`         | `mvn clean`                      | Maven clean                        |
| `mco`        | `mvn compile`                    | Maven compile                      |
| `mp`         | `mvn package`                    | Maven package                      |
| `mi`         | `mvn install`                    | Maven install                      |
| `mt`         | `mvn test`                       | Maven test                         |
| `mci`        | `mvn clean install`              | Maven clean install                |
| `mcist`      | `mvn clean install -DskipTests`  | Maven clean install skipping tests |
| `mcp`        | `mvn clean package`              | Maven clean package                |
| `mct`        | `mvn clean test`                 | Maven clean test                   |
| `mcv`        | `mvn clean verify`               | Maven clean verify                 |
| `mup`        | `mvn versions:update-properties` | Maven update properties            |
| `mdu`        | `mvn dependency:unresolve`       | Maven unresolve dependencies       |
| `msa`        | `mvn spotless:apply`             | Maven spotless apply               |
| `msc`        | `mvn spotless:check`             | Maven spotless check               |
| `msct`       | `mvn spotless:apply clean test`  | Maven spotless apply, clean, test  |

#### Tmux

| Abbreviation | Command                | Description                  |
| ------------ | ---------------------- | ---------------------------- | -------------------- | -------------------------------------------- |
| `amux`       | `tmux at -t base`      | Attach to base tmux session  |
| `tkill`      | `tmux kill-session -t` | Kill tmux session            |
| `nmux`       | `tmux new -s "base"`   | Create new base tmux session |
| `stmux`      | `tmux -2 attach        |                              | tmux -2 new-session` | Attach to tmux or create new session         |
| `st`         | `tmux -2 attach        |                              | tmux -2 new-session` | Attach to tmux or create new session (alias) |

#### Shells

| Abbreviation | Command                 | Description          |
| ------------ | ----------------------- | -------------------- |
| `usebash`    | `chsh -s $(which bash)` | Switch to bash shell |
| `usezsh`     | `chsh -s $(which zsh)`  | Switch to zsh shell  |
| `usefish`    | `chsh -s $(which fish)` | Switch to fish shell |

#### Rust/Cargo

| Abbreviation | Command                   | Description                     |
| ------------ | ------------------------- | ------------------------------- |
| `rtup`       | `rustup update`           | Update Rust                     |
| `cgr`        | `cargo run`               | Run Cargo project               |
| `cgt`        | `cargo test`              | Test Cargo project              |
| `cgb`        | `cargo build`             | Build Cargo project             |
| `cgbi`       | `cargo build --release`   | Build Cargo project for release |
| `cgc`        | `cargo check`             | Check Cargo project             |
| `cgu`        | `cargo update`            | Update Cargo dependencies       |
| `cgs`        | `cargo search`            | Search Cargo packages           |
| `cgin`       | `cargo install`           | Install Cargo package           |
| `cga`        | `cargo add`               | Add Cargo dependency            |
| `cgup`       | `cargo install-update -a` | Update all Cargo packages       |

#### Nix

| Abbreviation              | Command                                                                                                        | Description              |
| ------------------------- | -------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `nix-flake-up`            | `nix flake update --flake ~/.config/nix-config`                                                                | Update Nix flake         |
| `nix-config-up`           | `git -C ~/.config/nix-config pull && sudo darwin-rebuild switch --flake ~/.config/nix-config#{$hostname}`      | Update Nix config        |
| `nix-config-test`         | `git -C ~/.config/nix-config pull && sudo darwin-rebuild switch --flake ~/.config/nix-config#{$hostname}-test` | Test Nix config          |
| `nix-profile-update`      | `nix profile upgrade --all`                                                                                    | Update Nix profile       |
| `nix-channel-update`      | `nix-channel --update`                                                                                         | Update Nix channel       |
| `nix-determinate-upgrade` | `sudo determinate-nixd upgrade`                                                                                | Upgrade determinate-nixd |

#### Miscellaneous

| Abbreviation           | Command                                                                                               | Description                 |
| ---------------------- | ----------------------------------------------------------------------------------------------------- | --------------------------- | ---------------------- |
| `cl`                   | `clear`                                                                                               | Clear terminal              |
| `dup`                  | `du -h --max-depth=1                                                                                  | sort`                       | Show disk usage sorted |
| `df`                   | `df -h`                                                                                               | Show disk free space        |
| `watch`                | `watch -c`                                                                                            | Watch command with color    |
| `print-colors-palette` | `for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+"\n"}; done` | Print color palette         |
| `t`                    | `tail -f`                                                                                             | Tail file with follow       |
| `ag`                   | `antigravity-ide`                                                                                     | Launch antigravity          |
| `sw`                   | `clock-rs -c cyan stopwatch`                                                                          | Start a cyan stopwatch      |
| `opsignin`             | `eval (op signin)`                                                                                    | Sign in to 1Password        |
| `op-create`            | `f(){ op create document $1 --tags chezmoi --title $1;  unset -f f; }; f`                             | Create 1Password document   |
| `gpg-kill-agent`       | `gpgconf --kill gpg-agent`                                                                            | Kill GPG agent              |
| `ij`                   | `idea`                                                                                                | Open IntelliJ IDEA          |
| `ws`                   | `webstorm`                                                                                            | Open WebStorm               |
| `rr`                   | `rustrover`                                                                                           | Open RustRover              |
| `fzfp`                 | `fzf --preview "bat --style=numbers --color=always --line-range :500 {}"`                             | FZF with preview            |
| `fzftp`                | `fzf-tmux --preview "bat --style=numbers --color=always --line-range :500 {}"`                        | FZF with tmux and preview   |
| `vim`                  | `lvim`                                                                                                | Use LunarVim instead of vim |

### Fish Functions

| Function                     | Description                                                                        |
| ---------------------------- | ---------------------------------------------------------------------------------- |
| `multicd`                    | Converts multiple dots into cd commands with the appropriate number of "../" paths |
| `multicd2`                   | Similar to multicd but for "cd.." syntax                                           |
| `y`                          | Alias-style wrapper for yazi (`alias y=yazi`)                                      |
| `yy`                         | Wrapper for the yazi file manager that allows changing the current directory       |
| `ls`                         | Wrapper for eza (modern ls replacement) that falls back to standard ls             |
| `clear_fish_welcome_message` | Clears the fish welcome message                                                    |
| `fish_customization_setup`   | Sets up fish customizations                                                        |
| `fish_user_key_bindings`     | Sets up custom key bindings for fish                                               |
| `has_aws_token_expired`      | Checks if AWS token has expired                                                    |
| `install-fisher`             | Installs the Fisher package manager for fish                                       |
| `install-rust`               | Installs Rust                                                                      |
| `my_fish_setup`              | Sets up fish shell                                                                 |
| `setup-fifc-fzf`             | Sets up FIFC and FZF integration                                                   |

## Bash Shell

### Bash Aliases

#### File System Navigation

| Alias      | Command                        | Description                   |
| ---------- | ------------------------------ | ----------------------------- | ----- | --------------------------------------- |
| `cd..`     | `cd ..`                        | Navigate up one directory     |
| `cd...`    | `cd ../..`                     | Navigate up two directories   |
| `cd....`   | `cd ../../..`                  | Navigate up three directories |
| `cd.....`  | `cd ../../../..`               | Navigate up four directories  |
| `cd......` | `cd ../../../../..`            | Navigate up five directories  |
| `..`       | `cd ..`                        | Navigate up one directory     |
| `...`      | `cd ../..`                     | Navigate up two directories   |
| `....`     | `cd ../../..`                  | Navigate up three directories |
| `.....`    | `cd ../../../..`               | Navigate up four directories  |
| `......`   | `cd ../../../../..`            | Navigate up five directories  |
| `-`        | `\_\_dircycle_update_cycled +1 |                               | true` | Navigate to previous directory in stack |
| `+`        | `\_\_dircycle_update_cycled -0 |                               | true` | Navigate to next directory in stack     |

#### Directory Listing

| Alias | Command   | Description                                     |
| ----- | --------- | ----------------------------------------------- |
| `lsa` | `ls -lah` | List all files with human-readable sizes        |
| `l`   | `ls -lah` | List all files with human-readable sizes        |
| `ll`  | `ls -lah` | List all files with human-readable sizes        |
| `la`  | `ls -lAh` | List almost all files with human-readable sizes |

#### Chezmoi

| Alias              | Command                                        | Description                      |
| ------------------ | ---------------------------------------------- | -------------------------------- |
| `dotfiles`         | `code ${HOME}/.local/share/chezmoi`            | Open dotfiles in VS Code         |
| `dotfiles-applied` | `code ${HOME}/.config/dotfiles`                | Open applied dotfiles in VS Code |
| `upchezmoi-fetch`  | `chezmoi git pull -- --rebase && chezmoi diff` | Update chezmoi and show diff     |
| `upchezmoi`        | `chezmoi update`                               | Update chezmoi                   |

#### Git

| Alias            | Command                                     | Description          |
| ---------------- | ------------------------------------------- | -------------------- |
| `bfg`            | `java -jar ${HOME}/bin/git-scripts/bfg.jar` | Run BFG Repo Cleaner |
| `gpg-kill-agent` | `gpgconf --kill gpg-agent`                  | Kill GPG agent       |

#### Docker

| Alias    | Command                                  | Description                |
| -------- | ---------------------------------------- | -------------------------- |
| `dspall` | `docker system prune --all --volumes -f` | Prune all Docker resources |

#### Package Managers

| Alias        | Command                                                                                | Description              |
| ------------ | -------------------------------------------------------------------------------------- | ------------------------ |
| `pipupdate`  | `pip freeze --local \| grep -v '^\-e' \| cut -d = -f 1  \| xargs -n1 pip install -U`   | Update all pip packages  |
| `pip3update` | `pip3 freeze --local \| grep -v '^\-e' \| cut -d = -f 1  \| xargs -n1 pip3 install -U` | Update all pip3 packages |

#### NPM

| Alias | Command       | Description        |
| ----- | ------------- | ------------------ |
| `nrd` | `npm run dev` | Run npm dev script |

#### Tmux

| Alias   | Command                                   | Description                          |
| ------- | ----------------------------------------- | ------------------------------------ |
| `tm`    | `start_tmux`                              | Start tmux                           |
| `stmux` | `tmux -2 attach \|\| tmux -2 new-session` | Attach to tmux or create new session |

#### Miscellaneous

| Alias                  | Command                                                                                               | Description                            |
| ---------------------- | ----------------------------------------------------------------------------------------------------- | -------------------------------------- |
| `opsignin`             | `eval $(op signin)`                                                                                   | Sign in to 1Password                   |
| `asdfupdate`           | `asdf update && asdf plugin update --all && asdf-install-plugins`                                     | Update asdf and all plugins            |
| `upprecleanup`         | `echo "No cleanup"`                                                                                   | Placeholder for cleanup before updates |
| `osupdate`             | `echo "osupdate: OS not supported"`                                                                   | OS-specific update command             |
| `upall`                | `asdfupdate && upchezmoi && upprecleanup && upzshplugin && osupdate`                                  | Update everything                      |
| `print-colors-palette` | `for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+"\n"}; done` | Print color palette                    |
| `t`                    | `tail -f`                                                                                             | Tail file with follow                  |
| `ag`                   | `antigravity-ide`                                                                                     | Launch antigravity                     |
| `sudo`                 | `sudo `                                                                                               | Allow aliases with sudo                |
| `dup`                  | `du -h --max-depth=1 \| sort`                                                                         | Show disk usage sorted                 |
| `df`                   | `df -h`                                                                                               | Show disk free space                   |
| `watch`                | `watch -c`                                                                                            | Watch command with color               |
| `openports`            | `lsof -i`                                                                                             | Show open ports                        |
| `fzfp`                 | `fzf --preview "bat --style=numbers --color=always --line-range :500 {}"`                             | FZF with preview                       |
| `fzftp`                | `fzf-tmux --preview "bat --style=numbers --color=always --line-range :500 {}"`                        | FZF with tmux and preview              |
| `op-create`            | `f(){ op create document $1 --tags chezmoi --title $1;  unset -f f; }; f`                             | Create 1Password document              |

## Zsh Shell

### Zsh Aliases

Zsh includes all the Bash aliases plus the following:

#### Zsh-specific

| Alias            | Command                                              | Description                         |
| ---------------- | ---------------------------------------------------- | ----------------------------------- |
| `zsh-clean-comp` | `rm -rf ~/.zcompcache ~/.zcompdump*`                 | Clean zsh completion cache          |
| `upprecleanup`   | `{ zsh-clean-comp \|\| true }`                       | Clean zsh completion before updates |
| `zsh-speedtest`  | `for i in $(seq 1 10); do time zsh -i -c exit; done` | Test zsh startup speed              |
| `zsh-refresh`    | `zstyle \":completion:*:commands\" rehash 1`         | Refresh zsh completions             |

### Zsh Functions

| Function                   | Description                               |
| -------------------------- | ----------------------------------------- |
| `__dircycle_update_cycled` | Cycles through the directory stack        |
| `__sudo`                   | Adds sudo to the beginning of the command |
| `@shexit`                  | Handles shell exit                        |
| `d`                        | Directory navigation helper               |
| `fix_zsh_insecure`         | Fixes zsh insecure directory warnings     |
| `fp`                       | Find and list processes                   |
| `get_os`                   | Gets the current OS                       |
| `history-stat`             | Shows command history statistics          |
| `is_archlinux`             | Checks if the system is Arch Linux        |
| `is_cygwin`                | Checks if the system is Cygwin            |
| `is_osx`                   | Checks if the system is macOS             |
| `is_ubuntu`                | Checks if the system is Ubuntu            |
| `prompt_term_program_p10k` | Sets up Powerlevel10k prompt              |
| `start_tmux`               | Starts tmux if not already running        |
| `zicompinit_fast`          | Fast initialization of zsh completion     |
| `zinit_cleanup`            | Cleans up zinit plugins                   |

## Scripts

### General Scripts

| Script                         | Description                             |
| ------------------------------ | --------------------------------------- |
| `brewup`                       | Updates Homebrew packages               |
| `fix-zsh-insecure`             | Fixes zsh insecure directory warnings   |
| `osupdate.tmpl`                | OS-specific update script template      |
| `setup-atuin`                  | Sets up Atuin shell history             |
| `setup-claude-code`            | Sets up Claude Code CLI & configuration |
| `setup-dotfiles-repo-url`      | Sets up dotfiles repository URL         |
| `show-zsh-startup-files-order` | Shows the order of zsh startup files    |
| `upall.tmpl`                   | Updates everything (template)           |

### Git Scripts

| Script                    | Description                                         |
| ------------------------- | --------------------------------------------------- |
| `git-amend`               | Amends the previous commit                          |
| `git-copy-branch-name`    | Copies the current branch name to the clipboard     |
| `git-delete-gone-branch`  | Deletes branches that no longer exist on the remote |
| `git-delete-local-merged` | Deletes local branches that have been merged        |
| `git-normalize-eol.sh`    | Normalizes line endings in git repository           |
| `git-update-dirs`         | Updates multiple git repositories                   |
| `git-wtf`                 | Displays the state of your repository               |

### GPG Scripts

| Script               | Description                       |
| -------------------- | --------------------------------- |
| `gpg-backup`         | Backs up GPG keys                 |
| `gpg-download-op`    | Downloads GPG keys from 1Password |
| `gpg-restore-backup` | Restores GPG keys from backup     |
| `gpg-upload-op`      | Uploads GPG keys to 1Password     |
