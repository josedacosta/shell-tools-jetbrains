#!/bin/bash
set -euo pipefail
# =============================================================================
# JetBrains IDE Settings Export Script
# =============================================================================
#
# PLATFORM:     macOS (primary) / Linux (secondary support)
# SHELL:        Bash (tested with GNU bash 3.2+)
#
# DESCRIPTION:
#   Exports JetBrains IDE settings to a human-readable Markdown file for manual
#   replication after a clean reinstall. Also copies the raw settings folder
#   for potential import.
#
# SUPPORTED IDEs:
#   IntelliJ IDEA, PyCharm, WebStorm, PhpStorm, RubyMine, DataGrip,
#   GoLand, Rider, CLion, AppCode, Fleet
#
# USAGE:
#   bash export_settings.sh    # Interactive IDE and version selection
#
# OUTPUT:
#   Creates a timestamped folder containing:
#   - {IDE}_SETTINGS.md        Human-readable settings summary
#   - options/                 Raw IDE options (XML files)
#   - colors/                  Color schemes
#   - keymaps/                 Custom keymaps
#   - plugins_list.txt         List of installed plugins
#
# NOTE:
#   This script prioritizes functionality over code elegance. It may be long,
#   repetitive, and not fully optimized. Code refactoring is planned for a
#   future version.
#
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Verify OS is supported
if [[ "$OSTYPE" != "darwin"* ]] && [[ "$OSTYPE" != "linux"* ]]; then
    log_error "Unsupported OS: $OSTYPE"
    exit 1
fi

# Script directory for output
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# IDE CONFIGURATION FUNCTION
# =============================================================================
set_ide_config() {
    local choice="$1"

    case "$choice" in
        1)
            IDE_NAME="IntelliJ IDEA"
            IDE_SHORT="intellij"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                IDE_BASE="$HOME/Library/Application Support/JetBrains"
            else
                IDE_BASE="$HOME/.config/JetBrains"
            fi
            SETTINGS_FILE_NAME="INTELLIJ_SETTINGS.md"
            # Patterns for finding IDE versions
            VERSION_PATTERNS=("IntelliJIdea*" "IdeaIC*")
            ;;
        2)
            IDE_NAME="PyCharm"
            IDE_SHORT="pycharm"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                IDE_BASE="$HOME/Library/Application Support/JetBrains"
            else
                IDE_BASE="$HOME/.config/JetBrains"
            fi
            SETTINGS_FILE_NAME="PYCHARM_SETTINGS.md"
            VERSION_PATTERNS=("PyCharm*" "PyCharmCE*")
            ;;
        3)
            IDE_NAME="WebStorm"
            IDE_SHORT="webstorm"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                IDE_BASE="$HOME/Library/Application Support/JetBrains"
            else
                IDE_BASE="$HOME/.config/JetBrains"
            fi
            SETTINGS_FILE_NAME="WEBSTORM_SETTINGS.md"
            VERSION_PATTERNS=("WebStorm*")
            ;;
        4)
            IDE_NAME="PhpStorm"
            IDE_SHORT="phpstorm"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                IDE_BASE="$HOME/Library/Application Support/JetBrains"
            else
                IDE_BASE="$HOME/.config/JetBrains"
            fi
            SETTINGS_FILE_NAME="PHPSTORM_SETTINGS.md"
            VERSION_PATTERNS=("PhpStorm*")
            ;;
        5)
            IDE_NAME="RubyMine"
            IDE_SHORT="rubymine"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                IDE_BASE="$HOME/Library/Application Support/JetBrains"
            else
                IDE_BASE="$HOME/.config/JetBrains"
            fi
            SETTINGS_FILE_NAME="RUBYMINE_SETTINGS.md"
            VERSION_PATTERNS=("RubyMine*")
            ;;
        6)
            IDE_NAME="DataGrip"
            IDE_SHORT="datagrip"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                IDE_BASE="$HOME/Library/Application Support/JetBrains"
            else
                IDE_BASE="$HOME/.config/JetBrains"
            fi
            SETTINGS_FILE_NAME="DATAGRIP_SETTINGS.md"
            VERSION_PATTERNS=("DataGrip*")
            ;;
        7)
            IDE_NAME="GoLand"
            IDE_SHORT="goland"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                IDE_BASE="$HOME/Library/Application Support/JetBrains"
            else
                IDE_BASE="$HOME/.config/JetBrains"
            fi
            SETTINGS_FILE_NAME="GOLAND_SETTINGS.md"
            VERSION_PATTERNS=("GoLand*")
            ;;
        8)
            IDE_NAME="Rider"
            IDE_SHORT="rider"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                IDE_BASE="$HOME/Library/Application Support/JetBrains"
            else
                IDE_BASE="$HOME/.config/JetBrains"
            fi
            SETTINGS_FILE_NAME="RIDER_SETTINGS.md"
            VERSION_PATTERNS=("Rider*")
            ;;
        9)
            IDE_NAME="CLion"
            IDE_SHORT="clion"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                IDE_BASE="$HOME/Library/Application Support/JetBrains"
            else
                IDE_BASE="$HOME/.config/JetBrains"
            fi
            SETTINGS_FILE_NAME="CLION_SETTINGS.md"
            VERSION_PATTERNS=("CLion*")
            ;;
        10)
            IDE_NAME="AppCode"
            IDE_SHORT="appcode"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                IDE_BASE="$HOME/Library/Application Support/JetBrains"
            else
                return 1  # AppCode not available on Linux
            fi
            SETTINGS_FILE_NAME="APPCODE_SETTINGS.md"
            VERSION_PATTERNS=("AppCode*")
            ;;
        11)
            IDE_NAME="Fleet"
            IDE_SHORT="fleet"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                IDE_BASE="$HOME/Library/Application Support/JetBrains"
            else
                IDE_BASE="$HOME/.config/JetBrains"
            fi
            SETTINGS_FILE_NAME="FLEET_SETTINGS.md"
            VERSION_PATTERNS=("Fleet*")
            ;;
        *)
            return 1
            ;;
    esac
    return 0
}

# =============================================================================
# UTILITY FUNCTIONS FOR XML EXTRACTION
# =============================================================================
extract_xml_value() {
    local file="$1"
    local xpath="$2"
    local default="${3:-(not set)}"

    if [[ -f "$file" ]]; then
        # Use grep and sed for basic XML extraction (no external dependencies)
        local result=$(grep -o "$xpath" "$file" 2>/dev/null | head -1 | sed 's/.*="\([^"]*\)".*/\1/' || echo "")
        if [[ -n "$result" ]]; then
            echo "$result"
        else
            echo "$default"
        fi
    else
        echo "$default"
    fi
}

extract_xml_option() {
    local file="$1"
    local option_name="$2"
    local default="${3:-(not set)}"

    if [[ -f "$file" ]]; then
        local result=$(grep "name=\"$option_name\"" "$file" 2>/dev/null | grep -o 'value="[^"]*"' | sed 's/value="\([^"]*\)"/\1/' | head -1 || echo "")
        if [[ -n "$result" ]]; then
            echo "$result"
        else
            echo "$default"
        fi
    else
        echo "$default"
    fi
}

section_header() {
    echo ""
    echo "---"
    echo ""
    echo "## $1"
    echo ""
}

subsection() {
    echo ""
    echo "### $1"
    echo ""
}

# =============================================================================
# EXPORT FUNCTION FOR A SINGLE IDE
# =============================================================================
export_ide() {
    local ide_num="$1"
    local auto_version="${2:-false}"  # If true, auto-select latest version

    if ! set_ide_config "$ide_num"; then
        return 1
    fi

    # Check if IDE base folder exists
    if [[ ! -d "$IDE_BASE" ]]; then
        if [[ "$auto_version" == true ]]; then
            log_warn "$IDE_NAME settings folder not found, skipping..."
            return 1
        else
            log_error "JetBrains settings folder not found: $IDE_BASE"
            log_error "Make sure $IDE_NAME has been run at least once."
            return 1
        fi
    fi

    echo ""
    echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}  Exporting: $IDE_NAME${NC}"
    echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Find available versions
    VERSIONS=()
    for pattern in "${VERSION_PATTERNS[@]}"; do
        while IFS= read -r -d '' dir; do
            VERSIONS+=("$(basename "$dir")")
        done < <(find "$IDE_BASE" -maxdepth 1 -type d -name "$pattern" -print0 2>/dev/null | sort -zr)
    done

    if [[ ${#VERSIONS[@]} -eq 0 ]]; then
        if [[ "$auto_version" == true ]]; then
            log_warn "No $IDE_NAME versions found, skipping..."
            return 1
        else
            log_error "No $IDE_NAME versions found in: $IDE_BASE"
            return 1
        fi
    fi

    # Version selection
    log_info "Available $IDE_NAME versions:"
    for i in "${!VERSIONS[@]}"; do
        echo "  $((i+1))) ${VERSIONS[$i]}"
    done

    if [[ "$auto_version" == true ]]; then
        # Auto-select the latest version (first in sorted list)
        SELECTED_VERSION="${VERSIONS[0]}"
        log_info "Auto-selecting version: $SELECTED_VERSION"
    elif [[ ${#VERSIONS[@]} -eq 1 ]]; then
        SELECTED_VERSION="${VERSIONS[0]}"
        log_info "Single version found, auto-selecting: $SELECTED_VERSION"
    else
        echo ""
        read -p "Select a version (1-${#VERSIONS[@]}) [1]: " choice
        choice=${choice:-1}
        if [[ "$choice" -lt 1 || "$choice" -gt ${#VERSIONS[@]} ]]; then
            log_error "Invalid choice"
            return 1
        fi
        SELECTED_VERSION="${VERSIONS[$((choice-1))]}"
        log_success "Selected version: $SELECTED_VERSION"
    fi

    VERSION_DIR="$IDE_BASE/$SELECTED_VERSION"
    OPTIONS_DIR="$VERSION_DIR/options"

    if [[ ! -d "$OPTIONS_DIR" ]]; then
        log_error "Options folder not found for version: $SELECTED_VERSION"
        return 1
    fi

    # Create backup folder
    TS="$(date +%Y%m%d-%H%M%S)"
    OUT_DIR="$SCRIPT_DIR/export-settings-${IDE_SHORT}-$TS"
    mkdir -p "$OUT_DIR"

    # Copy raw settings folders
    log_info "Copying raw settings..."
    [[ -d "$OPTIONS_DIR" ]] && cp -r "$OPTIONS_DIR" "$OUT_DIR/options" && log_success "Copied: options/"
    [[ -d "$VERSION_DIR/colors" ]] && cp -r "$VERSION_DIR/colors" "$OUT_DIR/colors" && log_success "Copied: colors/"
    [[ -d "$VERSION_DIR/keymaps" ]] && cp -r "$VERSION_DIR/keymaps" "$OUT_DIR/keymaps" && log_success "Copied: keymaps/"
    [[ -d "$VERSION_DIR/codestyles" ]] && cp -r "$VERSION_DIR/codestyles" "$OUT_DIR/codestyles" && log_success "Copied: codestyles/"
    [[ -d "$VERSION_DIR/templates" ]] && cp -r "$VERSION_DIR/templates" "$OUT_DIR/templates" && log_success "Copied: templates/"
    [[ -d "$VERSION_DIR/inspection" ]] && cp -r "$VERSION_DIR/inspection" "$OUT_DIR/inspection" && log_success "Copied: inspection/"

    # Export plugins list
    PLUGINS_DIR="$VERSION_DIR/plugins"
    if [[ -d "$PLUGINS_DIR" ]]; then
        log_info "Exporting plugins list..."
        ls -1 "$PLUGINS_DIR" 2>/dev/null > "$OUT_DIR/plugins_list.txt"
        log_success "Plugins list saved"
    fi

    # Generate summary file
    SUMMARY="$OUT_DIR/$SETTINGS_FILE_NAME"

    {
        echo "# $IDE_NAME Settings Export"
        echo ""
        echo "**Export date:** $(date '+%Y-%m-%d %H:%M:%S')"
        echo "**IDE:** $IDE_NAME"
        echo "**Version:** $SELECTED_VERSION"
        echo "**Full path:** \`$VERSION_DIR\`"
        echo ""

        section_header "EDITOR SETTINGS"

        if [[ -f "$OPTIONS_DIR/editor.xml" ]]; then
            echo "### General Editor Settings"
            echo ""
            echo "| Setting | Value |"
            echo "|---------|-------|"

            font_size=$(extract_xml_option "$OPTIONS_DIR/editor.xml" "FONT_SIZE" "12")
            echo "| Font size | $font_size |"

            line_spacing=$(extract_xml_option "$OPTIONS_DIR/editor.xml" "LINE_SPACING" "1.0")
            echo "| Line spacing | $line_spacing |"

            show_line_numbers=$(extract_xml_option "$OPTIONS_DIR/editor.xml" "ARE_LINE_NUMBERS_SHOWN" "true")
            echo "| Show line numbers | $show_line_numbers |"

            use_soft_wraps=$(extract_xml_option "$OPTIONS_DIR/editor.xml" "USE_SOFT_WRAPS" "false")
            echo "| Use soft wraps | $use_soft_wraps |"

            show_whitespaces=$(extract_xml_option "$OPTIONS_DIR/editor.xml" "IS_WHITESPACES_SHOWN" "false")
            echo "| Show whitespaces | $show_whitespaces |"

            echo ""
            echo "*Settings > Editor > General*"
        else
            echo "*(editor.xml not found - using defaults)*"
        fi

        section_header "CODE STYLE"

        if [[ -f "$OPTIONS_DIR/code.style.schemes.xml" ]]; then
            echo "### Code Style Scheme"
            echo ""
            current_scheme=$(grep -o 'CURRENT_SCHEME_NAME="[^"]*"' "$OPTIONS_DIR/code.style.schemes.xml" 2>/dev/null | sed 's/CURRENT_SCHEME_NAME="\([^"]*\)"/\1/' || echo "Default")
            echo "**Current scheme:** $current_scheme"
            echo ""
            echo "*Settings > Editor > Code Style*"
        fi

        section_header "KEYMAP"

        if [[ -f "$OPTIONS_DIR/keymap.xml" ]]; then
            echo "### Active Keymap"
            echo ""
            active_keymap=$(grep -o 'active_keymap="[^"]*"' "$OPTIONS_DIR/keymap.xml" 2>/dev/null | sed 's/active_keymap="\([^"]*\)"/\1/' || echo "Default")
            echo "**Active keymap:** $active_keymap"
            echo ""
        fi

        # List custom keymaps if any
        if [[ -d "$VERSION_DIR/keymaps" ]] && [[ -n "$(ls -A "$VERSION_DIR/keymaps" 2>/dev/null)" ]]; then
            echo "### Custom Keymaps"
            echo ""
            for keymap in "$VERSION_DIR/keymaps"/*.xml; do
                if [[ -f "$keymap" ]]; then
                    echo "- $(basename "$keymap" .xml)"
                fi
            done
            echo ""
        fi
        echo "*Settings > Keymap*"

        section_header "APPEARANCE"

        if [[ -f "$OPTIONS_DIR/laf.xml" ]]; then
            echo "### Look and Feel"
            echo ""
            laf=$(grep -o 'laf="[^"]*"' "$OPTIONS_DIR/laf.xml" 2>/dev/null | sed 's/laf="\([^"]*\)"/\1/' || echo "Default")
            echo "**Theme:** $laf"
            echo ""
        fi

        if [[ -f "$OPTIONS_DIR/colors.scheme.xml" ]]; then
            echo "### Color Scheme"
            echo ""
            color_scheme=$(grep -o 'name="[^"]*"' "$OPTIONS_DIR/colors.scheme.xml" 2>/dev/null | head -1 | sed 's/name="\([^"]*\)"/\1/' || echo "Default")
            echo "**Active color scheme:** $color_scheme"
            echo ""
        fi

        # List custom color schemes
        if [[ -d "$VERSION_DIR/colors" ]] && [[ -n "$(ls -A "$VERSION_DIR/colors" 2>/dev/null)" ]]; then
            echo "### Custom Color Schemes"
            echo ""
            for scheme in "$VERSION_DIR/colors"/*.icls; do
                if [[ -f "$scheme" ]]; then
                    echo "- $(basename "$scheme" .icls)"
                fi
            done
            echo ""
        fi
        echo "*Settings > Appearance & Behavior > Appearance*"

        section_header "VERSION CONTROL"

        if [[ -f "$OPTIONS_DIR/vcs.xml" ]]; then
            echo "### VCS Settings"
            echo ""

            confirm_push=$(extract_xml_option "$OPTIONS_DIR/vcs.xml" "CONFIRM_PUSH" "true")
            echo "- **Confirm push:** $confirm_push"

            update_type=$(extract_xml_option "$OPTIONS_DIR/vcs.xml" "UPDATE_TYPE" "default")
            echo "- **Update type:** $update_type"

            echo ""
            echo "*Settings > Version Control*"
        fi

        section_header "INSTALLED PLUGINS"

        echo "### Plugins"
        echo ""

        if [[ -f "$OUT_DIR/plugins_list.txt" ]] && [[ -s "$OUT_DIR/plugins_list.txt" ]]; then
            plugin_count=$(wc -l < "$OUT_DIR/plugins_list.txt" | tr -d ' ')
            echo "**Total plugins:** $plugin_count"
            echo ""
            echo "| Plugin Name |"
            echo "|-------------|"
            while IFS= read -r plugin; do
                echo "| $plugin |"
            done < "$OUT_DIR/plugins_list.txt"
            echo ""
            echo "**To reinstall:** Open $IDE_NAME > Settings > Plugins > Marketplace"
        else
            echo "*(No custom plugins installed or plugins folder not found)*"
        fi
        echo ""
        echo "*Settings > Plugins*"

        section_header "RECENT PROJECTS"

        if [[ -f "$OPTIONS_DIR/recentProjects.xml" ]]; then
            echo "### Recent Projects"
            echo ""
            echo "Recent projects are stored in \`recentProjects.xml\`."
            echo ""
            # Extract project paths
            projects=$(grep -o 'key="[^"]*"' "$OPTIONS_DIR/recentProjects.xml" 2>/dev/null | sed 's/key="\([^"]*\)"/\1/' | grep "^\$USER_HOME" | head -10 || true)
            if [[ -n "$projects" ]]; then
                echo "**Last 10 projects:**"
                echo ""
                echo "$projects" | while read -r project; do
                    # Replace $USER_HOME$ with actual path for display
                    display_path=$(echo "$project" | sed "s|\\\$USER_HOME\\\$|~|g")
                    echo "- \`$display_path\`"
                done
            fi
            echo ""
        fi

        section_header "LIVE TEMPLATES"

        if [[ -d "$VERSION_DIR/templates" ]] && [[ -n "$(ls -A "$VERSION_DIR/templates" 2>/dev/null)" ]]; then
            echo "### Custom Live Templates"
            echo ""
            echo "Custom live templates found:"
            echo ""
            for template in "$VERSION_DIR/templates"/*.xml; do
                if [[ -f "$template" ]]; then
                    template_name=$(basename "$template" .xml)
                    echo "- $template_name"
                fi
            done
            echo ""
            echo "Templates have been copied to the export folder."
        else
            echo "*(No custom live templates found)*"
        fi
        echo ""
        echo "*Settings > Editor > Live Templates*"

        section_header "FILE TYPES"

        if [[ -f "$OPTIONS_DIR/filetypes.xml" ]]; then
            echo "### Custom File Types"
            echo ""
            echo "Custom file type associations are stored in \`filetypes.xml\`."
            echo "This file has been copied to the export folder."
            echo ""
            echo "*Settings > Editor > File Types*"
        fi

        section_header "HOW TO REPLICATE THESE SETTINGS"

        echo "### Option 1: Import Settings (Recommended)"
        echo ""
        echo "1. Open $IDE_NAME"
        echo "2. Go to **File > Manage IDE Settings > Import Settings...**"
        echo "3. Select the \`options\` folder from this export"
        echo "4. Choose which settings to import"
        echo "5. Restart the IDE"
        echo ""

        echo "### Option 2: Manual Configuration"
        echo ""
        echo "1. **Theme & Appearance:** Settings > Appearance & Behavior"
        echo "2. **Keymap:** Settings > Keymap"
        echo "3. **Editor Settings:** Settings > Editor > General"
        echo "4. **Code Style:** Settings > Editor > Code Style"
        echo "5. **Plugins:** Settings > Plugins > Marketplace"
        echo ""

        echo "### Option 3: Sync Settings (JetBrains Account)"
        echo ""
        echo "If you have a JetBrains account, you can sync settings:"
        echo ""
        echo "1. Go to **Settings > Settings Sync**"
        echo "2. Sign in with your JetBrains account"
        echo "3. Enable sync for desired categories"
        echo ""

        echo "### Reference Files"
        echo ""
        echo "Raw configuration files are available in:"
        echo "\`$OUT_DIR\`"
        echo ""
        echo "- \`options/\` - IDE settings (XML files)"
        echo "- \`colors/\` - Custom color schemes"
        echo "- \`keymaps/\` - Custom keymaps"
        echo "- \`codestyles/\` - Code style settings"
        echo "- \`templates/\` - Live templates"
        echo "- \`plugins_list.txt\` - Installed plugins"
        echo ""

        echo "---"
        echo "*Generated by export-settings.sh on $(date '+%Y-%m-%d %H:%M:%S')*"

    } > "$SUMMARY"

    # Final summary for this IDE
    echo ""
    log_success "Export complete for $IDE_NAME!"
    echo ""
    echo "Files created in: $OUT_DIR"
    echo ""
    echo "   $SETTINGS_FILE_NAME     - Readable summary (Markdown)"
    echo "   options/                 - Raw IDE settings"
    if [[ -d "$OUT_DIR/colors" ]]; then
        echo "   colors/                  - Custom color schemes"
    fi
    if [[ -d "$OUT_DIR/keymaps" ]]; then
        echo "   keymaps/                 - Custom keymaps"
    fi
    if [[ -f "$OUT_DIR/plugins_list.txt" ]]; then
        echo "   plugins_list.txt         - Installed plugins"
    fi
    echo ""

    return 0
}

# =============================================================================
# IDE SELECTION
# =============================================================================
clear
echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║                 JETBRAINS IDE SETTINGS EXPORT                            ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Select an IDE to export settings from:${NC}"
echo ""
echo -e "  1) IntelliJ IDEA ${DIM}(Ultimate + Community)${NC}"
echo -e "  2) PyCharm ${DIM}(Professional + Community)${NC}"
echo "  3) WebStorm"
echo "  4) PhpStorm"
echo "  5) RubyMine"
echo "  6) DataGrip"
echo "  7) GoLand"
echo "  8) Rider"
echo "  9) CLion"
echo "  10) AppCode"
echo "  11) Fleet"
echo "  12) All IDEs"
echo ""
read -p "Enter your choice (1-12): " ide_choice
echo ""

# =============================================================================
# MAIN EXECUTION
# =============================================================================
if [[ "$ide_choice" == "12" ]]; then
    # Export all IDEs
    log_info "Exporting settings for all installed JetBrains IDEs..."
    echo ""

    EXPORTED_COUNT=0
    FAILED_COUNT=0

    for i in 1 2 3 4 5 6 7 8 9 10 11; do
        if export_ide "$i" true; then
            ((EXPORTED_COUNT++))
        else
            ((FAILED_COUNT++))
        fi
    done

    echo ""
    echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}  EXPORT SUMMARY${NC}"
    echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${GREEN}IDEs exported:${NC} $EXPORTED_COUNT"
    echo -e "  ${YELLOW}IDEs skipped:${NC}  $FAILED_COUNT (not installed)"
    echo ""
else
    # Export single IDE
    if ! export_ide "$ide_choice" false; then
        exit 1
    fi
fi

echo "Open the generated Markdown files to see the replication guides"
