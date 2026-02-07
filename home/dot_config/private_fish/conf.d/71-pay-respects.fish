if status --is-interactive
    if type -q pay-respects
        # Use --nocnf to avoid conflict with mise's fish_command_not_found hook
        pay-respects fish --nocnf | source
    end
end
