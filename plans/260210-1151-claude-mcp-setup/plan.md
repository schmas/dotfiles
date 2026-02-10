---
title: "Add MCP servers to Claude Code setup"
description: "Register 3 MCP servers (human-mcp, chrome-devtools, sequential-thinking) via claude mcp add in setup script"
status: complete
priority: P3
effort: 15m
branch: main
tags: [claude, mcp, chezmoi, setup]
created: 2026-02-10
---

# Add MCP Servers to Claude Code Setup

## Goal
Add automatic MCP server registration to `setup-claude-code` script so fresh installs get human-mcp, chrome-devtools, and sequential-thinking configured at user scope.

## Phases

| # | Phase | Status | File |
|---|-------|--------|------|
| 1 | Add `setup_mcp_servers()` function | complete | [phase-01](./phase-01-add-mcp-setup-function.md) |

## Key Decisions
- Use `claude mcp get <name>` (exit 0=exists, 1=missing) for idempotency
- Guard entire function behind `command -v claude` check
- Prompt interactively for Gemini API key only when human-mcp not yet installed
- Each MCP add is independent; one failure doesn't block others

## File Modified
- `home/bin/executable_setup-claude-code`
