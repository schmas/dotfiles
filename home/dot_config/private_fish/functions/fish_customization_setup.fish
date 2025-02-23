function fish_customization_setup
  # remove the default greeting
  set -U fish_greeting ""

  # tide pro
  set --universal tide_git_truncation_length 60
  set --universal tide_right_prompt_items status cmd_duration context jobs direnv node python rustc java php pulumi ruby go gcloud kubectl distrobox toolbox terraform nix_shell crystal elixir zig time
end
