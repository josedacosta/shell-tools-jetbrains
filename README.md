<div align="center">

```
       ██╗███████╗████████╗██████╗ ██████╗  █████╗ ██╗███╗   ██╗███████╗
       ██║██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔════╝
       ██║█████╗     ██║   ██████╔╝██████╔╝███████║██║██╔██╗ ██║███████╗
  ██   ██║██╔══╝     ██║   ██╔══██╗██╔══██╗██╔══██║██║██║╚██╗██║╚════██║
  ╚█████╔╝███████╗   ██║   ██████╔╝██║  ██║██║  ██║██║██║ ╚████║███████║
   ╚════╝ ╚══════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝
                  ─────── TOOLS ───────
```

**Deep uninstall and find traces of JetBrains IDEs on macOS**

[![Platform](https://img.shields.io/badge/platform-macOS-blue?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Shell](https://img.shields.io/badge/shell-bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/license-MIT-yellow?style=for-the-badge)](LICENSE)
[![No Dependencies](https://img.shields.io/badge/dependencies-none-brightgreen?style=for-the-badge)]()

</div>

---

## Why This Repository?

### The Problem

On macOS, simply dragging a JetBrains IDE to the Trash **does not actually uninstall it**. JetBrains IDEs leave behind a significant amount of residual data scattered across your system:

- **IDE settings and configurations** in `~/Library/Application Support/JetBrains/`
- **Caches and indexes** in `~/Library/Caches/JetBrains/`
- **Logs** in `~/Library/Logs/JetBrains/`
- **Preferences** (`.plist` files) in `~/Library/Preferences/`
- **Saved states** in `~/Library/Saved Application State/`
- **Plugins** in the IDE configuration folder
- **Recent projects history**
- **Local history data**
- And much more...

When you reinstall the IDE, **all this residual data is reused**. This means:
- Old corrupted settings may cause bugs or slowdowns
- Outdated plugins may cause compatibility issues
- You never get the "fresh install" experience
- Performance issues from previous installs carry over
- Indexing problems persist

### The Solution

This repository provides Bash scripts for **complete, deep cleaning** of JetBrains IDEs on macOS. The goal is simple: **start from scratch** with a truly clean slate, as if the IDE had never been installed on your machine.

---

## Quick Start

```bash
# Clone the repository
git clone https://github.com/josedacosta/shell-tools-jetbrains.git
cd shell-tools-jetbrains

# Run a script
bash tools/deep-uninstall.sh --dry-run
```

---

## What Each Script Does

| Script | Purpose |
|--------|---------|
| [`deep-uninstall.sh`](tools/deep-uninstall.sh) | **Complete removal** — Deletes the IDE AND all its traces from the entire system |
| [`find-traces.sh`](tools/find-traces.sh) | **Verification** — Scans your system to find any remaining IDE files |

### Recommended Workflow

1. **Export your settings** using **File > Manage IDE Settings > Export Settings...** (optional)
2. **Preview the deletion** with `tools/deep-uninstall.sh --dry-run`
3. **Run the deep uninstall** with `tools/deep-uninstall.sh`
4. **Verify the cleanup** with `tools/find-traces.sh`
5. **Reinstall the IDE** fresh from JetBrains website or Toolbox
6. **Import your settings** using **File > Manage IDE Settings > Import Settings...**

---

## Supported IDEs

<details>
<summary><b>View all 12 supported IDEs</b></summary>

| IDE | Bundle ID | Application Support Path |
|-----|-----------|--------------------------|
| IntelliJ IDEA ¹ | `com.jetbrains.intellij` | `~/Library/Application Support/JetBrains/IntelliJIdea*` |
| PyCharm ² | `com.jetbrains.pycharm` | `~/Library/Application Support/JetBrains/PyCharm*` |
| WebStorm | `com.jetbrains.WebStorm` | `~/Library/Application Support/JetBrains/WebStorm*` |
| PhpStorm | `com.jetbrains.PhpStorm` | `~/Library/Application Support/JetBrains/PhpStorm*` |
| RubyMine | `com.jetbrains.rubymine` | `~/Library/Application Support/JetBrains/RubyMine*` |
| DataGrip | `com.jetbrains.datagrip` | `~/Library/Application Support/JetBrains/DataGrip*` |
| GoLand | `com.jetbrains.goland` | `~/Library/Application Support/JetBrains/GoLand*` |
| Rider | `com.jetbrains.rider` | `~/Library/Application Support/JetBrains/Rider*` |
| CLion | `com.jetbrains.CLion` | `~/Library/Application Support/JetBrains/CLion*` |
| AppCode | `com.jetbrains.AppCode` | `~/Library/Application Support/JetBrains/AppCode*` |
| Fleet | `com.jetbrains.fleet` | `~/Library/Application Support/JetBrains/Fleet*` |
| JetBrains Toolbox | `com.jetbrains.toolbox` | `~/Library/Application Support/JetBrains/Toolbox` |

> ¹ **IntelliJ IDEA** includes both Ultimate and Community Edition — they are removed together.
>
> ² **PyCharm** includes both Professional and Community Edition — they are removed together.

</details>

---

## Available Scripts

### 1. `deep-uninstall.sh` - Complete Uninstaller

**Purpose**: Completely remove an IDE and ALL its traces from the system.

This script performs a full purge, going far beyond a simple uninstall. It removes:

| Category | What Gets Removed |
|----------|-------------------|
| Application | `.app` file from `/Applications` and `~/Applications` |
| IDE settings | Configuration, keymaps, code styles, live templates |
| Plugins | All installed plugins |
| Caches | All IDE and project caches, indexes |
| Logs | All IDE logs |
| Preferences | `.plist` files in `~/Library/Preferences` |
| Saved State | Saved application states |
| Cookies | HTTP storage and cookies |
| Temporary files | In `/private/var/folders` |
| Dock | Removes icon from Dock |

#### Usage

```bash
# Dry-run mode (no deletion)
bash tools/deep-uninstall.sh --dry-run

# Actual deletion (requires double confirmation)
bash tools/deep-uninstall.sh
```

#### Built-in Safety Features

1. **Double confirmation**: You must type `YES` then a specific phrase (e.g., `DELETE INTELLIJ`)
2. **5-second countdown**: Delay before deletion starts
3. **Dry-run mode**: Preview what would be deleted without removing anything
4. **IDE isolation**: Each IDE uses its own identifiers, no risk of deleting another IDE's files

#### Interactive Menu

```
Select an IDE to uninstall:

  1) IntelliJ IDEA (Ultimate + Community)
  2) PyCharm (Professional + Community)
  3) WebStorm
  4) PhpStorm
  5) RubyMine
  6) DataGrip
  7) GoLand
  8) Rider
  9) CLion
  10) AppCode
  11) Fleet
  12) JetBrains Toolbox
  13) All JetBrains products    <- Removes ALL IDEs
```

---

### 2. `find-traces.sh` - Traces Finder

**Purpose**: Scan the system to find all remaining files/folders from an IDE.

Useful for:
- Verifying that an uninstall is complete
- Finding leftover files after a manual uninstall
- Diagnosing issues related to residual files

#### Usage

```bash
bash tools/find-traces.sh
```

#### How It Works

1. Displays an IDE selection menu
2. Scans the entire system (`/`) with configurable exclusions
3. Uses IDE-specific patterns
4. Displays a list of all found files/folders
5. Exports results to a `.txt` file for easy sharing

#### Default Exclusions

- `~/Projects` - Avoids scanning your development projects
- `~/.Trash` - Ignores the trash

---

## Security and Isolation

**CRITICAL**: Each script uses UNIQUE identifiers per IDE to prevent cross-contamination.

Example - If you select WebStorm:
- Only `WebStorm*` and `com.jetbrains.WebStorm*` files are targeted
- No IntelliJ IDEA, PyCharm, etc. files are touched

This isolation is guaranteed by:
1. IDE-specific variables (`BUNDLE_IDS`, `APP_NAMES`, etc.)
2. Unique search patterns for each IDE
3. Version-specific folder patterns (e.g., `WebStorm2024.1`)

---

## Usage Examples

<details>
<summary><b>Scenario 1: Clean IntelliJ IDEA Reinstall</b></summary>

```bash
# 1. Export current settings (optional)
# In the IDE: File > Manage IDE Settings > Export Settings...

# 2. Preview what will be deleted
bash tools/deep-uninstall.sh --dry-run
# Choose 1) IntelliJ IDEA

# 3. Completely remove IntelliJ IDEA
bash tools/deep-uninstall.sh
# Choose 1) IntelliJ IDEA
# Confirm with YES then DELETE INTELLIJ

# 4. Verify nothing remains
bash tools/find-traces.sh
# Choose 1) IntelliJ IDEA
# Should display "No IntelliJ IDEA traces found!"

# 5. Reinstall IntelliJ IDEA and import settings
# Use File > Manage IDE Settings > Import Settings...
```

</details>

<details>
<summary><b>Scenario 2: Remove All JetBrains Products</b></summary>

```bash
# Remove ALL JetBrains IDEs
bash tools/deep-uninstall.sh
# Choose 13) All JetBrains products
# Confirm with YES then DELETE ALL JETBRAINS
```

</details>

<details>
<summary><b>Scenario 3: Diagnostics</b></summary>

```bash
# IDE behaving strangely? Look for residual files
bash tools/find-traces.sh
# Choose the IDE you want to investigate
```

</details>

---

## Important Notes

> [!CAUTION]
> **Back up your data** before using `deep-uninstall.sh` — deletion is **IRREVERSIBLE**.

> [!TIP]
> **Always use `--dry-run` first** to preview what will be deleted.

- **Keychain** may contain IDE credentials (instructions provided at script end)
- **Project `.idea` folders** are NOT removed (they are in your project directories)

---

## System Requirements

| Requirement | Details |
|-------------|---------|
| **Operating System** | macOS 10.15 Catalina or later |
| **Shell** | Bash 3.2+ (included with macOS by default) |
| **Terminal** | Any macOS terminal (Terminal.app, iTerm2, etc.) |
| **Dependencies** | None |

### Verifying Your Shell

```bash
# Check your Bash version
bash --version
# Should output: GNU bash, version 3.2.57 or later
```

> [!NOTE]
> These scripts use macOS-specific paths (`~/Library/Application Support/`, etc.) and commands. They are **not compatible** with Linux or Windows without modification.

---

## License

This project is licensed under the [MIT License](LICENSE) — free to use, modify, and distribute.
