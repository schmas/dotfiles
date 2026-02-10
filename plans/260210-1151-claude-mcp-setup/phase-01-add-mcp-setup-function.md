# Phase 01: Add `setup_mcp_servers()` Function

## Context
- Parent plan: [plan.md](./plan.md)
- Target file: `home/bin/executable_setup-claude-code` (lines 1-91)
- Existing patterns: functions with echo headers, `set -e`, early returns
- Claude Code resolves `${VAR}` in MCP env config at runtime from shell environment

## Overview
- **Priority:** P3
- **Status:** complete
- **Description:** Add function that registers 3 MCP servers at user scope via `claude mcp add -s user`, called in `main()` after `run_setup_script`. Gemini key sourced from `~/.claude/.env` (1Password) instead of interactive prompt.

## Key Insights
- `claude mcp get <name>` exits 0 if server exists, 1 if not
- `claude mcp add -s user` writes to user-scoped config (available in all projects)
- human-mcp env uses `${GEMINI_API_KEY}` literal reference (Claude Code resolves at runtime)
- Script uses `set -e` so each add must be guarded to prevent script abort on failure

## Requirements
- Only execute if `claude` command available
- Skip each MCP already registered (idempotent)
- Store `${GEMINI_API_KEY}` literal in MCP config (resolved at runtime by Claude Code)
- Don't fail overall script on MCP add errors

## Related Code Files
- **Modify:** `home/bin/executable_setup-claude-code`

## Implementation Steps

1. Add helper `mcp_exists()` function:
   ```bash
   mcp_exists() {
     claude mcp get "$1" >/dev/null 2>&1
   }
   ```

2. Add `setup_mcp_servers()` function after `run_setup_script()`:
   ```bash
   setup_mcp_servers() {
     if ! command -v claude >/dev/null 2>&1; then
       echo "Claude CLI not found, skipping MCP setup"
       return 0
     fi

     echo "Setting up MCP servers..."

     # human-mcp (Gemini key resolved at runtime via ${GEMINI_API_KEY})
     if ! mcp_exists "human-mcp"; then
       claude mcp add -s user -e 'GOOGLE_GEMINI_API_KEY=${GEMINI_API_KEY}' \
         human-mcp -- npx @goonnguyen/human-mcp || echo "Warning: failed to add human-mcp"
     else
       echo "human-mcp already configured"
     fi

     # chrome-devtools
     if ! mcp_exists "chrome-devtools"; then
       claude mcp add -s user chrome-devtools -- npx -y chrome-devtools-mcp@latest \
         || echo "Warning: failed to add chrome-devtools"
     else
       echo "chrome-devtools already configured"
     fi

     # sequential-thinking
     if ! mcp_exists "sequential-thinking"; then
       claude mcp add -s user sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking \
         || echo "Warning: failed to add sequential-thinking"
     else
       echo "sequential-thinking already configured"
     fi
   }
   ```

3. Update `main()` to call `setup_mcp_servers` after `run_setup_script`:
   ```bash
   main() {
     echo "=== Claude Code Setup ==="
     setup_claude_config
     install_claude_code
     run_setup_script
     setup_mcp_servers      # <-- add this line
     show_plugin_instructions
   }
   ```

## Todo List
- [x] Add `mcp_exists()` helper function
- [x] Add `setup_mcp_servers()` function with 3 MCP registrations
- [x] Update `main()` to call `setup_mcp_servers`
- [x] Test with `chezmoi apply --dry-run`

## Success Criteria
- Script doesn't fail when claude CLI unavailable
- Already-installed MCPs are skipped without error
- human-mcp stores `${GEMINI_API_KEY}` literal (no hardcoded key)
- All 3 MCPs registered at user scope on fresh install

## Risk Assessment
- **Low:** `claude mcp add` may change CLI flags in future versions
- **Mitigation:** `|| echo "Warning: ..."` prevents script abort

## Security Considerations
- Gemini API key stored as `${GEMINI_API_KEY}` reference, never hardcoded in config
- Actual key resolved at runtime from shell environment (set via `~/.claude/.env` from 1Password)

## Next Steps
- None - single phase task
