if status is-interactive
    #################
    # Abbreviations #
    #################

    # ls
    abbr --add lag 'la --group-directories-first'
    abbr --add lat 'la --tree --level=2'
    abbr --add lagt 'la --group-directories-first --tree --level=2'

    # 1password
    abbr --add opsignin 'eval (op signin)'
    abbr --add op-create 'f(){ op create document $1 --tags chezmoi --title $1;  unset -f f; }; f'

    # chezmoi
    abbr --add czm chezmoi
    abbr --add czmcd chezmoi cd
    abbr --add czma chezmoi apply
    abbr --add czmadd chezmoi add
    abbr --add czmradd chezmoi re-add
    abbr --add czmi chezmoi init
    abbr --add czmu chezmoi update
    abbr --add czmvc "bat ~/.config/chezmoi/chezmoi.yaml "

    # DOCKER
    abbr --add dspall "docker system prune --all --volumes -f"
    abbr --add lzd lazydocker

    # homebrew
    abbr --add bi 'brew install '
    abbr --add binfo 'brew info'
    abbr --add brews 'brew list'
    abbr --add casks 'brew list --cask'

    # directories
    abbr --add home --position anywhere '~/'
    abbr --add configd --position anywhere '~/.config/'
    abbr --add locald --position anywhere '~/.local/'
    abbr --add fishd --position anywhere '~/.config/fish'
    abbr --add chezmoid --position anywhere '~/.local/share/chezmoi'

    abbr --add dotfiles 'webstorm ~/.local/share/chezmoi'
    abbr --add dotfilesf 'webstorm ~/.config/fish'

    # IDEs
    abbr --add ij idea
    abbr --add ws webstorm
    abbr --add rr rustrover

    # fzf
    abbr --add fzfp 'fzf --preview "bat --style=numbers --color=always --line-range :500 {}"'
    abbr --add fzftp 'fzf-tmux --preview "bat --style=numbers --color=always --line-range :500 {}"'

    # github cli
    abbr --add ghw 'gh repo view --web'
    abbr --add ghpr 'gh pr create -a "@me" --fill'
    abbr --add ghm --set-cursor 'gh pr merge % --merge'
    abbr --add ghr --set-cursor 'gh release create v% --generate-notes --latest'
    abbr --add ghcs --set-cursor 'gh copilot suggest "%"'
    abbr --add ghce --set-cursor 'gh copilot explain "%"'

    # git
    abbr --add g git
    abbr --add gaa 'git add -A .'
    abbr --add gdd 'git add -A .'
    abbr --add gadd 'git add -A .'
    abbr --add gc 'git commit'
    abbr --add gcm --set-cursor 'git commit -m "%"'
    abbr --add gcmc --set-cursor 'git commit -m "chore: %"'
    abbr --add gcmr --set-cursor 'git commit -m "refactor: %"'
    abbr --add gcmf --set-cursor 'git commit -m "feat: %"'
    abbr --add gcmi --set-cursor 'git commit -m "fix: %"'
    abbr --add gcmt --set-cursor 'git commit -m "test: %"'
    abbr --add gcma 'git commit --amend'
    abbr --add gco 'git checkout'
    abbr --add gcod 'git checkout develop'
    abbr --add gcom 'git checkout main'
    abbr --add gsw 'git switch'
    abbr --add gswd 'git switch develop'
    abbr --add gswm 'git switch main'
    abbr --add gmod 'git merge origin/develop'
    abbr --add gmom 'git merge origin/main'
    abbr --add grod 'git rebase origin/develop'
    abbr --add grom 'git rebase origin/main'
    abbr --add gd 'git d'
    abbr --add gs 'git s'
    abbr --add gp 'git push'
    abbr --add gpl 'git pull'
    abbr --add gpf 'git pf'
    abbr --add gpfr 'git pfr'
    abbr --add gdg 'git del-gone'
    abbr --add gcbn 'git copy-branch-name'
    abbr --add gumd 'git up-merge-develop'

    # Git Tools
    abbr --add lzg lazygit

    # gpg
    abbr --add gpg-kill-agent "gpgconf --kill gpg-agent"

    # npm
    abbr --add ni 'npm install'
    abbr --add nis 'npm install --save'
    abbr --add nisd 'npm install --save-dev'
    abbr --add nr 'npm run'
    abbr --add nrs 'npm run start'
    abbr --add nrsd 'npm run start:dev'
    abbr --add nrt 'npm run test'
    abbr --add nrtc 'npm run test:coverage'
    abbr --add nrc 'npm run coverage'
    abbr --add nrb 'npm run build'
    abbr --add nru 'npm run update'
    abbr --add nrdd npm-run-deploy-dev
    abbr --add nout 'npm outdated'
    abbr --add nup 'npm update'
    abbr --add nupg 'npm upgrade'
    abbr --add nrm 'npm uninstall'
    abbr --add npb 'npm publish'
    abbr --add npbb 'npm publish --tag beta'
    abbr --add nls 'npm ls'
    abbr --add nver 'npm version'
    abbr --add ncache 'npm cache clean --force'
    abbr --add nsv --set-cursor 'npm show % versions'
    abbr --add nrsb 'npm run storybook'
    abbr --add nxsva 'npx standard-version --release-as'

    # Maven
    abbr --add mc 'mvn clean'
    abbr --add mco 'mvn compile'
    abbr --add mp 'mvn package'
    abbr --add mi 'mvn install'
    abbr --add mt 'mvn test'
    abbr --add mci 'mvn clean install'
    abbr --add mcist 'mvn clean install -DskipTests'
    abbr --add mcp 'mvn clean package'
    abbr --add mcp 'mvn clean compile'
    abbr --add mct 'mvn clean test'
    abbr --add mcv 'mvn clean verify'
    abbr --add mup 'mvn versions:update-properties'
    abbr --add mdu 'mvn dependency:unresolve'

    abbr --add msa 'mvn spotless:apply'
    abbr --add msc 'mvn spotless:check'
    abbr --add msct 'mvn spotless:apply clean test'

    # Now, .. transforms to cd ../, while ... turns into cd ../../ and .... expands to cd ../../../.
    abbr --add dotdot --regex '^\.\.+$' --function multicd
    abbr --add cddotdot --regex '^cd\.\.+$' --function multicd2

    # tmux
    abbr --add amux 'tmux at -t base'
    abbr --add tkill 'tmux kill-session -t'
    abbr --add nmux 'tmux new -s "base"'
    abbr --add stmux "tmux -2 attach || tmux -2 new-session"
    abbr --add st "tmux -2 attach || tmux -2 new-session"

    if set -q TMUX
        abbr --add clear 'clear; tmux clear-history'
    end

    # vim / lvim
    abbr --add vim lvim

    # shells
    abbr --add usebash 'chsh -s $(which bash)'
    abbr --add usezsh 'chsh -s $(which zsh)'
    abbr --add usefish 'chsh -s $(which fish)'

    # rust/cargo
    abbr --add rtup 'rustup update'

    abbr --add cgr 'cargo run'
    abbr --add cgt 'cargo test'
    abbr --add cgb 'cargo build'
    abbr --add cgbi 'cargo build --release'
    abbr --add cgc 'cargo check'
    abbr --add cgu 'cargo update'
    abbr --add cgs 'cargo search'
    abbr --add cgin 'cargo install'
    abbr --add cga 'cargo add'
    abbr --add cgup 'cargo install-update -a'

    # nix
    abbr --add nix-flake-up 'nix flake update --flake ~/.config/nix-config'
    abbr --add nix-config-up 'git -C ~/.config/nix-config pull && darwin-rebuild switch --flake ~/.config/nix-config#{$hostname}'
    abbr --add nix-config-test 'git -C ~/.config/nix-config pull && darwin-rebuild switch --flake ~/.config/nix-config#{$hostname}-test'
    abbr --add nix-profile-update 'nix profile upgrade --all'
    abbr --add nix-channel-update 'nix-channel --update'

    # misc
    abbr --add cl clear
    abbr --add dup "du -h --max-depth=1 | sort"
    abbr --add df "df -h"
    abbr --add watch "watch -c"
    abbr --add print-colors-palette 'for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+"\n"}; done'
    abbr --add t 'tail -f'

    #  abbr --add atm neofetch
    #  # abbr --add cls '$DROPBOX/Clients'
    #  abbr --add co 'code-insiders '
    #  abbr --add con 'code-insiders -n .'
    #  abbr --add cargos 'cargo install --list'
    #  abbr --add coo 'code-insiders -r .'
    #  abbr --add dls '~/Downloads/'
    #  abbr --add gems 'gem list'
    #  abbr --add gg 'go get GITHUB_URL'
    #  abbr --add goo 'cd ~/.go/'
    #  abbr --add npms 'npm list -g --depth=0'
    #  abbr --add pns 'pnpm list -g'
    #  abbr --add pnpms 'pnpm list -g'
    #  abbr --add buns 'bun pm ls -g'
    #  abbr --add siz 'du -khsc'
    #  abbr --add sp speedtest
    #  abbr --add grabit 'wget -mkEpnp url_here'
    #  abbr --add link 'ln -s'
    #  abbr --add symlink 'ln -s'
    #  abbr --add wrg wrangler
    #  abbr --add usebash 'chsh -s $(which bash)'
    #  abbr --add usezsh 'chsh -s $(which zsh)'
    #  abbr --add upp topgrade
end
