function install-rust
  if not command -v rustup >/dev/null
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --component rust-analyzer
      source "$HOME/.cargo/env.fish"
  else
      rustup update
  end

  cargo install rust-script cargo-update
  cargo install-update -a
end
