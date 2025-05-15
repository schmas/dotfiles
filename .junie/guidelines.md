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

- **Git Commit Messages**:
  - Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification
  - Format: `<type>[optional scope]: <description>`
  - Common types:
    - `feat`: A new feature
    - `fix`: A bug fix
    - `docs`: Documentation only changes
    - `style`: Changes that do not affect the meaning of the code (white-space, formatting, etc.)
    - `refactor`: A code change that neither fixes a bug nor adds a feature
    - `perf`: A code change that improves performance
    - `test`: Adding missing tests or correcting existing tests
    - `chore`: Changes to the build process or auxiliary tools and libraries
  - Examples:
    ```
    feat: add new fish abbreviation for git status
    fix(git): correct path in gitconfig template
    docs: update SHELL-REFERENCE.md with new aliases
    chore: update mise configuration
    ```
  - Breaking changes should be indicated by a `!` after the type/scope or by including `BREAKING CHANGE:` in the footer
    ```
    feat!: change default shell to fish
    ```

### Chezmoi Templates

- Template files use Go's text/template syntax
- Variables are defined in `.chezmoi.yaml.tmpl`
- Use conditional logic to handle different profiles and operating systems

### Directory Structure

- `home/` - The root directory for all dotfiles
- `home/.chezmoiscripts/` - Scripts that run after applying dotfiles
- `home/dot_config/` - Configuration files for various applications
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

### Documentation Maintenance

#### SHELL-REFERENCE.md

The `SHELL-REFERENCE.md` file serves as a comprehensive reference for all aliases, functions, and scripts defined in this repository, organized by shell.

1. **Keep it updated**: Whenever you add, modify, or remove shell aliases, functions, or scripts, make sure to update the `SHELL-REFERENCE.md` file accordingly.
2. **Follow the existing format**: Maintain the table format for consistency.
3. **Organize by shell**: Ensure that new entries are added under the appropriate shell section.
4. **Include descriptions**: Each entry should have a clear description of what it does.

This document is essential for users to discover and understand the available shell commands and functions provided by the dotfiles.

### Integration with Nix

This dotfiles repository is designed to work with Nix. If you're using Nix:

1. Set up the Nix configuration repository: [https://github.com/schmas/nix-config](https://github.com/schmas/nix-config)
2. Choose "Yes" when prompted about using NIX-CONFIG during chezmoi initialization
