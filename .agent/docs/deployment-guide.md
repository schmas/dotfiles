# Deployment & Installation Guide

Operational runbook: how a machine is provisioned, what runs during apply, and
how to recover when the provider environment (1Password, WSL, sudo) fights back.
The root [README](../README.md#getting-started-5-minutes) holds the copy-paste
quickstart commands; this guide owns the *why* and the troubleshooting.

## Prerequisites

- **1Password** desktop app + CLI, unlocked, with the SSH agent enabled. Secrets,
  git SSH auth, and commit signing all resolve through it at apply time.
- Git and a shell. Everything else is installed by the bootstrap and apply scripts.

## Install routes

Three entry points, all in the README quickstart:

- **Fresh macOS** — one bootstrap gist installs Xcode CLI tools, Homebrew, and
  1Password, pauses for you to enable the 1Password SSH agent, then runs
  `chezmoi init --apply`.
- **Fresh WSL / Ubuntu** — 1Password runs as the Windows app; the Linux `op`
  binary cannot reach it, so a bridge (`op` / `op-ssh-sign` calling `.exe` via
  interop) is installed first. See "WSL interop" below.
- **Existing machine** — `chezmoi init --apply https://github.com/schmas/dotfiles.git`.

The bootstrap scripts themselves live outside this repo (GitHub gists, kept in
sync from `home/bin/executable_sync-bootstrap-gist.sh`); the in-repo copies are
`home/bin/executable_bootstrap-*.sh`.

## Init prompts

`chezmoi init` collects machine shape via `home/.chezmoi.yaml.tmpl`:

- **Profile** — `default` or `server`.
- **NIX-CONFIG** — whether this machine also uses the (deprecated) nix-config.
- **Editor** — `nvim` (default), `zed`, `code`, or `none`.

These answers are written to `~/.config/chezmoi/chezmoi.toml` and gate the rest
of apply. To change them later, re-run `chezmoi init` or edit that file.

## What runs during apply

Apply-time scripts live in `home/.chezmoiscripts/`, in two phases (see
[System Architecture](./system-architecture.md#install-script-pipeline) for the
phase model):

- **before** — 1Password config, Homebrew install, Brewfile package install
  (re-runs only when the Brewfile changes).
- **after** — macOS defaults, Touch/Watch-ID sudo, Mise runtimes, Fisher/Sheldon
  plugins, Claude tooling, Linux setup, launchd agents.

Read the scripts for exact behavior; their `run_once` / `run_onchange` prefix
tells you when each re-runs.

## Externals

`upall` (the Go update TUI) is fetched from its GitHub release via
`home/.chezmoiexternal.toml`, refreshed every 168h. Force a refresh with
`chezmoi apply --refresh-externals`. The `upall-classic` bash fallback ships in
`home/bin/`.

## Updating

```bash
chezmoi status   # preview drift
chezmoi update   # pull remote + apply
upall            # update brew, mise, rust, chezmoi, fisher
```

## Troubleshooting

- **1Password vault access.** The CLI only sees vaults you authorize. If apply
  reads from a non-default vault (e.g. `Dotfiles`), open it in the desktop app →
  Manage → confirm CLI access, then verify with `op vault list`. 1Password must
  be **unlocked** whenever chezmoi runs.
- **WSL interop.** Secrets route through `~/.local/bin/op`, which calls `op.exe`;
  `.chezmoi.yaml.tmpl` sets `onepassword.command` to it when `is_wsl` is true.
  In the Windows 1Password app enable *Integrate with 1Password CLI*, *Use the
  SSH agent*, and Windows Hello. Confirm vaults appear via `op vault list` in WSL
  before bootstrapping.
- **Repeated sudo prompts (Linux/WSL).** Set up temporary passwordless sudo in
  `/etc/sudoers.d/` before apply and remove it afterward.
- **Template output looks wrong.** Debug with
  `chezmoi execute-template < path/to/file.tmpl`.

Known open items about the provisioned environment are tracked in the
[Project Roadmap](./project-roadmap.md).
