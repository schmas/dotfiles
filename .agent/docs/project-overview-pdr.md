# Project Overview & PDR

Product intent, principles, and constraints for this dotfiles repository. This
is a WHY document — it records rationale that the source cannot express. For
what and how, read the code it points to.

## Purpose

Reproduce one developer's shell, terminal, and tooling environment on any fresh
macOS or Linux/WSL machine with a single, idempotent `chezmoi apply`, with all
secrets sourced from 1Password rather than committed.

## Goals

- **One source of truth per concern.** Environment variables, `PATH` entries,
  aliases, and packages each have exactly one owner shared across shells.
- **Cross-shell parity.** Fish, Zsh, and Bash expose the same behavior so the
  active shell never changes muscle memory.
- **Reproducible bootstrap.** A new machine reaches a working state from the
  bootstrap gists plus `chezmoi apply`, without manual per-tool setup.
- **Secrets out of the repo.** Credentials resolve at apply time from 1Password
  templates; the repository is safe to publish.

## Non-goals

- Not a general-purpose or multi-user framework — it encodes personal choices.
- Not a package manager. Homebrew owns packages via the Brewfile.
- The `docs/` tree and `README.md` are repo-only references, deliberately
  excluded from apply (see `home/.chezmoiignore`); they never land in `$HOME`.

## Design principles

DRY over KISS over cleverness. The concrete expressions of these principles —
the load-order convention, the centralized env/path files, the plugin-manager
split, and the cross-platform gating — are described in
[System Architecture](./system-architecture.md), and the rules that keep them
consistent live in [Code Standards](./code-standards.md).

## Profiles

`chezmoi init` prompts for a profile that gates which machine setup applies. The
prompt currently offers **default** (full workstation) and **server** (minimal);
additional flags (`is_p_ct`, `is_p_aaa`, `is_p_csaa`) exist in the data model for
specialized machines but are not offered as prompt choices. The prompt list and
every derived flag are owned by `home/.chezmoi.yaml.tmpl` — treat that file as
authoritative over any enumeration in prose.

## Terminology

- **Source vs target** — `home/` (the `.chezmoiroot`) is the source; `$HOME` is
  the applied target.
- **Profile** — a machine class selected at init that toggles setup scripts.
- **External** — an artifact fetched at apply time rather than stored in the
  repo (see `home/.chezmoiexternal.toml`).

## Constraints

- 1Password (desktop app + CLI, unlocked) must be reachable during apply; on WSL
  it is bridged from the Windows app. See [Deployment Guide](./deployment-guide.md).
- Supported targets: macOS and Linux, including Ubuntu on WSL.

Related repositories and their status are listed in the root
[README](../README.md#related-repositories); open questions are tracked in the
[Project Roadmap](./project-roadmap.md).
