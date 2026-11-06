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
`bin/macos` and `bin/setup-pam-watchid` off Linux, `bin/linux` off macOS,
Karabiner complex modifications and `Library` off Linux — and keeps repo-only
paths out of `$HOME`. This lets one source tree serve every machine class
without per-machine branches in the files themselves.

## Externals

`home/.chezmoiexternal.toml` is the hook for fetching artifacts at apply time
instead of vendoring them. It currently declares **none** — every entry in the
file is commented out. `upall`, the one artifact that used to live here, is now
installed by `home/.chezmoiscripts/01-common/run_once_after_05.5-upall-install.sh.tmpl`
and self-updates thereafter.

## Packs: private chezmoi instances

A pack is a private git repo that is a normal chezmoi source, run as its own
chezmoi instance. Packs hold files that must not be public. The public repo
builds a complete machine alone, names no pack, and never depends on one. A
pack may depend on files the public repo writes.

- Layout per pack `<name>`: source `~/.local/share/chezmoi-<name>`, config
  `~/.config/chezmoi-<name>/chezmoi.toml` with `sourceDir` and its own
  `persistentState` (state file in the same directory). `<name>` is the repo
  name without `.git` and without the `dotfiles-` prefix.
- Commands: `czm` (public, `home/bin/executable_czm`), `czm-<short>` (one pack,
  a script in the pack), `czp` (all instances, `home/bin/executable_czp`). `czp`
  finds packs by directory: a pack counts only if its `chezmoi.toml` exists. An
  optional repo-root `.czp` file (`command=<czm-short>`) names the pack's
  command for `czp list`.
- Order: public first, then packs in name order. One failed instance does not
  stop the others; `czp` exits non-zero and names the failed instances.
- Overlap rule: no two instances manage the same file or symlink target.
  `czp check` compares `chezmoi managed` of every instance. `czp apply` and
  `czp install` stop on a conflict (`install --no-apply` only reports it).
  `czp update` pulls every instance first, then checks, then applies, so an
  overlap that arrives with a pull never applies. Shared directories (`~/bin`, `conf.d`, ...) are not conflicts.

Drop-in points (the public side never names a pack):

| Shared target | Drop-in | Who adds it |
|---|---|---|
| `~/.ssh/config` (unmanaged) | `Include ~/.ssh/config.d/*` above every `Host` block. ssh reads the files in name order and keeps the first value, so the public `00-machine` comes first and pack files must sort after it | public: `etc/ssh_config.template` and the local-files script (adds or moves the Include) |
| `~/.config/git/config` (unmanaged) | `[include] path = ~/.config/git/pack-<name>.gitconfig` | the pack's script, with `git config --file`, only if missing |
| `~/.config/1Password/ssh/agent.toml` | public file is `create_` (written once, never changed), so a pack script can add its `[[ssh-keys]]` block between markers | the pack |
| Brewfile | the pack's own Brewfile and `brew bundle` script | the pack |
| upall | `~/.config/upall/steps.d/chezmoi-<name>.toml` running `czm-<short> update` | the pack |
| worktrunk `post-start` | executables in `~/.config/worktrunk/post-start.d/`, called with `<primary_worktree> <worktree>` | the pack |
| env, PATH | `~/.config/env/*.env`, `~/.config/path/*.path` | the pack |
| `~/bin`, shell `conf.d`, `functions`, `completions` | the pack's own files | the pack |

## Decision ledger

| Decision | Rationale |
|---|---|
| Shared `.env`/`.path` sourced by all shells | Eliminate per-shell env drift |
| Numeric `conf.d` load order | Make inter-module dependencies explicit |
| Fisher for Fish, Sheldon for Zsh+Bash | Idiomatic per-shell plugin management |
| Single Brewfile manifest | One owner for packages across OSes |
| Secrets via 1Password templates | Keep the repo publishable |
| `.chezmoiignore` for platform gating | One tree, many machine classes |
| Packs: private chezmoi instances (`czm`, `czm-<short>`, `czp`) | Keep the repo public and standalone while private files stay in private repos. One instance per repo, so path commands (`add`, `edit`, `forget`) act on one named repo. Scripts, not aliases, so they work in every shell, in scripts, in upall and for agents. `czp check` enforces that no target has two owners |
| Per-machine SSH key on disk (`~/.ssh/id_machine`) for github.com, bitbucket.org, ssh.bitbucket.org, win-dev, and for commit signing | You and unattended agents push, pull, sign and SSH with no 1Password prompt. Each machine has its own key in 1Password vault `Machine` (item from `.chezmoitemplates/machine-key-item`), so a leak revokes one key. All other hosts stay on the 1Password agent. The hosts are in `~/.ssh/config.d/00-machine`, which must sort first in `config.d`: ssh keeps the first value it reads. A pack can add a private host with the same three options (`IdentityFile ~/.ssh/id_machine`, `IdentitiesOnly yes`, `IdentityAgent none`) in its own `~/.ssh/config.d` file. On WSL, `git-ssh-wsl` sends github.com and Bitbucket to Linux ssh and every other host to `ssh.exe`. The machine's public key must be added to the Bitbucket account (Personal settings > SSH keys) |
| Shared SSH keys on disk from a pack | A pack may write host keys that are shared by several machines (not per machine) as plain files, for the same reason as the machine key. Their `Host` blocks go in the pack's `~/.ssh/config.d/` file, with `IdentitiesOnly yes` and `IdentityAgent none`. Host addresses come from 1Password, so they stay out of every repo. The pack documents its own keys |
