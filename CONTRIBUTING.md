# Contributing to Qubar

Thank you for your interest in contributing to Qubar! This document provides guidelines for contributions.

## Getting Started

1. **Fork** the repository on GitHub
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Qubar.git
   cd Qubar
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Prerequisites

- Arch Linux (or Arch-based distro)
- Hyprland window manager
- QuickShell (from AUR: `quickshell-git`)

### Running Locally

```bash
# Reload QuickShell after changes
quickshell -r

# View logs
quickshell -l
```

## Code Guidelines

### QML Files

- Use **camelCase** for properties and functions
- Use **PascalCase** for component names
- Add error handlers to all Process objects
- Use `Qt.getenv()` for environment variables (not `Quickshell.env()`)
- Avoid QML template literals (`${var}`) - use string concatenation

### Bash Scripts

- Include `set -euo pipefail` at the top
- Use `${VAR}` syntax for variables
- Add input validation for user-provided values
- Run `shellcheck` before submitting

## Pull Request Process

1. **Test** your changes locally
2. **Update documentation** if needed
3. **Run linters**:
   ```bash
   shellcheck scripts/*.sh
   ```
4. **Commit** with clear messages:
   ```bash
   git commit -m "feat: add new widget for X"
   ```
5. **Push** and open a Pull Request

### Commit Message Format

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `chore:` Maintenance tasks

## Reporting Issues

When reporting bugs, please include:

- Hyprland version (`hyprctl version`)
- QuickShell version
- Steps to reproduce
- Error logs (`quickshell -l`)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
