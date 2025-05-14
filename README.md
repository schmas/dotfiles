# Dotfiles

![License](https://img.shields.io/github/license/schmas/dotfiles)
![Last Commit](https://img.shields.io/github/last-commit/schmas/dotfiles)

> 🏠 Welcome to my personal dotfiles repository! This is where I manage my system configuration and keep my development environment consistent across machines.

## What are Dotfiles?

Dotfiles are configuration files in Unix-like systems that begin with a dot (.) and control the behavior of various applications and system components. Managing these files in a repository offers several benefits:

- **Backup and restoration**: Never lose your carefully crafted configurations
- **Synchronization**: Keep your settings consistent across multiple machines
- **Version control**: Track changes and revert when needed
- **Sharing**: Learn from others and share your setup with the community
- **Automation**: Streamline the setup of new machines

## Repository Structure

This repository is organized as follows:

- `home/` - The root directory for all dotfiles
  - `bin/` - Executable scripts and utilities
  - `.config/` - Configuration files for various applications
    - `fish/` - Fish shell configuration
    - `bash/` - Bash shell configuration
    - `zsh/` - Zsh shell configuration
    - `git/` - Git configuration
    - `nvim/` - Neovim configuration
    - And many more...
  - `.chezmoiscripts/` - Scripts that run after applying dotfiles

For a comprehensive reference of all aliases, functions, and scripts defined in this repository, see the [Shell Reference](SHELL-REFERENCE.md) document.

## Prerequisites

Before setting up these dotfiles, you'll need:

- [chezmoi](https://www.chezmoi.io/) - The dotfiles manager used by this repository
- [mise](https://mise.jdx.dev/) - Used for managing development tool versions
- [Fish shell](https://fishshell.com/) - One of the supported shells
- [Nix](https://nixos.org/) - Optional but recommended for a consistent environment

## Installation

### Quick Start

> **Optional**: First provision with nix repository: [my nix-config](https://github.com/schmas/nix-config)

```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply schmas

# Or if you prefer to clone first
git clone https://github.com/schmas/dotfiles.git
cd dotfiles
chezmoi init --apply
```

### Setup Process

During initialization, you'll be prompted to choose:
- A profile (default or server)
- Whether you're using NIX-CONFIG (recommended)
- Your default editor (nvim, zed, code, or none)

### Post-Installation

After applying the dotfiles, several scripts will run automatically:
- Sets up mise and installs configured tools
- Installs Fisher (Fish shell package manager)
- Installs the Neovim configuration

## Updating Your Dotfiles

To update your dotfiles after making changes to the repository:

```bash
chezmoi update
```

To pull the latest changes from the repository and apply them:

```bash
chezmoi update --pull
```

## Customization

### Adding Your Own Configurations

1. Make changes to the source files in the repository
2. Test changes with `chezmoi apply --dry-run --verbose`
3. Apply changes with `chezmoi apply`
4. Commit and push changes to the repository

### Using Templates

This repository uses Chezmoi's templating system:
- Template files use Go's text/template syntax
- Variables are defined in `.chezmoi.yaml.tmpl`
- Use conditional logic to handle different profiles and operating systems

## Best Practices for Version-Controlling Dotfiles

1. **Don't include sensitive information**: Use templates and separate private data
2. **Document your configurations**: Add comments to explain non-obvious settings
3. **Use a consistent style**: Follow established style guides for shell scripts
4. **Test before committing**: Ensure your changes work as expected
5. **Keep it modular**: Organize configurations by application or purpose
6. **Regular updates**: Periodically update and clean up your dotfiles

## Integration with Nix

This dotfiles repository is designed to work with Nix. If you're using Nix:

1. Set up the Nix configuration repository: [nix-config](https://github.com/schmas/nix-config)
2. Choose "Yes" when prompted about using NIX-CONFIG during chezmoi initialization

## Debugging

If you encounter issues:

- Use `chezmoi apply --dry-run --verbose` to see what changes would be made without applying them
- Check the chezmoi source state: `chezmoi source-path`
- Inspect the computed template output: `chezmoi execute-template < file.tmpl`

## License

This project is open source and available under the [MIT License](LICENSE).
