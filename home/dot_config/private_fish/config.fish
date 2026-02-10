#!/usr/bin/env fish

# Nix setup
if test -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end

##############################
# DOTFILES
##############################
# meaningful-ooo/sponge: Purge only on exit
set sponge_purge_only_on_exit true

# pay-respects: must load in config.fish (after vendor_conf.d/mise-activate.fish)
if status --is-interactive; and type -q pay-respects
    pay-respects fish | source
end

# load config_local.fish if available
if test -f $__fish_config_dir/config_local.fish
    source $__fish_config_dir/config_local.fish
end
