# Contributing to JetBrains IDE Management Tools

Thank you for your interest in contributing to this project!

## How to Contribute

### Reporting Bugs

1. Check existing [Issues](../../issues) to avoid duplicates
2. Create a new issue with:
   - macOS version
   - IDE name and version
   - Steps to reproduce
   - Expected vs actual behavior
   - Output of the script (use `--dry-run` if applicable)

### Suggesting Features

Open an issue describing:
- The problem you're trying to solve
- Your proposed solution
- Which script(s) would be affected

### Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Test with `--dry-run` mode
5. Commit with a clear message
6. Push and open a Pull Request

## Development Guidelines

### Code Style

- Use **American English** for all code, comments, and messages
- Use **snake_case** for script and function names
- Use consistent indentation (4 spaces)
- Add comments for complex logic

### Testing

Always test changes with:
```bash
bash tools/deep-uninstall.sh --dry-run
```

### IDE Isolation

**Critical**: Never use generic patterns like `*jetbrains*` alone. Each IDE must use its specific identifiers to prevent cross-contamination. See CLAUDE.md for the complete pattern list.

### Commit Messages

Use clear, descriptive commit messages:
```
Add support for new IDE
Fix file pattern for PyCharm Community
Update README with new usage examples
```

## Questions?

Open an issue for any questions about contributing.
