# Documentation Index

Welcome to the dotfiles documentation. This directory contains comprehensive guides covering all aspects of the personal dotfiles repository.

## Quick Navigation

### For New Users
Start here if you're setting up the dotfiles for the first time:
1. **[Deployment & Installation Guide](./deployment-guide.md)** - Step-by-step setup (5-10 min read)
2. **[Project Overview](./project-overview-pdr.md)** - What this project does (5 min read)

### For Users
Using the dotfiles daily? Check these:
- **[Code Standards](./code-standards.md)** - How to add aliases, customize configs
- **[Design Guidelines](./design-guidelines.md)** - Philosophy and patterns
- Main README: `../README.md` - Quick reference

### For Maintainers
Maintaining or extending the system:
1. **[System Architecture](./system-architecture.md)** - How it works (15 min read)
2. **[Codebase Summary](./codebase-summary.md)** - File structure (10 min read)
3. **[Code Standards](./code-standards.md)** - Development guidelines
4. **[Project Roadmap](./project-roadmap.md)** - Status and future plans

### For Contributors
Want to improve the project?
1. **[Project Roadmap](./project-roadmap.md)** - Planned improvements and priorities
2. **[Code Standards](./code-standards.md)** - Conventions and patterns to follow
3. **[System Architecture](./system-architecture.md)** - Understand the design before changing

---

## Documentation Files

### Core Documentation (3,129 lines total)

| File | Purpose | LOC | Read Time |
|------|---------|-----|-----------|
| **[Project Overview & PDR](./project-overview-pdr.md)** | Goals, features, design principles, PDR | 175 | 5 min |
| **[Codebase Summary](./codebase-summary.md)** | Repository structure, file organization | 292 | 10 min |
| **[Code Standards](./code-standards.md)** | Development conventions, patterns, checklist | 538 | 15 min |
| **[System Architecture](./system-architecture.md)** | Technical design, data flows, integrations | 595 | 20 min |
| **[Project Roadmap](./project-roadmap.md)** | Current status, phases, improvements, backlog | 413 | 15 min |
| **[Deployment Guide](./deployment-guide.md)** | Installation, setup, troubleshooting | 595 | 20 min |
| **[Design Guidelines](./design-guidelines.md)** | Philosophy, design patterns, principles | 521 | 15 min |

**Total:** 3,129 lines of documentation

---

## By Topic

### Getting Started
- [Deployment & Installation Guide](./deployment-guide.md) - Complete setup instructions
- [Project Overview](./project-overview-pdr.md) - What and why

### How It Works
- [System Architecture](./system-architecture.md) - Technical deep-dive
- [Codebase Summary](./codebase-summary.md) - File structure
- [Design Guidelines](./design-guidelines.md) - Design philosophy

### Making Changes
- [Code Standards](./code-standards.md) - Conventions and patterns
- [Design Guidelines](./design-guidelines.md) - Principles to follow

### Planning & Future
- [Project Roadmap](./project-roadmap.md) - Status and next steps
- [Unresolved Questions](#unresolved-questions) - Issues to address

### Reference
- [../SHELL-REFERENCE.md](../SHELL-REFERENCE.md) - All aliases and functions
- [../README.md](../README.md) - Quick start and overview

---

## Key Concepts

### Profile System
The dotfiles support multiple profiles for different machines:
- `default` - Full development environment
- `server` - Minimal server setup
- `ct` - Custom profile (purpose TBD)
- `aaa` - Alternative account configuration

See [Project Overview](./project-overview-pdr.md#target-users--machines) for details.

### Template System
Configuration files use Chezmoi templates (Go text/template syntax):
- Variables: `{{ .profile }}`, `{{ .chezmoi.os }}`
- Secrets: `{{ onepasswordRead "op://vault/item/field" }}`
- Conditions: `{{ if eq .chezmoi.os "darwin" }} ... {{ end }}`

See [Code Standards](./code-standards.md#template-syntax-standards) for details.

### Multi-Shell Support
All shells (Fish, Zsh, Bash) share:
- Same command aliases (identical across shells)
- Same environment variables
- Same prompt (Starship)
- Different plugin managers (Fisher for Fish, Sheldon for Zsh/Bash)

See [Design Guidelines](./design-guidelines.md#shell-configuration-philosophy) for philosophy.

### 1Password Integration
Secrets are stored in 1Password and injected during config application:
- Git signing keys
- SSH identities
- API tokens
- GPG key backups

See [System Architecture](./system-architecture.md#secret-management-architecture) for details.

---

## Common Questions

### Q: How do I add a personal alias?
**A:** Create or edit `~/.config/fish/config_local.fish` (Fish) or `~/.config/zsh/zshrc_local` (Zsh). See [Code Standards](./code-standards.md#local-customizations-dont-edit-repo).

### Q: How do I update to latest changes?
**A:** Run `chezmoi pull && chezmoi apply`. See [Deployment Guide](./deployment-guide.md#updating-configuration).

### Q: Where are my aliases defined?
**A:** See [../SHELL-REFERENCE.md](../SHELL-REFERENCE.md) for complete list. Defined in `99-aliases.*` files.

### Q: How do I install on a new machine?
**A:** See [Deployment Guide](./deployment-guide.md#quick-start-5-minutes).

### Q: Can I use just Bash?
**A:** Yes, bash configuration is included. Fish and Zsh are optional. See [Code Standards](./code-standards.md#shell-script-standards).

### Q: How does 1Password integration work?
**A:** See [System Architecture](./system-architecture.md#1password-integration-flow).

### Q: What if I want different config on different machines?
**A:** Use `*_local` template files or per-machine profile selections. See [Deployment Guide](./deployment-guide.md#machine-specific-configuration).

---

## Unresolved Questions

These items need clarification (targeted for Phase 3, Q1 2026):

1. **Atuin sync status** - Is cross-machine history sync enabled?
2. **Zellij vs Tmux** - Which multiplexer is primary?
3. **Profile purposes** - What are ct and aaa profiles for?
4. **Custom plugin forks** - Maintenance strategy for schmas/fifc and dircolors-neutral?
5. **Mise pinning** - Are tool versions pinned or floating?
6. **p10k usage** - Zsh loads p10k prompt but uses Starship. Why?
7. **Bash minimal** - Why 6 Sheldon plugins for Bash vs 27 for Zsh?
8. **Local templates** - Are `*_local` template files actively used?

See [Project Roadmap](./project-roadmap.md#unresolved-questions--dependencies) for details.

---

## Maintenance & Updates

### Documentation Goals
- Keep all docs under 800 LOC (currently 3,129 total across 7 files)
- Cross-reference between documents
- Include code examples and diagrams
- Answer common questions
- List unresolved issues

### When to Update Docs
Update documentation when:
- Code changes significantly
- New tool or feature added
- Architecture decision made
- User asks a question doc doesn't answer
- Unresolved question gets answered

See [Design Guidelines](./design-guidelines.md#when-to-add-documentation) for principles.

### Contributing to Docs
Follow [Code Standards](./code-standards.md#documentation-standards) when writing:
- Markdown formatting
- Clear headings and structure
- Inline comments for non-obvious settings
- Link cross-references
- Include examples

---

## Documentation Statistics

- **Total Files:** 7 main docs + SHELL-REFERENCE + README
- **Total Lines:** 3,129 LOC (docs only, excluding reports)
- **Average File Size:** 447 LOC
- **Largest File:** System Architecture (595 LOC)
- **Smallest File:** Project Overview (175 LOC)
- **Coverage:** ~90% of project documented

---

## Related Resources

### External Documentation
- **Chezmoi:** https://www.chezmoi.io/
- **Fish Shell:** https://fishshell.com/docs/
- **Zsh:** http://zsh.sourceforge.net/Doc/
- **Starship:** https://starship.rs/
- **1Password CLI:** https://developer.1password.com/docs/cli/

### Related Repositories
- **[nix-config](https://github.com/schmas/nix-config)** - NixOS/nix-darwin setup
- **[nvim_lazy](https://github.com/schmas/nvim_lazy)** - Neovim configuration
- **[fifc](https://github.com/schmas/fifc)** - Custom Fish tab completion
- **[dircolors-neutral](https://github.com/schmas/dircolors-neutral)** - Custom ls colors

### Tools Referenced
- Git, SSH, GPG (secrets and signing)
- Tmux, Zellij (terminal multiplexers)
- Fish, Zsh, Bash (shells)
- Mise (version manager)
- Atuin, FZF, Yazi, Lazygit (utilities)
- IdeaVim, Zed, LunarVim, Vim (editors)

---

## Feedback & Improvements

Found something missing or incorrect?

1. Check [Unresolved Questions](#unresolved-questions) first
2. Review [Project Roadmap](./project-roadmap.md) for planned improvements
3. Submit feedback via GitHub issues
4. Contribute improvements via pull request

See [Project Roadmap](./project-roadmap.md#next-steps) for how documentation will improve.

---

## Document Navigation

```
docs/README.md (you are here)
├── Project Overview & PDR
│   ├── Goals and features
│   └── PDR requirements
├── Deployment Guide
│   ├── Installation steps
│   ├── Troubleshooting
│   └── Post-setup
├── Codebase Summary
│   ├── Directory structure
│   └── File statistics
├── Code Standards
│   ├── Naming conventions
│   ├── Template syntax
│   └── Review checklist
├── System Architecture
│   ├── Technical design
│   ├── Data flows
│   └── Integrations
├── Design Guidelines
│   ├── Philosophy
│   ├── Patterns
│   └── Principles
└── Project Roadmap
    ├── Current status
    ├── Implementation phases
    └── Improvement backlog
```

---

**Last Updated:** Jan 22, 2026
**Status:** Production Ready
**Version:** 1.0
**Maintainer:** Schmas

*For questions, see [Unresolved Questions](#unresolved-questions) or check [Project Roadmap](./project-roadmap.md).*
