# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

macOS utility scripts for complete uninstallation and management of JetBrains IDEs. Two standalone Bash scripts with no external dependencies.

**Repository**: https://github.com/josedacosta/shell-tools-jetbrains.git

## Running the Scripts

```bash
# Complete IDE removal
bash tools/deep-uninstall.sh              # Interactive with double confirmation
bash tools/deep-uninstall.sh --dry-run    # Preview mode (no deletion)

# Find remaining traces after uninstall
bash tools/find-traces.sh
```

All scripts present an interactive menu to select which IDE (1-12) or all IDEs (13).

## Architecture

### Script Organization

| Script | Lines | Purpose |
|--------|-------|---------|
| `deep-uninstall.sh` | ~1200 | Complete IDE removal with safety features |
| `find-traces.sh` | ~440 | System scan for leftover IDE files |

### Common Patterns

**Logging functions** (consistent across scripts):
- `log_info()`, `log_ok()`, `log_warning()`, `log_error()`, `log_kill()` - Color-coded output

**File removal helpers** (in `deep-uninstall.sh`):
- `remove_item()` - Remove single file/directory
- `remove_pattern()` - Remove by glob pattern
- `remove_find()` - Remove via find command

### Safety Mechanisms

- Double confirmation: type `YES` then IDE-specific phrase (e.g., `DELETE INTELLIJ`)
- 5-second countdown before deletion starts
- `--dry-run` mode for safe preview
- IDE isolation via unique identifiers per IDE

## IDE Isolation (CRITICAL)

**Always use IDE-specific patterns** to prevent cross-contamination:

| IDE | Patterns |
|-----|----------|
| IntelliJ IDEA | `IntelliJIdea*`, `IdeaIC*`, `com.jetbrains.intellij*` |
| PyCharm | `PyCharm*`, `PyCharmCE*`, `com.jetbrains.pycharm*` |
| WebStorm | `WebStorm*`, `com.jetbrains.WebStorm*` |
| PhpStorm | `PhpStorm*`, `com.jetbrains.PhpStorm*` |
| RubyMine | `RubyMine*`, `com.jetbrains.rubymine*` |
| DataGrip | `DataGrip*`, `com.jetbrains.datagrip*` |
| GoLand | `GoLand*`, `com.jetbrains.goland*` |
| Rider | `Rider*`, `com.jetbrains.rider*` |
| CLion | `CLion*`, `com.jetbrains.CLion*` |
| AppCode | `AppCode*`, `com.jetbrains.AppCode*` |
| Fleet | `Fleet*`, `com.jetbrains.fleet*` |
| Toolbox | `JetBrains/Toolbox`, `com.jetbrains.toolbox*` |

**Never use generic patterns** like `*jetbrains*` alone when targeting a single IDE.

## JetBrains File Locations (macOS)

```
~/Library/Application Support/JetBrains/{IDEName}{Version}/
├── options/          # XML configuration
├── colors/           # Color schemes
├── keymaps/          # Custom keymaps
├── codestyles/       # Code styles
├── templates/        # Live templates
└── plugins/          # Installed plugins

~/Library/Caches/JetBrains/{IDEName}{Version}/
~/Library/Logs/JetBrains/{IDEName}{Version}/
~/Library/Preferences/com.jetbrains.{ide}*.plist
~/Library/Saved Application State/com.jetbrains.{ide}*.savedState/
```

## Conventions

- **Language**: American English (code, comments, docs, messages)
- **Script filenames (.sh)**: kebab-case (`find-traces.sh`)
- **Generated files**: snake_case (`jetbrains_traces_*.txt`)

### File Naming Rules

**`./jose/` and `./tools/` folders:**
- All `.sh`, `.txt`, `.json`, `.md` files must use **kebab-case** (e.g., `configure-github-repo.sh`)
- Exception: `jose/PROMPTS.md` must remain **UPPERCASE**

**GitHub files (root and `.github/`):**
- Use the most popular case convention for public open-source repositories:
  - `README.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `LICENSE` (UPPERCASE)
  - `CLAUDE.md` (UPPERCASE)
  - `.github/CODEOWNERS`, `.github/PULL_REQUEST_TEMPLATE.md` (UPPERCASE)
  - `.github/ISSUE_TEMPLATE/bug_report.md`, `feature_request.md` (snake_case)
  - `.github/ISSUE_TEMPLATE/config.yml` (lowercase)

## Git Ignored Files

Generated outputs are not committed:
- `jetbrains_traces_*.txt` - Trace reports
- `jose/` - Personal notes
