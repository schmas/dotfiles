# Project Roadmap & Status

> **Stateful record, not evergreen authority.** This file captures open
> questions and intended direction at a point in time. It goes stale by design —
> do not treat it as the source of truth for how the repo currently behaves. For
> that, read the code and the other `docs/` files it links to.

## Open questions

These are unresolved decisions, carried forward from the root README's
"Unresolved Questions". Each needs a call, not documentation:

- **Atuin sync** — whether shell history syncs across machines, and if so through
  which backend. Config owner: `home/dot_config/atuin/`,
  `home/bin/executable_setup-atuin`.
- **Multiplexer** — Zellij vs Tmux. Both are configured
  (`home/dot_config/zellij/`, `home/dot_config/tmux/`); the intent is to settle
  on one default.
- **Specialized profiles** — `ct`, `aaa`, and `csaa` still exist as `is_p_*`
  flags in `home/.chezmoi.yaml.tmpl` but are no longer offered as init choices.
  Decide whether to restore them as prompts, keep them as manual overrides, or
  remove the dead flags.
- **Nix deprecation cleanup** — the `using_nix` init prompt and related branches
  remain even though nix-config is deprecated (migrated to Homebrew). Decide when
  to remove the prompt and its conditionals.
- **Custom fork maintenance** — several tools depend on personal forks
  (`fifc`, `dircolors-neutral`, `nvim_lazy`, `upall`); no defined strategy for
  keeping them current with upstream.

## Recent structural direction

- Documentation was reset (the previous `docs/` tree was removed as outdated) and
  rebuilt as this thin, pointer-based set. Keep docs short and evidence-backed;
  resist re-growing implementation paraphrase.
- Package management is fully on Homebrew via a single Brewfile; nix-config is
  deprecated.
- `upall` moved to an auto-fetched Go binary, with the bash version retained as
  `upall-classic`.

Related repositories and their status live in the root
[README](../README.md#related-repositories).
