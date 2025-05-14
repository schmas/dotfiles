# Development Guidelines

This document provides guidelines for developing and maintaining this dotfiles repository. It's intended for advanced developers who are familiar with shell scripting, chezmoi, and related tools.

## Build/Configuration Instructions

### Prerequisites

- [chezmoi](https://www.chezmoi.io/) - The dotfiles manager used by this repository
- [mise](https://mise.jdx.dev/) - Used for managing development tool versions
- [Fish shell](https://fishshell.com/) - One of the supported shells
- [Nix](https://nixos.org/) - Optional but recommended for a consistent environment

### Initial Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/schmas/dotfiles.git
   cd dotfiles
   ```

2. **Initialize chezmoi with this repository**:
   ```bash
   chezmoi init --apply
   ```
   
   During initialization, you'll be prompted to choose:
   - A profile (default or server)
   - Whether you're using NIX-CONFIG (recommended)
   - Your default editor (nvim, zed, code, or none)

3. **Post-installation scripts**:
   After applying the dotfiles, several scripts will run automatically:
   - `run_once_after_01-mise-install.sh` - Sets up mise and installs configured tools
   - `run_once_after_02-install-fisher.fish` - Installs Fisher (Fish shell package manager)
   - `run_once_after_05-nvim_lazy-install.sh` - Installs the Neovim configuration

### Updating

To update your dotfiles after making changes to the repository:

```bash
chezmoi update
```

To pull the latest changes from the repository and apply them:

```bash
chezmoi update --pull
```

## Additional Development Information

### Code Style

- **Shell Scripts**:
  - Use shellcheck to validate shell scripts
  - Follow the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
  - Use `set -e`, `set -u`, and `set -o pipefail` for error handling

- **Fish Scripts**:
  - Follow the [Fish shell style guide](https://fishshell.com/docs/current/style.html)

### Chezmoi Templates

- Template files use Go's text/template syntax
- Variables are defined in `.chezmoi.yaml.tmpl`
- Use conditional logic to handle different profiles and operating systems

### Directory Structure

- `home/` - The root directory for all dotfiles
- `home/.chezmoiscripts/` - Scripts that run after applying dotfiles
- `home/.config/` - Configuration files for various applications
- `home/bin/` - Executable scripts

### Debugging Tips

- Use `chezmoi apply --dry-run --verbose` to see what changes would be made without applying them
- Check the chezmoi source state: `chezmoi source-path`
- Inspect the computed template output: `chezmoi execute-template < file.tmpl`

### Recommended Workflow

1. Make changes to the source files in the repository
2. Test changes with `chezmoi apply --dry-run --verbose`
3. Apply changes with `chezmoi apply`
4. Commit and push changes to the repository

### Integration with Nix

This dotfiles repository is designed to work with Nix. If you're using Nix:

1. Set up the Nix configuration repository: [https://github.com/schmas/nix-config](https://github.com/schmas/nix-config)
2. Choose "Yes" when prompted about using NIX-CONFIG during chezmoi initialization
