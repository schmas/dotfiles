# Completions for aaa-remote-services-tunnel
complete -c aaa-remote-services-tunnel -f # -f: no file completion

# Top-level commands (only when no subcommand chosen yet)
complete -c aaa-remote-services-tunnel -n __fish_use_subcommand -a sync    -d "rsync bind-mount dirs to win-dev"
complete -c aaa-remote-services-tunnel -n __fish_use_subcommand -a tunnel  -d "open SSH tunnels in foreground (Ctrl+C to close)"
complete -c aaa-remote-services-tunnel -n __fish_use_subcommand -a service -d "manage the self-healing background tunnel"
complete -c aaa-remote-services-tunnel -n __fish_use_subcommand -a all     -d "sync then tunnel (foreground) [default]"
complete -c aaa-remote-services-tunnel -n __fish_use_subcommand -a help    -d "show usage"

# `service` subcommands (only after `service`, and not once one is chosen)
set -l svc_seen "__fish_seen_subcommand_from service; and not __fish_seen_subcommand_from up start stop restart status logs"
complete -c aaa-remote-services-tunnel -n "$svc_seen" -a up      -d "sync, then start the background tunnel"
complete -c aaa-remote-services-tunnel -n "$svc_seen" -a start   -d "start self-healing background tunnel (not on reboot)"
complete -c aaa-remote-services-tunnel -n "$svc_seen" -a stop    -d "stop the background tunnel"
complete -c aaa-remote-services-tunnel -n "$svc_seen" -a restart -d "restart the background tunnel"
complete -c aaa-remote-services-tunnel -n "$svc_seen" -a status  -d "show running state"
complete -c aaa-remote-services-tunnel -n "$svc_seen" -a logs    -d "show recent tunnel log"
