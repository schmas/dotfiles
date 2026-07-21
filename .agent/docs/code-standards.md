# Code Standards

Engineering conventions and the rules that keep this repo consistent. These are
choices, not descriptions — the reasons a change should or should not be made a
certain way.

## Naming

- **Chezmoi prefixes** follow the tool's conventions (`dot_`, `private_`,
  `executable_`, `symlink_`, `run_*`, `.tmpl`); see
  [chezmoi target types](https://www.chezmoi.io/reference/target-types/).
- **Shell modules** are named `NN-topic.shell[.tmpl]` where `NN` is the load
  order (see [System Architecture](./system-architecture.md#shell-configuration-numeric-load-order)).
  Pick the lowest prefix the module's dependencies allow.
- **New files** use kebab-case unless a language dictates otherwise.

## Adding environment variables or PATH entries

Add them to the shared files, never to a per-shell module:

- Variables → `home/dot_config/private_env/*.env.tmpl`
- `PATH` → `home/dot_config/private_path/*.path.tmpl`

A per-shell definition defeats the centralization and will drift. This is the
single most important rule in the repo.

## Cross-shell parity

Behavior must match across Fish, Zsh, and Bash.

- Zsh and Bash aliases are kept identical (shared templated logic in
  `99-aliases.{zsh,bash}.tmpl`).
- Fish uses abbreviations (`home/dot_config/private_fish/conf.d/10-abbr.fish`).
- When you change an alias, function, or abbreviation, update
  [SHELL-REFERENCE.md](../SHELL-REFERENCE.md) in the same change so the reference
  stays the source of truth for what exists. Keyboard shortcuts live in
  [SHORTCUTS-REFERENCE.md](../SHORTCUTS-REFERENCE.md).

## Templates

Files ending `.tmpl` are Go `text/template`, evaluated at apply time. Branch on
the gates owned by `home/.chezmoi.yaml.tmpl`:

- OS: `{{ if eq .chezmoi.os "darwin" }}…{{ end }}`
- Profile: `{{ if .is_p_default }}…{{ end }}`
- Secret: `{{ onepasswordRead "op://vault/item/field" }}`

Debug output with `chezmoi execute-template < path/to/file.tmpl`. Shared template
snippets live in `home/.chezmoitemplates/`.

## Security

- Secrets resolve **only** from 1Password templates. Never commit tokens, keys,
  dotenv files, or credentials — not even placeholder values that look real.
- Content that must stay in the repo but never reach `$HOME` (references,
  snapshots) belongs in `home/.chezmoiignore`.
- 1Password must be unlocked during apply; on WSL secrets bridge to the Windows
  app (see [Deployment Guide](./deployment-guide.md)).

## Local overrides

Never edit applied files on a single machine to customize it. Each shell sources
an untracked local file for machine-specific tweaks:

- Fish → `~/.config/fish/config_local.fish`
- Zsh → `~/.config/zsh/zshrc_local`
- Bash → `~/.config/bash/bashrc_local`

## Commits

Conventional Commits with a scope: `feat(fish): …`, `fix(git): …`, `docs: …`.
Keep each commit focused on one type/scope. No AI-authorship references in
messages.
