# Phase 01: Implement AAA Workspace Script

## Context Links
- [Plan](plan.md)
- [Code Standards](../../docs/code-standards.md)
- Reference script: `home/bin/executable_upall.tmpl`

## Overview
- **Priority:** P2
- **Status:** complete
- **Description:** Create `home/bin/executable_aaa-workspace` bash script with `backup` and `setup` subcommands.

## Key Insights
- Repos hosted on Bitbucket under `aaa-national` org
- SSH alias `bitbucket-aaa` exists in user's SSH config — use for all repos
- data-integration is ~552MB, connect-plus-db is ~6.8GB — tar.gz compression appropriate
- Existing scripts use `set -e`, echo-based progress, simple bash patterns

## Requirements

### Functional
- `aaa-workspace backup`: compress & copy 3 items to backup dir
- `aaa-workspace setup`: clone 3 repos + restore 3 items from backup
- `aaa-workspace` (no args): show usage

### Non-Functional
- Fast feedback — show progress for large compressions
- Fail fast on missing source dirs/files
- Idempotent setup — skip clone if repo dir exists

## Architecture

Single bash script, no dependencies beyond `tar`, `git`, `mise`.

```
aaa-workspace backup
  ├─ Validate source dirs exist
  ├─ mkdir -p backup dir
  ├─ tar czf data-integration.tar.gz
  ├─ tar czf connect-plus-db.tar.gz
  └─ cp mise.toml

aaa-workspace setup
  ├─ mkdir -p workspace dirs
  ├─ git clone (3 repos, skip if exists)
  ├─ Extract data-integration.tar.gz
  ├─ Extract connect-plus-db.tar.gz
  ├─ cp mise.toml
  └─ mise install
```

## Related Code Files

| Action | File |
|--------|------|
| Create | `home/bin/executable_aaa-workspace` |
| Reference | `home/bin/executable_upall.tmpl` (style guide) |

## Implementation Steps

1. Create `home/bin/executable_aaa-workspace`
2. Add shebang, `set -e`, variable definitions:
   - `AAA_DIR="$HOME/projects/work/aaa"`
   - `BACKUP_DIR="$HOME/Documents/01.1_Projects/01_AAA_Connect+"`
   - `BB_HOST="bitbucket-aaa"`
   - `BB_ORG="aaa-national"`
   - Array of repos: `connect-plus-backend`, `connect-plus-frontend`, `connectsuiteapps`
3. Implement `backup` subcommand:
   - Validate `$AAA_DIR/tools/data-integration` exists
   - Validate `$AAA_DIR/connect-plus-db` exists
   - Validate `$AAA_DIR/mise.toml` exists
   - `mkdir -p "$BACKUP_DIR"`
   - `tar czf "$BACKUP_DIR/data-integration.tar.gz" -C "$AAA_DIR/tools" data-integration`
   - `tar czf "$BACKUP_DIR/connect-plus-db.tar.gz" -C "$AAA_DIR" connect-plus-db`
   - `cp "$AAA_DIR/mise.toml" "$BACKUP_DIR/mise.toml"`
4. Implement `setup` subcommand:
   - `mkdir -p "$AAA_DIR/tools"`
   - For each repo: `git clone "git@$BB_HOST:$BB_ORG/$repo.git" "$AAA_DIR/$repo"` (skip if exists)
   - Validate backup archives exist in `$BACKUP_DIR`
   - `tar xzf "$BACKUP_DIR/data-integration.tar.gz" -C "$AAA_DIR/tools"`
   - `tar xzf "$BACKUP_DIR/connect-plus-db.tar.gz" -C "$AAA_DIR"`
   - `cp "$BACKUP_DIR/mise.toml" "$AAA_DIR/mise.toml"`
   - `cd "$AAA_DIR" && mise install`
5. Add `case "$1"` dispatcher with usage message for unknown/no args
6. Run `shellcheck` on the script

## Todo List

- [x] Create script file with backup subcommand
- [x] Add setup subcommand
- [x] Add usage/help message
- [x] Run shellcheck validation

## Success Criteria
- `aaa-workspace backup` creates 3 items in backup dir
- `aaa-workspace setup` clones repos + restores from backup
- Script passes shellcheck
- Follows existing script style conventions

## Risk Assessment
- **6.8GB connect-plus-db compression** — may take several minutes. Mitigated by echo progress before tar.
- **SSH alias `bitbucket-aaa`** may not exist on new machine before chezmoi apply. Mitigated: user runs `chezmoi apply` first (sets up SSH config).

## Security Considerations
- No secrets in script — SSH keys handled by chezmoi/1Password
- Backup dir is in user Documents, not committed to git

## Next Steps
- After script works: `chezmoi apply` to deploy, test both subcommands
