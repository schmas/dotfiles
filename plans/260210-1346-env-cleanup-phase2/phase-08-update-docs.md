# Phase 8: Update Architecture Docs

## Context
- Parent: [plan.md](plan.md)
- Depends on: Phase 7 (verify first)

## Overview
- **Priority**: Low
- **Status**: pending
- **Description**: Update docs to reflect new 15-services.env, updated architecture, and 00-load-homebrew for all shells.

## Implementation Steps

1. Update `plans/260210-1251-centralized-shared-env-vars/plan.md` architecture section:
   - Add `15-services.env` to the file listing
   - Note that tokens moved from 10-shared to 15-services

2. Update `docs/system-architecture.md`:
   - Update Module Load Order table: add `05-*` shared env row
   - Update `00-*` description to mention all shells have homebrew loader
   - Add centralized env directory to architecture diagram

3. Update `docs/code-standards.md`:
   - Update Environment Variables section to note centralized location
   - Update "Tool-Specific Variables" table (tokens now in 15-services.env)
   - Note `source_posix_env` function handles `$HOME` expansion

## Todo
- [ ] Update Phase 1 plan architecture section
- [ ] Update system-architecture.md load order + diagram
- [ ] Update code-standards.md env vars section

## Success Criteria
- Docs accurately reflect current architecture
- New developer can find where env vars are defined
