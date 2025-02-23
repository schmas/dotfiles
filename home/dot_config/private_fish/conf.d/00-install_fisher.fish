if status is-interactive
    if not type --quiet "fisher"
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
        fisher update
    end
end
