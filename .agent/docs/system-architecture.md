# System Architecture

Current boundaries and the decisions behind them. This document points to the
executable owners of each concern; it does not restate their contents. Verify
any claim here against the file it names.

## Source model

The repo-root `.chezmoiroot` file names `home/` as the chezmoi source root. Filename prefixes
(`dot_`, `private_`, `executable_`, `symlink_`, `run_*`) and the `.tmpl` suffix
follow chezmoi's own conventions; see the
[chezmoi reference](https://www.chezmoi.io/reference/target-types/). Templates
resolve OS, profile, and secrets at apply time.

## Shell configuration: numeric load order

Each shell loads ordered modules from its `conf.d/` directory
(`home/dot_config/private_{fish,zsh,bash}/conf.d/`). The numeric prefix encodes
dependency order, not preference:

| Prefix | Responsibility |
|---|---|
| `00` | Plugin-manager and Homebrew shellenv bootstrap |
| `05` | Source the shared env/path files (below) |
| `10` | Common env, abbreviations/colors |
| `20` | OS-specific env (`darwin` / `linux`) |
| `49`–`50` | Readline input, completions |
| `70` | Tool init (Starship, Zellij, Worktrunk, Yazi) |
| `98` | Sheldon (Zsh/Bash) |
| `99` | Aliases (Zsh/Bash, templated) |
| `zzz` | Late load — Mise, FZF, Atuin, Television |

The invariant that makes this work: nothing may depend on a module with an equal
or higher prefix. New modules take the lowest prefix their dependencies allow.

## Centralized env and path (the core DRY decision)

Environment variables and `PATH` entries are defined **once**, shell-agnostically,
and consumed by all three shells:

- Owners: `home/dot_config/private_env/*.env.tmpl` →`~/.config/env/` and
  `home/dot_config/private_path/*.path.tmpl` →`~/.config/path/`.
- Consumers: each shell's `05-shared-env.*` / `05-shared-path.*` module sources
  every file in those directories at startup.

**Why:** three per-shell copies of the same exports drift. A single POSIX-ish
`.env`/`.path` set sourced everywhere means a new variable is added in one place
and is immediately live in Fish, Zsh, and Bash. Add shared vars to these files,
never to a per-shell module.

## Profile and OS resolution

`home/.chezmoi.yaml.tmpl` runs the init prompts and derives every gate the rest
of the repo branches on: `profile`, the `is_p_*` flags, `os_id`/`os_id_like`,
and `is_wsl` (Linux kernel reporting "microsoft"). All conditional apply logic
reads these — this file is the single decision point for machine shape.

## Plugin managers (deliberately split)

- **Fish** uses Fisher; plugin list in `home/dot_config/private_fish/fish_plugins`.
- **Zsh and Bash** share Sheldon; plugin lists in
  `home/dot_config/private_{zsh,bash}/etc/sheldon/plugins.toml`.

**Why two:** Fish's plugin ecosystem is Fisher-native, while Sheldon gives Zsh
and Bash one declarative TOML manager. Each shell uses the manager idiomatic to
it rather than forcing a lowest common denominator.

## Package management

`home/dot_config/etc/Brewfile.tmpl` is the single package manifest (brews +
casks, templated per OS/profile). Setup scripts install from it; nothing else
tracks packages.

## Install-script pipeline

`home/.chezmoiscripts/` holds the apply-time scripts, split by phase:

- `00-run-before/` — runs before files are written: 1Password configuration,
  Homebrew install, and the Brewfile package install (`run_onchange`, so it
  re-runs only when the Brewfile changes).
- `01-common/` — runs after files are written: macOS defaults and Touch/Watch-ID
  sudo, Mise, Fisher, Claude tooling, Linux system setup, launchd agents, and
  more.

The directory is the authoritative list — read it rather than relying on an
enumeration here. Run intent is encoded in each script's `run_once` /
`run_onchange` prefix.

## Cross-platform gating

`home/.chezmoiignore` excludes files that do not apply to the current target —
`bin/macos` off Linux, `bin/linux` off macOS, Karabiner assets off Linux,
Claude skills when `claude` is absent — and keeps repo-only docs
(`README.md`, `docs/`) out of `$HOME`. This lets one source tree serve every
machine class without per-machine branches in the files themselves.

## Externals

`home/.chezmoiexternal.toml` fetches artifacts at apply time instead of vendoring
them — currently the `upall` Go updater from its GitHub release, refreshed every
168h (`chezmoi apply --refresh-externals` to force).

## Decision ledger

| Decision | Rationale |
|---|---|
| Shared `.env`/`.path` sourced by all shells | Eliminate per-shell env drift |
| Numeric `conf.d` load order | Make inter-module dependencies explicit |
| Fisher for Fish, Sheldon for Zsh+Bash | Idiomatic per-shell plugin management |
| Single Brewfile manifest | One owner for packages across OSes |
| Secrets via 1Password templates | Keep the repo publishable |
| `.chezmoiignore` for platform gating | One tree, many machine classes |
