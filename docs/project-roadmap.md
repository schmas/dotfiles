# Project Roadmap & Development Status

## Current State Summary

### Fully Implemented Features
- **Multi-shell support** - Fish, Zsh, Bash with unified aliases (100%)
- **Chezmoi dotfile management** - Profile-based deployment (100%)
- **1Password integration** - Secrets management for git, SSH, GPG (100%)
- **Terminal multiplexer** - Tmux with Oh my tmux! framework (100%)
- **Shell prompt** - Starship unified prompt across shells (100%)
- **Editor configurations** - IdeaVim, Zed, LunarVim, Vim (100%)
- **Git setup** - Dual identity, SSH signing, difftastic (100%)
- **GPG key management** - Backup/restore via 1Password (100%)
- **Tool integrations** - Atuin, Yazi, Lazygit, Zellij (100%)
- **Update orchestration** - Master upall script for system updates (100%)

### Partially Implemented Features
- **Mise version manager** - Tools installed but versions not enforced (60%)
  - Config exists, tools listed, but usage unclear
  - Integration incomplete in all shells
- **Zellij terminal multiplexer** - Full config, unclear if primary (50%)
  - Configured but Tmux also available
  - No clear migration path from Tmux
- **Atuin sync** - Config exists, sync status unknown (40%)
  - Local history working
  - Cross-machine sync unclear if enabled
- **Custom plugin forks** - schmas/fifc and dircolors-neutral exist (50%)
  - Features documented in scout reports
  - Unclear if maintained/synced with upstream

### Not Yet Implemented
- **Automated testing** - Manual verification only (0%)
  - No test suite for dotfile application
  - No validation of config correctness
  - Manual chezmoi --dry-run testing
- **Comprehensive documentation** - In progress (10%)
  - This project creating initial docs
  - SHELL-REFERENCE.md exists but incomplete
- **CI/CD pipeline** - No continuous integration (0%)
  - No GitHub Actions for config validation
  - No automated linting
- **Migration tooling** - Manual setup required (0%)
  - No asdf → Mise migration helpers
  - No plugin manager transition scripts

## Phase Breakdown

### Phase 1: Documentation Foundation (CURRENT)
**Status:** In Progress
**Timeline:** Jan 22-25, 2026
**Goal:** Create comprehensive documentation for existing system

**Tasks:**
- [x] Project overview and PDR
- [x] Codebase structure summary
- [x] Code standards and conventions
- [x] System architecture documentation
- [x] Project roadmap (this file)
- [ ] Deployment and installation guide
- [ ] Design guidelines and philosophy
- [ ] Update README with doc links

**Success Criteria:**
- All docs under 800 LOC (split if needed)
- Clear cross-references between documents
- Unanswered questions documented
- README updated with navigation

---

### Phase 2: Quality & Testing (Q1 2026)
**Status:** Pending
**Goal:** Establish testing and validation practices

**Tasks:**
- [ ] Create dotfile application test suite
  - Test chezmoi init with all profiles
  - Validate template processing
  - Verify file permissions
  - Check tool installations
- [ ] Automated linting
  - Shell script linting (shellcheck)
  - YAML validation
  - JSON/TOML syntax checks
- [ ] CI/CD pipeline
  - GitHub Actions workflow
  - Test on macOS and Linux
  - Validate config on each commit
- [ ] Documentation validation
  - Link checking in markdown files
  - Code example verification

**Success Criteria:**
- All tests passing (>90% coverage)
- CI pipeline green on main branch
- No broken links in documentation
- Automated checks on PRs

---

### Phase 3: Clarification & Consolidation (Q1 2026)
**Status:** Pending
**Goal:** Resolve ambiguities, improve architecture

**Tasks:**
- [ ] Clarify profile purposes
  - Document what ct and aaa profiles are for
  - Consider consolidation if redundant
  - Update .chezmoi.yaml.tmpl with clearer prompts
- [ ] Multiplexer decision
  - Choose Zellij or Tmux as primary
  - Document migration path if switching
  - Clean up unused multiplexer config
- [ ] Atuin configuration review
  - Enable/disable sync explicitly
  - Document sync strategy
  - Configure conflict resolution
- [ ] Plugin fork maintenance
  - Clarify schmas/fifc and dircolors-neutral features
  - Decide on maintenance strategy (upstream or fork)
  - Document custom enhancements
- [ ] Tool version pinning
  - Finalize Mise version strategy
  - Pin or float? Document rationale
  - Create .mise.local template

**Success Criteria:**
- All questions from PDR answered
- Profile purposes clearly defined
- Multiplexer decision documented
- Plugin fork strategy clear
- Zero ambiguous configuration choices

---

### Phase 4: Automation & Efficiency (Q2 2026)
**Status:** Pending
**Goal:** Improve installation and maintenance experience

**Tasks:**
- [ ] Fast setup wizard
  - Create interactive setup script
  - Auto-detect OS and profile recommendation
  - Validate 1Password setup
  - Streamline first-time experience
- [ ] Automated tool migration
  - asdf → Mise migration helper
  - Plugin manager transition (if needed)
  - Breaking change notifications
- [ ] Cross-machine sync
  - Test chezmoi pull on multiple machines
  - Document sync conflicts handling
  - Create safe rollback procedures
- [ ] Performance benchmarking
  - Measure shell startup time
  - Profile plugin loading
  - Optimize critical paths
- [ ] Secrets rotation automation
  - Helper script for token refresh
  - 1Password integration automation
  - Notification for expiring credentials

**Success Criteria:**
- First-time setup < 5 minutes
- Profile migration < 2 minutes
- Shell startup < 1.5 seconds
- Zero manual secret rotation
- 100% dotfile consistency across machines

---

### Phase 5: Advanced Features (Q2-Q3 2026)
**Status:** Pending
**Goal:** Enhance capabilities and customization

**Tasks:**
- [ ] Per-machine overrides system
  - Create machine-specific profiles
  - Override defaults without forking
  - Template-driven machine detection
- [ ] IDE configuration unification
  - Common keymap across IdeaVim, Zed, Neovim
  - Shared theme definitions
  - Single source of truth for editor prefs
- [ ] Project-specific environments
  - Per-project tool versions
  - Directory-specific aliases
  - Automatic context switching
- [ ] Advanced shell features
  - Directory-specific functions
  - Project detection and setup
  - Automated environment activation
- [ ] Tool ecosystem expansion
  - Additional language support
  - More IDE configurations
  - Development tool integrations

**Success Criteria:**
- Machine-specific overrides working
- Editor consistency across tools
- Project context auto-detected
- Zero manual tool setup per project
- Extensible architecture for new tools

---

## Improvement Backlog

### High Priority (Unresolved Questions)

1. **Atuin sync architecture** (High Impact)
   - Current: Config exists, sync status unknown
   - Desired: Clear enabled/disabled, sync tested across machines
   - Effort: 2-3 days
   - Impact: Trust in history system

2. **Zellij vs Tmux decision** (High Impact)
   - Current: Both configured, unclear which primary
   - Desired: Single multiplexer, clear migration path
   - Effort: 1-2 days
   - Impact: Reduces config duplication, improves UX

3. **Profile clarity** (Medium Impact)
   - Current: ct and aaa purposes unclear
   - Desired: Documented use cases, clear naming
   - Effort: 1 day
   - Impact: Easier onboarding, feature clarity

4. **Custom plugin maintenance** (Medium Impact)
   - Current: schmas/fifc, dircolors-neutral unclear
   - Desired: Documented features, maintenance plan
   - Effort: 2-3 days
   - Impact: Sustainable long-term maintenance

### Medium Priority (Quality & UX)

1. **Test automation** (High Value)
   - Current: Manual testing
   - Desired: Automated suite covering all profiles/OS
   - Effort: 5-7 days
   - Impact: Confidence in deployments

2. **Performance profiling** (Medium Value)
   - Current: Estimated shell startup ~1-2s
   - Desired: Measured, optimized to < 1s
   - Effort: 2-3 days
   - Impact: Improved user experience

3. **Documentation examples** (Medium Value)
   - Current: SHELL-REFERENCE.md lists aliases
   - Desired: Runnable examples, use case documentation
   - Effort: 2-3 days
   - Impact: Easier adoption, reduced confusion

4. **IDE configuration consolidation** (Medium Value)
   - Current: Separate IdeaVim, Zed, Neovim configs
   - Desired: Shared keymap/theme definitions
   - Effort: 3-4 days
   - Impact: Consistency, easier maintenance

### Low Priority (Nice to Have)

1. **Dashboard/monitoring**
   - Status overview of all machines
   - Last sync time, version info
   - Configuration drift detection

2. **Shell color scheme unification**
   - Consistent theme across all shells
   - Single catppuccin/dracula definition
   - Auto-sync across tools

3. **Environment variable management**
   - Centralized env var documentation
   - Cross-shell variable testing
   - Profile-specific env vars

4. **Backup & restore procedures**
   - Full system backup before apply
   - Easy rollback to previous state
   - Version history of configs

## Known Limitations

### Current Constraints

1. **Fisher vs Sheldon split** (Medium Impact)
   - Fish uses Fisher (13 plugins)
   - Zsh/Bash use Sheldon (27 + 6 plugins)
   - Inconsistent plugin management
   - Workaround: Unified test suite

2. **1Password dependency** (High Impact)
   - Secrets require 1Password account
   - No offline mode for config generation
   - Not portable to machines without 1Password
   - Workaround: Local override templates for testing

3. **Manual tool installation** (Medium Impact)
   - Some tools require manual post-apply setup
   - Atuin requires first-time login
   - GPG setup interactive
   - Workaround: Comprehensive setup guide

4. **Plugin version floating** (Low-Medium Impact)
   - No pinned plugin versions
   - Updates can introduce breaking changes
   - Inconsistent versions across machines
   - Workaround: Sheldon cache, pin critical plugins

5. **Limited cross-machine sync** (Medium Impact)
   - Chezmoi pulls from git, doesn't auto-sync
   - Manual chezmoi pull required
   - Secrets not sync'd (stored locally)
   - Workaround: Cron job for auto-sync

## Metrics & Success Indicators

### Current Baseline
- **Shell startup:** ~1-2 seconds (Fish/Zsh with plugins)
- **Dotfile count:** 100+ files
- **Configuration LOC:** ~9,000
- **Profiles:** 4 (default, server, ct, aaa)
- **Shells supported:** 3 (Fish, Zsh, Bash)
- **Documentation coverage:** ~5% (this project improving to 20%)

### Phase 1 Success Metrics
- [x] Documentation complete (4 core docs)
- [x] All code standards defined
- [x] Architecture documented
- [x] Unresolved questions listed

### Phase 2 Success Metrics (Target)
- [ ] Test coverage > 80%
- [ ] Zero documentation broken links
- [ ] CI/CD pipeline green
- [ ] All linting checks passing

### Phase 3 Success Metrics (Target)
- [ ] All unanswered questions resolved
- [ ] Profile purposes crystal clear
- [ ] Multiplexer decision documented
- [ ] Plugin strategy finalized

### Phase 4 Success Metrics (Target)
- [ ] Setup wizard created
- [ ] Tool migration < 2 minutes
- [ ] Shell startup < 1.5 seconds
- [ ] 100% machine sync success rate

### Long-term Vision
- **30K+ LOC** - Comprehensive configuration ecosystem
- **8+ profiles** - Specialized setups (dev, server, minimal, ci, etc.)
- **5+ shells** - Nushell, Elvish support
- **10+ IDEs** - VSCode, Neovim, etc.
- **< 1s startup** - Optimized plugin loading
- **100% test coverage** - Automated validation
- **Zero questions** - Complete documentation
- **Fully automated** - Zero manual setup

## Unresolved Questions & Dependencies

### Blocking Phase 2
1. Should test suite cover all 4 profiles?
2. What's minimum coverage threshold for CI approval?
3. Should tests run on macOS and Linux separately?

### Blocking Phase 3
1. Are ct/aaa profiles actively used or legacy?
2. Is Zellij replacement for Tmux or alternative?
3. Are custom forks (fifc, dircolors-neutral) active maintenance?

### Blocking Phase 4
1. What's acceptable shell startup time target?
2. Should cross-machine sync be automatic or manual?
3. How to handle breaking changes in configs?

### General Architecture
1. Should profiles be based on role (dev, server) rather than machine?
2. Is Mise tool version pinning or floating?
3. What's the strategy for upstream plugin updates?

## Timeline Summary

```
Q1 2026 (Current)
├─ Phase 1: Documentation ✓ (In Progress)
└─ Phase 2: Testing (Upcoming)

Q1-Q2 2026
├─ Phase 3: Clarification (Jan-Feb)
└─ Phase 4: Automation (Feb-Mar)

Q2-Q3 2026
└─ Phase 5: Advanced Features (Apr-Jun)

Q4 2026+
└─ Maintenance & Optimization
```

## Getting Started with This Roadmap

1. **Read** this file + project-overview-pdr.md
2. **Identify** which phase is most relevant to your needs
3. **Review** associated tasks and unresolved questions
4. **Contribute** by working on high-priority improvements
5. **Document** progress in git commits and update this file

---

**Last Updated:** Jan 22, 2026
**Maintainer:** Schmas
**Status:** Active Development
