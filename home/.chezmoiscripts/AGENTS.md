# CHEZMOISCRIPTS

Pre/post-apply automation scripts. Execution order: directory prefix (`00-` before `01-`), then filename within each directory.

## STRUCTURE

```
.chezmoiscripts/
├── 00-run-before/          # Runs BEFORE files deployed
│   ├── run_once_before_00_configure_1password.sh     # 1Password CLI account setup
│   ├── run_once_before_01-install-homebrew-on-macos.sh.tmpl  # Rosetta 2 + Homebrew
│   └── run_onchange_before_02-install-packages-from-brewfile.sh.tmpl  # Brewfile install
└── 01-common/              # Runs AFTER files deployed
    ├── run_after_00-local-files.sh.tmpl              # Creates *_local override files
    ├── run_once_after_00-darwin-set-default-shell.sh.tmpl    # Fish as default (macOS)
    ├── run_once_after_00-darwin-system-defaults.sh.tmpl      # macOS Dock, Finder, etc.
    ├── run_once_after_00-darwin-touch-id-sudo.sh.tmpl        # Touch ID for sudo
    ├── run_once_after_00-linux-system-setup.sh.tmpl          # Linux packages + setup
    ├── run_once_after_01-mise-install.sh.tmpl                # Mise runtimes (5x retry)
    ├── run_once_after_02-install-fisher.fish.tmpl            # Fisher + Fish plugins
    ├── run_once_after_02.1-some-fish-setup.fish.tmpl         # Additional Fish config
    ├── run_once_after_03-claude-install.sh.tmpl              # Claude Code CLI
    ├── run_once_after_05-nvim_lazy-install.sh.tmpl           # Neovim lazy.nvim
    ├── run_once_after_06-post-install-logins.sh.tmpl         # Auth setup
    └── run_onchange_after_07-load-launchd-agents.sh.tmpl     # macOS LaunchAgents
```

## CONVENTIONS

**Naming scheme:** `run_{timing}_{modifier}_{order}-{description}.{ext}.tmpl`

| Timing | Modifier | Meaning |
|--------|----------|---------|
| `before` | `run_once` | First apply only, before file deployment |
| `before` | `run_onchange` | Re-runs when file hash changes (e.g., Brewfile) |
| `after` | `run_once` | First apply only, after file deployment |
| `after` | `run_after` | Every apply (local files creation) |
| `after` | `run_onchange` | Re-runs on hash change (launchd agents) |

**Execution flow on fresh machine:**
```
1password setup → Homebrew install → Brewfile packages →
[files deployed] →
local files → macOS defaults → shell → Linux setup →
Mise → Fisher → Fish setup → Claude → Neovim → logins → launchd
```

## ANTI-PATTERNS

- **NEVER** use `run_always_` — prefer `run_onchange_` with hash triggers
- **NEVER** skip OS guards — wrap macOS scripts with `{{ if eq .chezmoi.os "darwin" }}`
- **NEVER** assume sudo availability — request once, manage session
- Scripts are **NOT idempotent by default** — `run_once_` relies on chezmoi state tracking
- Brewfile script uses `{{ include "Brewfile" | sha256sum }}` as change trigger — don't remove that comment

## NOTES

- `00-run-before/` scripts run with chezmoi source dir files (NOT yet deployed)
- Brewfile installer keeps sudo alive via background refresh loop
- Mise install retries 5 times with 2s delay (handles transient network failures)
- `.fish.tmpl` scripts require Fish shell — they execute via `fish` interpreter
