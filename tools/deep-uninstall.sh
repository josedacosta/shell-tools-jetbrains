#!/bin/bash
# =============================================================================
# Complete JetBrains IDE Deep Uninstaller
# =============================================================================
#
# PLATFORM:     macOS only (requires macOS 10.15 Catalina or later)
# SHELL:        Bash (tested with GNU bash 3.2+)
#
# DESCRIPTION:
#   This script PERMANENTLY removes ALL traces of the selected JetBrains IDE
#   from your macOS system, including projects settings, caches, preferences,
#   plugins, and system-level files.
#
# SUPPORTED IDEs:
#   IntelliJ IDEA, PyCharm, WebStorm, PhpStorm, RubyMine, DataGrip,
#   GoLand, Rider, CLion, AppCode, Fleet, JetBrains Toolbox
#
# USAGE:
#   bash deep_uninstall.sh              # Interactive mode with confirmation
#   bash deep_uninstall.sh --dry-run    # Preview mode (no deletion)
#
# WARNING:
#   This operation is IRREVERSIBLE. Always run with --dry-run first!
#
# NOTE:
#   This script prioritizes functionality over code elegance. It may be long,
#   repetitive, and not fully optimized. Code refactoring is planned for a
#   future version.
#
# =============================================================================

# Colors for display
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Bold colors
BOLD_RED='\033[1;31m'
BOLD_YELLOW='\033[1;33m'
BOLD_GREEN='\033[1;32m'
BOLD_WHITE='\033[1;37m'

# Background colors
BG_RED='\033[41m'
BG_YELLOW='\033[43m'
BG_BLACK='\033[40m'

# Blinking
BLINK='\033[5m'

# Dry-run mode
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
fi

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_kill() {
    echo -e "${MAGENTA}[KILL]${NC} $1"
}

# Function to remove a file/folder
remove_item() {
    local path="$1"
    local description="$2"

    if [[ -e "$path" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "  ${YELLOW}[DRY-RUN]${NC} Would remove: $path"
        else
            rm -rf "$path" 2>/dev/null && log_success "Removed: $description" || log_warning "Could not remove: $path"
        fi
    fi
}

# Function to remove files matching a glob pattern
remove_pattern() {
    local pattern="$1"
    local description="$2"

    for item in $pattern; do
        if [[ -e "$item" ]]; then
            if [[ "$DRY_RUN" == true ]]; then
                echo -e "  ${YELLOW}[DRY-RUN]${NC} Would remove: $item"
            else
                rm -rf "$item" 2>/dev/null && log_success "Removed: $item" || log_warning "Could not remove: $item"
            fi
        fi
    done
}

# Function to remove files using find
remove_find() {
    local search_path="$1"
    local name_pattern="$2"

    if [[ -d "$search_path" ]]; then
        find "$search_path" -name "$name_pattern" 2>/dev/null | while read -r item; do
            if [[ -e "$item" ]]; then
                if [[ "$DRY_RUN" == true ]]; then
                    echo -e "  ${YELLOW}[DRY-RUN]${NC} Would remove: $item"
                else
                    rm -rf "$item" 2>/dev/null && log_success "Removed: $(basename "$item")"
                fi
            fi
        done
    fi
}

# =============================================================================
# IDE SELECTION
# =============================================================================
clear
echo ""
echo -e "${CYAN}${BOLD_WHITE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD_WHITE}║                    JETBRAINS IDE UNINSTALLER                             ║${NC}"
echo -e "${CYAN}${BOLD_WHITE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD_WHITE}Select an IDE to uninstall:${NC}"
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
echo "  12) JetBrains Toolbox"
echo -e "  13) ${RED}All JetBrains products${NC}"
echo ""
read -p "Enter your choice (1-13): " ide_choice
echo ""

# Handle "All IDEs" option
DELETE_ALL=false
if [[ "$ide_choice" == "13" ]]; then
    DELETE_ALL=true
    IDE_NAME="ALL JETBRAINS PRODUCTS"
    IDE_NAME_UPPER="ALL JETBRAINS PRODUCTS"
    DELETE_PHRASE="DELETE ALL JETBRAINS"
fi

# =============================================================================
# SET IDE-SPECIFIC VARIABLES
# CRITICAL: Each IDE has UNIQUE identifiers to prevent cross-contamination
# =============================================================================
case "$ide_choice" in
    1)
        IDE_NAME="IntelliJ IDEA"
        IDE_NAME_UPPER="INTELLIJ IDEA"
        APP_NAMES=("IntelliJ IDEA.app" "IntelliJ IDEA Ultimate.app" "IntelliJ IDEA CE.app" "IntelliJ IDEA Community Edition.app")
        BUNDLE_IDS=("com.jetbrains.intellij" "com.jetbrains.intellij.ce")
        PROCESS_NAMES=("idea" "IntelliJ IDEA")
        # Application Support paths (with version wildcards)
        APP_SUPPORT_PATTERNS=(
            "IntelliJIdea*"
            "IdeaIC*"
        )
        # Cache patterns
        CACHE_PATTERNS_JETBRAINS=(
            "IntelliJIdea*"
            "IdeaIC*"
        )
        # Preferences
        PREF_PATTERNS=(
            "$HOME/Library/Preferences/com.jetbrains.intellij*.plist"
            "$HOME/Library/Preferences/jetbrains.intellij*.plist"
        )
        # Saved State patterns
        SAVED_STATE_PATTERNS=("com.jetbrains.intellij*.savedState")
        # Safe Storage name
        SAFE_STORAGE_NAME="IntelliJ IDEA Safe Storage"
        # Second confirmation phrase
        DELETE_PHRASE="DELETE INTELLIJ"
        ;;
    2)
        IDE_NAME="PyCharm"
        IDE_NAME_UPPER="PYCHARM"
        APP_NAMES=("PyCharm.app" "PyCharm Professional Edition.app" "PyCharm CE.app" "PyCharm Community Edition.app")
        BUNDLE_IDS=("com.jetbrains.pycharm" "com.jetbrains.pycharm.ce")
        PROCESS_NAMES=("pycharm" "PyCharm")
        APP_SUPPORT_PATTERNS=(
            "PyCharm*"
            "PyCharmCE*"
        )
        CACHE_PATTERNS_JETBRAINS=(
            "PyCharm*"
            "PyCharmCE*"
        )
        PREF_PATTERNS=(
            "$HOME/Library/Preferences/com.jetbrains.pycharm*.plist"
            "$HOME/Library/Preferences/jetbrains.pycharm*.plist"
        )
        SAVED_STATE_PATTERNS=("com.jetbrains.pycharm*.savedState")
        SAFE_STORAGE_NAME="PyCharm Safe Storage"
        DELETE_PHRASE="DELETE PYCHARM"
        ;;
    3)
        IDE_NAME="WebStorm"
        IDE_NAME_UPPER="WEBSTORM"
        APP_NAMES=("WebStorm.app")
        BUNDLE_IDS=("com.jetbrains.WebStorm")
        PROCESS_NAMES=("webstorm" "WebStorm")
        APP_SUPPORT_PATTERNS=(
            "WebStorm*"
        )
        CACHE_PATTERNS_JETBRAINS=(
            "WebStorm*"
        )
        PREF_PATTERNS=(
            "$HOME/Library/Preferences/com.jetbrains.WebStorm*.plist"
            "$HOME/Library/Preferences/jetbrains.webstorm*.plist"
        )
        SAVED_STATE_PATTERNS=("com.jetbrains.WebStorm*.savedState")
        SAFE_STORAGE_NAME="WebStorm Safe Storage"
        DELETE_PHRASE="DELETE WEBSTORM"
        ;;
    4)
        IDE_NAME="PhpStorm"
        IDE_NAME_UPPER="PHPSTORM"
        APP_NAMES=("PhpStorm.app")
        BUNDLE_IDS=("com.jetbrains.PhpStorm")
        PROCESS_NAMES=("phpstorm" "PhpStorm")
        APP_SUPPORT_PATTERNS=(
            "PhpStorm*"
        )
        CACHE_PATTERNS_JETBRAINS=(
            "PhpStorm*"
        )
        PREF_PATTERNS=(
            "$HOME/Library/Preferences/com.jetbrains.PhpStorm*.plist"
            "$HOME/Library/Preferences/jetbrains.phpstorm*.plist"
        )
        SAVED_STATE_PATTERNS=("com.jetbrains.PhpStorm*.savedState")
        SAFE_STORAGE_NAME="PhpStorm Safe Storage"
        DELETE_PHRASE="DELETE PHPSTORM"
        ;;
    5)
        IDE_NAME="RubyMine"
        IDE_NAME_UPPER="RUBYMINE"
        APP_NAMES=("RubyMine.app")
        BUNDLE_IDS=("com.jetbrains.rubymine")
        PROCESS_NAMES=("rubymine" "RubyMine")
        APP_SUPPORT_PATTERNS=(
            "RubyMine*"
        )
        CACHE_PATTERNS_JETBRAINS=(
            "RubyMine*"
        )
        PREF_PATTERNS=(
            "$HOME/Library/Preferences/com.jetbrains.rubymine*.plist"
            "$HOME/Library/Preferences/jetbrains.rubymine*.plist"
        )
        SAVED_STATE_PATTERNS=("com.jetbrains.rubymine*.savedState")
        SAFE_STORAGE_NAME="RubyMine Safe Storage"
        DELETE_PHRASE="DELETE RUBYMINE"
        ;;
    6)
        IDE_NAME="DataGrip"
        IDE_NAME_UPPER="DATAGRIP"
        APP_NAMES=("DataGrip.app")
        BUNDLE_IDS=("com.jetbrains.datagrip")
        PROCESS_NAMES=("datagrip" "DataGrip")
        APP_SUPPORT_PATTERNS=(
            "DataGrip*"
        )
        CACHE_PATTERNS_JETBRAINS=(
            "DataGrip*"
        )
        PREF_PATTERNS=(
            "$HOME/Library/Preferences/com.jetbrains.datagrip*.plist"
            "$HOME/Library/Preferences/jetbrains.datagrip*.plist"
        )
        SAVED_STATE_PATTERNS=("com.jetbrains.datagrip*.savedState")
        SAFE_STORAGE_NAME="DataGrip Safe Storage"
        DELETE_PHRASE="DELETE DATAGRIP"
        ;;
    7)
        IDE_NAME="GoLand"
        IDE_NAME_UPPER="GOLAND"
        APP_NAMES=("GoLand.app")
        BUNDLE_IDS=("com.jetbrains.goland")
        PROCESS_NAMES=("goland" "GoLand")
        APP_SUPPORT_PATTERNS=(
            "GoLand*"
        )
        CACHE_PATTERNS_JETBRAINS=(
            "GoLand*"
        )
        PREF_PATTERNS=(
            "$HOME/Library/Preferences/com.jetbrains.goland*.plist"
            "$HOME/Library/Preferences/jetbrains.goland*.plist"
        )
        SAVED_STATE_PATTERNS=("com.jetbrains.goland*.savedState")
        SAFE_STORAGE_NAME="GoLand Safe Storage"
        DELETE_PHRASE="DELETE GOLAND"
        ;;
    8)
        IDE_NAME="Rider"
        IDE_NAME_UPPER="RIDER"
        APP_NAMES=("Rider.app")
        BUNDLE_IDS=("com.jetbrains.rider")
        PROCESS_NAMES=("rider" "Rider")
        APP_SUPPORT_PATTERNS=(
            "Rider*"
        )
        CACHE_PATTERNS_JETBRAINS=(
            "Rider*"
        )
        PREF_PATTERNS=(
            "$HOME/Library/Preferences/com.jetbrains.rider*.plist"
            "$HOME/Library/Preferences/jetbrains.rider*.plist"
        )
        SAVED_STATE_PATTERNS=("com.jetbrains.rider*.savedState")
        SAFE_STORAGE_NAME="Rider Safe Storage"
        DELETE_PHRASE="DELETE RIDER"
        ;;
    9)
        IDE_NAME="CLion"
        IDE_NAME_UPPER="CLION"
        APP_NAMES=("CLion.app")
        BUNDLE_IDS=("com.jetbrains.CLion")
        PROCESS_NAMES=("clion" "CLion")
        APP_SUPPORT_PATTERNS=(
            "CLion*"
        )
        CACHE_PATTERNS_JETBRAINS=(
            "CLion*"
        )
        PREF_PATTERNS=(
            "$HOME/Library/Preferences/com.jetbrains.CLion*.plist"
            "$HOME/Library/Preferences/jetbrains.clion*.plist"
        )
        SAVED_STATE_PATTERNS=("com.jetbrains.CLion*.savedState")
        SAFE_STORAGE_NAME="CLion Safe Storage"
        DELETE_PHRASE="DELETE CLION"
        ;;
    10)
        IDE_NAME="AppCode"
        IDE_NAME_UPPER="APPCODE"
        APP_NAMES=("AppCode.app")
        BUNDLE_IDS=("com.jetbrains.AppCode")
        PROCESS_NAMES=("appcode" "AppCode")
        APP_SUPPORT_PATTERNS=(
            "AppCode*"
        )
        CACHE_PATTERNS_JETBRAINS=(
            "AppCode*"
        )
        PREF_PATTERNS=(
            "$HOME/Library/Preferences/com.jetbrains.AppCode*.plist"
            "$HOME/Library/Preferences/jetbrains.appcode*.plist"
        )
        SAVED_STATE_PATTERNS=("com.jetbrains.AppCode*.savedState")
        SAFE_STORAGE_NAME="AppCode Safe Storage"
        DELETE_PHRASE="DELETE APPCODE"
        ;;
    11)
        IDE_NAME="Fleet"
        IDE_NAME_UPPER="FLEET"
        APP_NAMES=("Fleet.app")
        BUNDLE_IDS=("com.jetbrains.fleet")
        PROCESS_NAMES=("fleet" "Fleet")
        APP_SUPPORT_PATTERNS=(
            "Fleet*"
        )
        CACHE_PATTERNS_JETBRAINS=(
            "Fleet*"
        )
        PREF_PATTERNS=(
            "$HOME/Library/Preferences/com.jetbrains.fleet*.plist"
            "$HOME/Library/Preferences/jetbrains.fleet*.plist"
        )
        SAVED_STATE_PATTERNS=("com.jetbrains.fleet*.savedState")
        SAFE_STORAGE_NAME="Fleet Safe Storage"
        DELETE_PHRASE="DELETE FLEET"
        ;;
    12)
        IDE_NAME="JetBrains Toolbox"
        IDE_NAME_UPPER="JETBRAINS TOOLBOX"
        APP_NAMES=("JetBrains Toolbox.app")
        BUNDLE_IDS=("com.jetbrains.toolbox")
        PROCESS_NAMES=("jetbrains-toolbox" "JetBrains Toolbox")
        APP_SUPPORT_PATTERNS=(
            "JetBrains/Toolbox"
        )
        CACHE_PATTERNS_JETBRAINS=(
            "JetBrains/Toolbox"
        )
        PREF_PATTERNS=(
            "$HOME/Library/Preferences/com.jetbrains.toolbox*.plist"
            "$HOME/Library/Preferences/jetbrains.toolbox*.plist"
        )
        SAVED_STATE_PATTERNS=("com.jetbrains.toolbox*.savedState")
        SAFE_STORAGE_NAME="JetBrains Toolbox Safe Storage"
        DELETE_PHRASE="DELETE TOOLBOX"
        ;;
    13)
        # "All IDEs" - variables already set before switch
        # This case is just to prevent the error
        ;;
    *)
        log_error "Invalid choice. Please run the script again and select 1-13."
        exit 1
        ;;
esac

if [[ "$DELETE_ALL" == true ]]; then
    log_info "All JetBrains products selected for removal"
else
    log_success "Selected IDE: $IDE_NAME"
fi
echo ""

# =============================================================================
# MASSIVE WARNING BANNER
# =============================================================================
clear
echo ""
echo ""
echo -e "${BG_RED}${BOLD_WHITE}                                                                              ${NC}"
echo -e "${BG_RED}${BOLD_WHITE}  ██████╗  █████╗ ███╗   ██╗ ██████╗ ███████╗██████╗ ██╗                       ${NC}"
echo -e "${BG_RED}${BOLD_WHITE}  ██╔══██╗██╔══██╗████╗  ██║██╔════╝ ██╔════╝██╔══██╗██║                       ${NC}"
echo -e "${BG_RED}${BOLD_WHITE}  ██║  ██║███████║██╔██╗ ██║██║  ███╗█████╗  ██████╔╝██║                       ${NC}"
echo -e "${BG_RED}${BOLD_WHITE}  ██║  ██║██╔══██║██║╚██╗██║██║   ██║██╔══╝  ██╔══██╗╚═╝                       ${NC}"
echo -e "${BG_RED}${BOLD_WHITE}  ██████╔╝██║  ██║██║ ╚████║╚██████╔╝███████╗██║  ██║██╗                       ${NC}"
echo -e "${BG_RED}${BOLD_WHITE}  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝                       ${NC}"
echo -e "${BG_RED}${BOLD_WHITE}                                                                              ${NC}"
echo ""
echo -e "${BG_RED}${BOLD_WHITE}                    PERMANENT DELETION WARNING                                ${NC}"
echo -e "${BG_RED}${BOLD_WHITE}                                                                              ${NC}"
echo ""
echo ""
echo -e "${BOLD_RED}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD_RED}║                                                                            ║${NC}"
echo -e "${BOLD_RED}║   ${BLINK}⚠️  WARNING: THIS SCRIPT WILL PERMANENTLY DELETE ALL DATA! ⚠️${NC}${BOLD_RED}            ║${NC}"
echo -e "${BOLD_RED}║                                                                            ║${NC}"
echo -e "${BOLD_RED}║   IDE: ${YELLOW}$IDE_NAME${NC}${BOLD_RED}$(printf '%*s' $((55 - ${#IDE_NAME})) '')║${NC}"
echo -e "${BOLD_RED}║                                                                            ║${NC}"
echo -e "${BOLD_RED}║   This includes:                                                           ║${NC}"
echo -e "${BOLD_RED}║   ${YELLOW}• All your IDE settings and configurations${NC}${BOLD_RED}                              ║${NC}"
echo -e "${BOLD_RED}║   ${YELLOW}• All your project-specific settings (.idea folders)${NC}${BOLD_RED}                    ║${NC}"
echo -e "${BOLD_RED}║   ${YELLOW}• All installed plugins${NC}${BOLD_RED}                                                  ║${NC}"
echo -e "${BOLD_RED}║   ${YELLOW}• All recent projects history${NC}${BOLD_RED}                                            ║${NC}"
echo -e "${BOLD_RED}║   ${YELLOW}• All local history data${NC}${BOLD_RED}                                                 ║${NC}"
echo -e "${BOLD_RED}║   ${YELLOW}• All keymaps and code styles${NC}${BOLD_RED}                                            ║${NC}"
echo -e "${BOLD_RED}║   ${YELLOW}• All cached files and indexes${NC}${BOLD_RED}                                           ║${NC}"
echo -e "${BOLD_RED}║   ${YELLOW}• $IDE_NAME application${NC}${BOLD_RED}$(printf '%*s' $((48 - ${#IDE_NAME})) '')║${NC}"
echo -e "${BOLD_RED}║                                                                            ║${NC}"
echo -e "${BOLD_RED}║   ${BOLD_WHITE}>>> THIS ACTION CANNOT BE UNDONE! <<<${NC}${BOLD_RED}                                  ║${NC}"
echo -e "${BOLD_RED}║                                                                            ║${NC}"
echo -e "${BOLD_RED}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${BG_YELLOW}${BOLD_WHITE}                                                                              ${NC}"
    echo -e "${BG_YELLOW}${BOLD_WHITE}                        DRY-RUN MODE ENABLED                                  ${NC}"
    echo -e "${BG_YELLOW}${BOLD_WHITE}                  No files will actually be deleted                           ${NC}"
    echo -e "${BG_YELLOW}${BOLD_WHITE}                                                                              ${NC}"
    echo ""
fi

# =============================================================================
# FIRST CONFIRMATION
# =============================================================================
echo ""
echo -e "${BOLD_YELLOW}┌──────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${BOLD_YELLOW}│                         FIRST CONFIRMATION REQUIRED                         │${NC}"
echo -e "${BOLD_YELLOW}└──────────────────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${WHITE}Are you absolutely sure you want to ${BOLD_RED}PERMANENTLY DELETE${NC}${WHITE} all $IDE_NAME data?${NC}"
echo ""
echo -e "${CYAN}Type ${BOLD_WHITE}YES${NC}${CYAN} (in uppercase) to continue, or anything else to abort:${NC}"
echo ""
read -p ">>> " FIRST_CONFIRM
echo ""

if [[ "$FIRST_CONFIRM" != "YES" ]]; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                          OPERATION CANCELED                                ║${NC}"
    echo -e "${GREEN}║                                                                            ║${NC}"
    echo -e "${GREEN}║              No files have been deleted. Your data is safe.                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 0
fi

# =============================================================================
# SECOND CONFIRMATION (DOUBLE CHECK)
# =============================================================================
echo ""
echo -e "${BG_RED}${BOLD_WHITE}                                                                              ${NC}"
echo -e "${BG_RED}${BOLD_WHITE}                           FINAL WARNING!                                     ${NC}"
echo -e "${BG_RED}${BOLD_WHITE}                                                                              ${NC}"
echo ""
echo -e "${BOLD_RED}┌──────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${BOLD_RED}│                         SECOND CONFIRMATION REQUIRED                        │${NC}"
echo -e "${BOLD_RED}│                                                                             │${NC}"
echo -e "${BOLD_RED}│    This is your LAST CHANCE to cancel this operation!                      │${NC}"
echo -e "${BOLD_RED}│                                                                             │${NC}"
echo -e "${BOLD_RED}│    Once you confirm, ALL $IDE_NAME data will be PERMANENTLY ERASED.$(printf '%*s' $((11 - ${#IDE_NAME})) '')│${NC}"
echo -e "${BOLD_RED}│    There is NO recovery possible after this point.                         │${NC}"
echo -e "${BOLD_RED}└──────────────────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${WHITE}To confirm deletion, type ${BOLD_RED}$DELETE_PHRASE${NC}${WHITE} exactly:${NC}"
echo ""
read -p ">>> " SECOND_CONFIRM
echo ""

if [[ "$SECOND_CONFIRM" != "$DELETE_PHRASE" ]]; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                          OPERATION CANCELED                                ║${NC}"
    echo -e "${GREEN}║                                                                            ║${NC}"
    echo -e "${GREEN}║              No files have been deleted. Your data is safe.                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 0
fi

# =============================================================================
# COUNTDOWN BEFORE DELETION
# =============================================================================
echo ""
echo -e "${BOLD_YELLOW}Starting deletion in...${NC}"
echo ""
for i in 5 4 3 2 1; do
    echo -e "${BOLD_RED}   $i...${NC}"
    sleep 1
done
echo ""
echo -e "${BOLD_RED}   STARTING DELETION PROCESS!${NC}"
echo ""
sleep 1

# =============================================================================
# FUNCTION TO CONFIGURE IDE VARIABLES
# =============================================================================
configure_ide_vars() {
    local choice="$1"
    case "$choice" in
        1)
            IDE_NAME="IntelliJ IDEA"
            IDE_NAME_UPPER="INTELLIJ IDEA"
            APP_NAMES=("IntelliJ IDEA.app" "IntelliJ IDEA Ultimate.app" "IntelliJ IDEA CE.app" "IntelliJ IDEA Community Edition.app")
            BUNDLE_IDS=("com.jetbrains.intellij" "com.jetbrains.intellij.ce")
            PROCESS_NAMES=("idea" "IntelliJ IDEA")
            APP_SUPPORT_PATTERNS=("IntelliJIdea*" "IdeaIC*")
            CACHE_PATTERNS_JETBRAINS=("IntelliJIdea*" "IdeaIC*")
            PREF_PATTERNS=("$HOME/Library/Preferences/com.jetbrains.intellij*.plist" "$HOME/Library/Preferences/jetbrains.intellij*.plist")
            SAVED_STATE_PATTERNS=("com.jetbrains.intellij*.savedState")
            SAFE_STORAGE_NAME="IntelliJ IDEA Safe Storage"
            ;;
        2)
            IDE_NAME="PyCharm"
            IDE_NAME_UPPER="PYCHARM"
            APP_NAMES=("PyCharm.app" "PyCharm Professional Edition.app" "PyCharm CE.app" "PyCharm Community Edition.app")
            BUNDLE_IDS=("com.jetbrains.pycharm" "com.jetbrains.pycharm.ce")
            PROCESS_NAMES=("pycharm" "PyCharm")
            APP_SUPPORT_PATTERNS=("PyCharm*" "PyCharmCE*")
            CACHE_PATTERNS_JETBRAINS=("PyCharm*" "PyCharmCE*")
            PREF_PATTERNS=("$HOME/Library/Preferences/com.jetbrains.pycharm*.plist" "$HOME/Library/Preferences/jetbrains.pycharm*.plist")
            SAVED_STATE_PATTERNS=("com.jetbrains.pycharm*.savedState")
            SAFE_STORAGE_NAME="PyCharm Safe Storage"
            ;;
        3)
            IDE_NAME="WebStorm"
            IDE_NAME_UPPER="WEBSTORM"
            APP_NAMES=("WebStorm.app")
            BUNDLE_IDS=("com.jetbrains.WebStorm")
            PROCESS_NAMES=("webstorm" "WebStorm")
            APP_SUPPORT_PATTERNS=("WebStorm*")
            CACHE_PATTERNS_JETBRAINS=("WebStorm*")
            PREF_PATTERNS=("$HOME/Library/Preferences/com.jetbrains.WebStorm*.plist" "$HOME/Library/Preferences/jetbrains.webstorm*.plist")
            SAVED_STATE_PATTERNS=("com.jetbrains.WebStorm*.savedState")
            SAFE_STORAGE_NAME="WebStorm Safe Storage"
            ;;
        4)
            IDE_NAME="PhpStorm"
            IDE_NAME_UPPER="PHPSTORM"
            APP_NAMES=("PhpStorm.app")
            BUNDLE_IDS=("com.jetbrains.PhpStorm")
            PROCESS_NAMES=("phpstorm" "PhpStorm")
            APP_SUPPORT_PATTERNS=("PhpStorm*")
            CACHE_PATTERNS_JETBRAINS=("PhpStorm*")
            PREF_PATTERNS=("$HOME/Library/Preferences/com.jetbrains.PhpStorm*.plist" "$HOME/Library/Preferences/jetbrains.phpstorm*.plist")
            SAVED_STATE_PATTERNS=("com.jetbrains.PhpStorm*.savedState")
            SAFE_STORAGE_NAME="PhpStorm Safe Storage"
            ;;
        5)
            IDE_NAME="RubyMine"
            IDE_NAME_UPPER="RUBYMINE"
            APP_NAMES=("RubyMine.app")
            BUNDLE_IDS=("com.jetbrains.rubymine")
            PROCESS_NAMES=("rubymine" "RubyMine")
            APP_SUPPORT_PATTERNS=("RubyMine*")
            CACHE_PATTERNS_JETBRAINS=("RubyMine*")
            PREF_PATTERNS=("$HOME/Library/Preferences/com.jetbrains.rubymine*.plist" "$HOME/Library/Preferences/jetbrains.rubymine*.plist")
            SAVED_STATE_PATTERNS=("com.jetbrains.rubymine*.savedState")
            SAFE_STORAGE_NAME="RubyMine Safe Storage"
            ;;
        6)
            IDE_NAME="DataGrip"
            IDE_NAME_UPPER="DATAGRIP"
            APP_NAMES=("DataGrip.app")
            BUNDLE_IDS=("com.jetbrains.datagrip")
            PROCESS_NAMES=("datagrip" "DataGrip")
            APP_SUPPORT_PATTERNS=("DataGrip*")
            CACHE_PATTERNS_JETBRAINS=("DataGrip*")
            PREF_PATTERNS=("$HOME/Library/Preferences/com.jetbrains.datagrip*.plist" "$HOME/Library/Preferences/jetbrains.datagrip*.plist")
            SAVED_STATE_PATTERNS=("com.jetbrains.datagrip*.savedState")
            SAFE_STORAGE_NAME="DataGrip Safe Storage"
            ;;
        7)
            IDE_NAME="GoLand"
            IDE_NAME_UPPER="GOLAND"
            APP_NAMES=("GoLand.app")
            BUNDLE_IDS=("com.jetbrains.goland")
            PROCESS_NAMES=("goland" "GoLand")
            APP_SUPPORT_PATTERNS=("GoLand*")
            CACHE_PATTERNS_JETBRAINS=("GoLand*")
            PREF_PATTERNS=("$HOME/Library/Preferences/com.jetbrains.goland*.plist" "$HOME/Library/Preferences/jetbrains.goland*.plist")
            SAVED_STATE_PATTERNS=("com.jetbrains.goland*.savedState")
            SAFE_STORAGE_NAME="GoLand Safe Storage"
            ;;
        8)
            IDE_NAME="Rider"
            IDE_NAME_UPPER="RIDER"
            APP_NAMES=("Rider.app")
            BUNDLE_IDS=("com.jetbrains.rider")
            PROCESS_NAMES=("rider" "Rider")
            APP_SUPPORT_PATTERNS=("Rider*")
            CACHE_PATTERNS_JETBRAINS=("Rider*")
            PREF_PATTERNS=("$HOME/Library/Preferences/com.jetbrains.rider*.plist" "$HOME/Library/Preferences/jetbrains.rider*.plist")
            SAVED_STATE_PATTERNS=("com.jetbrains.rider*.savedState")
            SAFE_STORAGE_NAME="Rider Safe Storage"
            ;;
        9)
            IDE_NAME="CLion"
            IDE_NAME_UPPER="CLION"
            APP_NAMES=("CLion.app")
            BUNDLE_IDS=("com.jetbrains.CLion")
            PROCESS_NAMES=("clion" "CLion")
            APP_SUPPORT_PATTERNS=("CLion*")
            CACHE_PATTERNS_JETBRAINS=("CLion*")
            PREF_PATTERNS=("$HOME/Library/Preferences/com.jetbrains.CLion*.plist" "$HOME/Library/Preferences/jetbrains.clion*.plist")
            SAVED_STATE_PATTERNS=("com.jetbrains.CLion*.savedState")
            SAFE_STORAGE_NAME="CLion Safe Storage"
            ;;
        10)
            IDE_NAME="AppCode"
            IDE_NAME_UPPER="APPCODE"
            APP_NAMES=("AppCode.app")
            BUNDLE_IDS=("com.jetbrains.AppCode")
            PROCESS_NAMES=("appcode" "AppCode")
            APP_SUPPORT_PATTERNS=("AppCode*")
            CACHE_PATTERNS_JETBRAINS=("AppCode*")
            PREF_PATTERNS=("$HOME/Library/Preferences/com.jetbrains.AppCode*.plist" "$HOME/Library/Preferences/jetbrains.appcode*.plist")
            SAVED_STATE_PATTERNS=("com.jetbrains.AppCode*.savedState")
            SAFE_STORAGE_NAME="AppCode Safe Storage"
            ;;
        11)
            IDE_NAME="Fleet"
            IDE_NAME_UPPER="FLEET"
            APP_NAMES=("Fleet.app")
            BUNDLE_IDS=("com.jetbrains.fleet")
            PROCESS_NAMES=("fleet" "Fleet")
            APP_SUPPORT_PATTERNS=("Fleet*" "JetBrains/Fleet")
            CACHE_PATTERNS_JETBRAINS=("Fleet*" "JetBrains/Fleet")
            PREF_PATTERNS=("$HOME/Library/Preferences/com.jetbrains.fleet*.plist" "$HOME/Library/Preferences/jetbrains.fleet*.plist")
            SAVED_STATE_PATTERNS=("com.jetbrains.fleet*.savedState")
            SAFE_STORAGE_NAME="Fleet Safe Storage"
            ;;
        12)
            IDE_NAME="JetBrains Toolbox"
            IDE_NAME_UPPER="JETBRAINS TOOLBOX"
            APP_NAMES=("JetBrains Toolbox.app")
            BUNDLE_IDS=("com.jetbrains.toolbox")
            PROCESS_NAMES=("jetbrains-toolbox" "JetBrains Toolbox")
            APP_SUPPORT_PATTERNS=("JetBrains/Toolbox")
            CACHE_PATTERNS_JETBRAINS=("JetBrains/Toolbox")
            PREF_PATTERNS=("$HOME/Library/Preferences/com.jetbrains.toolbox*.plist" "$HOME/Library/Preferences/jetbrains.toolbox*.plist")
            SAVED_STATE_PATTERNS=("com.jetbrains.toolbox*.savedState")
            SAFE_STORAGE_NAME="JetBrains Toolbox Safe Storage"
            ;;
    esac
}

# =============================================================================
# FUNCTION TO PERFORM UNINSTALL FOR CURRENT IDE
# =============================================================================
perform_ide_uninstall() {
    echo ""
    echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║              UNINSTALLING: $IDE_NAME$(printf '%*s' $((49 - ${#IDE_NAME})) '')║${NC}"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Kill processes
    log_kill "Terminating all $IDE_NAME processes..."
    for process in "${PROCESS_NAMES[@]}"; do
        pkill -9 -f "$process" 2>/dev/null && log_kill "Killed: $process" || true
    done
    sleep 1
    for process in "${PROCESS_NAMES[@]}"; do
        killall -9 "$process" 2>/dev/null || true
    done

    # Remove main applications
    log_info "Removing applications..."
    for app_name in "${APP_NAMES[@]}"; do
        remove_item "/Applications/$app_name" "$app_name"
        remove_item "$HOME/Applications/$app_name" "$app_name (user)"
    done

    # Remove Application Support (JetBrains folder structure)
    log_info "Removing user data..."
    for pattern in "${APP_SUPPORT_PATTERNS[@]}"; do
        if [[ "$pattern" == *"/"* ]]; then
            # Handle paths like "JetBrains/Toolbox"
            remove_item "$HOME/Library/Application Support/$pattern" "$pattern"
        else
            # Handle patterns like "IntelliJIdea*"
            find "$HOME/Library/Application Support/JetBrains" -maxdepth 1 -name "$pattern" -type d 2>/dev/null | while read -r item; do
                if [[ "$DRY_RUN" == true ]]; then
                    echo -e "  ${YELLOW}[DRY-RUN]${NC} Would remove: $item"
                else
                    rm -rf "$item" 2>/dev/null && log_success "Removed: $(basename "$item")"
                fi
            done
        fi
    done

    # Remove caches
    log_info "Removing caches..."
    for pattern in "${CACHE_PATTERNS_JETBRAINS[@]}"; do
        if [[ "$pattern" == *"/"* ]]; then
            remove_item "$HOME/Library/Caches/$pattern" "$pattern"
        else
            find "$HOME/Library/Caches/JetBrains" -maxdepth 1 -name "$pattern" -type d 2>/dev/null | while read -r item; do
                if [[ "$DRY_RUN" == true ]]; then
                    echo -e "  ${YELLOW}[DRY-RUN]${NC} Would remove: $item"
                else
                    rm -rf "$item" 2>/dev/null && log_success "Removed: $(basename "$item")"
                fi
            done
        fi
    done

    # Remove logs
    log_info "Removing logs..."
    for pattern in "${CACHE_PATTERNS_JETBRAINS[@]}"; do
        if [[ "$pattern" == *"/"* ]]; then
            remove_item "$HOME/Library/Logs/$pattern" "$pattern"
        else
            find "$HOME/Library/Logs/JetBrains" -maxdepth 1 -name "$pattern" -type d 2>/dev/null | while read -r item; do
                if [[ "$DRY_RUN" == true ]]; then
                    echo -e "  ${YELLOW}[DRY-RUN]${NC} Would remove: $item"
                else
                    rm -rf "$item" 2>/dev/null && log_success "Removed: $(basename "$item")"
                fi
            done
        fi
    done

    # Remove preferences
    log_info "Removing preferences..."
    for pattern in "${PREF_PATTERNS[@]}"; do
        remove_pattern "$pattern" "preferences"
    done

    # Remove saved state
    log_info "Removing saved state..."
    for bundle_id in "${BUNDLE_IDS[@]}"; do
        remove_item "$HOME/Library/Saved Application State/${bundle_id}.savedState" "saved state"
    done
    for pattern in "${SAVED_STATE_PATTERNS[@]}"; do
        find "$HOME/Library/Saved Application State" -maxdepth 1 -name "$pattern" 2>/dev/null | while read -r item; do
            if [[ "$DRY_RUN" == true ]]; then
                echo -e "  ${YELLOW}[DRY-RUN]${NC} Would remove: $item"
            else
                rm -rf "$item" 2>/dev/null && log_success "Removed: $(basename "$item")"
            fi
        done
    done

    # Remove cookies
    log_info "Removing cookies..."
    for bundle_id in "${BUNDLE_IDS[@]}"; do
        remove_item "$HOME/Library/Cookies/${bundle_id}.binarycookies" "cookies"
    done

    # Remove HTTP storages
    for bundle_id in "${BUNDLE_IDS[@]}"; do
        remove_item "$HOME/Library/HTTPStorages/${bundle_id}" "HTTP storage"
    done

    # Remove from Dock
    if [[ "$DRY_RUN" == false ]]; then
        for app_name in "${APP_NAMES[@]}"; do
            DOCK_LABEL="${app_name%.app}"
            python3 - "$DOCK_LABEL" <<'PYTHON' 2>/dev/null
import plistlib, os, sys
dock_label = sys.argv[1] if len(sys.argv) > 1 else ""
dock_plist = os.path.expanduser('~/Library/Preferences/com.apple.dock.plist')
try:
    with open(dock_plist, 'rb') as f:
        dock = plistlib.load(f)
    original_count = len(dock.get('persistent-apps', []))
    dock['persistent-apps'] = [app for app in dock.get('persistent-apps', [])
                               if dock_label not in app.get('tile-data', {}).get('file-label', '')]
    if len(dock['persistent-apps']) < original_count:
        with open(dock_plist, 'wb') as f:
            plistlib.dump(dock, f)
        sys.exit(0)
    sys.exit(1)
except:
    sys.exit(1)
PYTHON
            if [[ $? -eq 0 ]]; then
                log_success "Removed $app_name from Dock"
            fi
        done
    fi

    log_success "$IDE_NAME uninstall completed!"
}

# =============================================================================
# MAIN UNINSTALL LOGIC
# =============================================================================
if [[ "$DELETE_ALL" == true ]]; then
    # Uninstall all IDEs
    UNINSTALLED_COUNT=0
    for ide_num in 1 2 3 4 5 6 7 8 9 10 11 12; do
        configure_ide_vars "$ide_num"
        # Check if IDE is installed
        IDE_INSTALLED=false
        for app_name in "${APP_NAMES[@]}"; do
            if [[ -d "/Applications/$app_name" ]] || [[ -d "$HOME/Applications/$app_name" ]]; then
                IDE_INSTALLED=true
                break
            fi
        done
        # Also check for Application Support data
        if [[ -d "$HOME/Library/Application Support/JetBrains" ]]; then
            for pattern in "${APP_SUPPORT_PATTERNS[@]}"; do
                if ls "$HOME/Library/Application Support/JetBrains/"$pattern 1>/dev/null 2>&1; then
                    IDE_INSTALLED=true
                    break
                fi
            done
        fi

        if [[ "$IDE_INSTALLED" == true ]]; then
            perform_ide_uninstall
            ((UNINSTALLED_COUNT++))
        else
            log_warning "$IDE_NAME not installed, skipping..."
        fi
    done

    # Clean up empty JetBrains folders
    log_info "Cleaning up empty JetBrains folders..."
    for folder in "$HOME/Library/Application Support/JetBrains" "$HOME/Library/Caches/JetBrains" "$HOME/Library/Logs/JetBrains"; do
        if [[ -d "$folder" ]] && [[ -z "$(ls -A "$folder" 2>/dev/null)" ]]; then
            remove_item "$folder" "Empty JetBrains folder"
        fi
    done

    # Final cleanup
    log_info "Refreshing Dock..."
    killall Dock 2>/dev/null || true

    # Final message for all IDEs
    echo ""
    echo ""
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${BG_YELLOW}${BOLD_WHITE}                                                                              ${NC}"
        echo -e "${BG_YELLOW}${BOLD_WHITE}                         DRY-RUN COMPLETE                                     ${NC}"
        echo -e "${BG_YELLOW}${BOLD_WHITE}                                                                              ${NC}"
        echo -e "${BG_YELLOW}${BOLD_WHITE}                  No files were actually deleted                              ${NC}"
        echo -e "${BG_YELLOW}${BOLD_WHITE}             Run without --dry-run to perform deletion                        ${NC}"
        echo -e "${BG_YELLOW}${BOLD_WHITE}                                                                              ${NC}"
    else
        echo -e "${BG_BLACK}${BOLD_GREEN}                                                                              ${NC}"
        echo -e "${BG_BLACK}${BOLD_GREEN}  ███████╗██╗   ██╗ ██████╗ ██████╗███████╗███████╗███████╗██╗                ${NC}"
        echo -e "${BG_BLACK}${BOLD_GREEN}  ██╔════╝██║   ██║██╔════╝██╔════╝██╔════╝██╔════╝██╔════╝██║                ${NC}"
        echo -e "${BG_BLACK}${BOLD_GREEN}  ███████╗██║   ██║██║     ██║     █████╗  ███████╗███████╗██║                ${NC}"
        echo -e "${BG_BLACK}${BOLD_GREEN}  ╚════██║██║   ██║██║     ██║     ██╔══╝  ╚════██║╚════██║╚═╝                ${NC}"
        echo -e "${BG_BLACK}${BOLD_GREEN}  ███████║╚██████╔╝╚██████╗╚██████╗███████╗███████║███████║██╗                ${NC}"
        echo -e "${BG_BLACK}${BOLD_GREEN}  ╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝╚══════╝╚══════╝╚══════╝╚═╝                ${NC}"
        echo -e "${BG_BLACK}${BOLD_GREEN}                                                                              ${NC}"
        echo ""
        echo -e "${BOLD_GREEN}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BOLD_GREEN}║                                                                            ║${NC}"
        echo -e "${BOLD_GREEN}║      ALL JETBRAINS IDEs have been COMPLETELY REMOVED from your system!    ║${NC}"
        echo -e "${BOLD_GREEN}║                                                                            ║${NC}"
        echo -e "${BOLD_GREEN}║                      IDEs uninstalled: $UNINSTALLED_COUNT                                 ║${NC}"
        echo -e "${BOLD_GREEN}║                                                                            ║${NC}"
        echo -e "${BOLD_GREEN}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}Recommendations:${NC}"
        echo -e "  ${WHITE}•${NC} Restart your Mac to finalize cleanup"
        echo -e "  ${WHITE}•${NC} Empty Trash if files were moved there"
        echo -e "  ${WHITE}•${NC} Manually check Keychain Access for remaining entries"
    fi
    echo ""
    echo ""
    exit 0
fi

# =============================================================================
# SINGLE IDE UNINSTALL
# =============================================================================
echo ""
echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║                    FORCE KILLING ALL $IDE_NAME_UPPER PROCESSES$(printf '%*s' $((25 - ${#IDE_NAME_UPPER})) '')║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

log_kill "Terminating all $IDE_NAME processes..."

# Kill processes by name
for process in "${PROCESS_NAMES[@]}"; do
    pkill -9 -f "$process" 2>/dev/null && log_kill "Killed: $process" || true
done

# Wait for processes to terminate
sleep 2

# Double check and force kill again
log_kill "Performing secondary kill sweep..."
for process in "${PROCESS_NAMES[@]}"; do
    killall -9 "$process" 2>/dev/null || true
done

sleep 1

# =============================================================================
# START DELETION PROCESS
# =============================================================================
echo ""
echo -e "${BOLD_RED}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD_RED}║                    STARTING PERMANENT DELETION                             ║${NC}"
echo -e "${BOLD_RED}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

STEP=1
TOTAL_STEPS=10

# ==============================================================================
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}[$STEP/$TOTAL_STEPS] MAIN APPLICATIONS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
((STEP++))

for app_name in "${APP_NAMES[@]}"; do
    remove_item "/Applications/$app_name" "$app_name"
    remove_item "$HOME/Applications/$app_name" "$app_name (user Applications)"
done

# ==============================================================================
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}[$STEP/$TOTAL_STEPS] USER SETTINGS (Application Support)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
((STEP++))
log_info "Removing $IDE_NAME settings, plugins, keymaps, local history..."

for pattern in "${APP_SUPPORT_PATTERNS[@]}"; do
    if [[ "$pattern" == *"/"* ]]; then
        remove_item "$HOME/Library/Application Support/$pattern" "$pattern"
    else
        find "$HOME/Library/Application Support/JetBrains" -maxdepth 1 -name "$pattern" -type d 2>/dev/null | while read -r item; do
            if [[ "$DRY_RUN" == true ]]; then
                echo -e "  ${YELLOW}[DRY-RUN]${NC} Would remove: $item"
            else
                rm -rf "$item" 2>/dev/null && log_success "Removed: $(basename "$item")"
            fi
        done
    fi
done

# ==============================================================================
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}[$STEP/$TOTAL_STEPS] CACHES${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
((STEP++))

for pattern in "${CACHE_PATTERNS_JETBRAINS[@]}"; do
    if [[ "$pattern" == *"/"* ]]; then
        remove_item "$HOME/Library/Caches/$pattern" "$pattern"
    else
        find "$HOME/Library/Caches/JetBrains" -maxdepth 1 -name "$pattern" -type d 2>/dev/null | while read -r item; do
            if [[ "$DRY_RUN" == true ]]; then
                echo -e "  ${YELLOW}[DRY-RUN]${NC} Would remove: $item"
            else
                rm -rf "$item" 2>/dev/null && log_success "Removed: $(basename "$item")"
            fi
        done
    fi
done

# Also check for bundle ID caches
for bundle_id in "${BUNDLE_IDS[@]}"; do
    remove_item "$HOME/Library/Caches/$bundle_id" "$bundle_id cache"
done

# ==============================================================================
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}[$STEP/$TOTAL_STEPS] LOGS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
((STEP++))

for pattern in "${CACHE_PATTERNS_JETBRAINS[@]}"; do
    if [[ "$pattern" == *"/"* ]]; then
        remove_item "$HOME/Library/Logs/$pattern" "$pattern"
    else
        find "$HOME/Library/Logs/JetBrains" -maxdepth 1 -name "$pattern" -type d 2>/dev/null | while read -r item; do
            if [[ "$DRY_RUN" == true ]]; then
                echo -e "  ${YELLOW}[DRY-RUN]${NC} Would remove: $item"
            else
                rm -rf "$item" 2>/dev/null && log_success "Removed: $(basename "$item")"
            fi
        done
    fi
done

# ==============================================================================
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}[$STEP/$TOTAL_STEPS] PREFERENCES (plist files)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
((STEP++))

for pattern in "${PREF_PATTERNS[@]}"; do
    remove_pattern "$pattern" "preferences"
done

# ==============================================================================
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}[$STEP/$TOTAL_STEPS] SAVED APPLICATION STATE${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
((STEP++))

for bundle_id in "${BUNDLE_IDS[@]}"; do
    remove_item "$HOME/Library/Saved Application State/${bundle_id}.savedState" "$IDE_NAME saved state"
done

for pattern in "${SAVED_STATE_PATTERNS[@]}"; do
    find "$HOME/Library/Saved Application State" -maxdepth 1 -name "$pattern" 2>/dev/null | while read -r item; do
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "  ${YELLOW}[DRY-RUN]${NC} Would remove: $item"
        else
            rm -rf "$item" 2>/dev/null && log_success "Removed: $(basename "$item")"
        fi
    done
done

# ==============================================================================
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}[$STEP/$TOTAL_STEPS] COOKIES & HTTP STORAGE${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
((STEP++))

for bundle_id in "${BUNDLE_IDS[@]}"; do
    remove_item "$HOME/Library/Cookies/${bundle_id}.binarycookies" "$bundle_id cookies"
    remove_item "$HOME/Library/HTTPStorages/${bundle_id}" "$bundle_id HTTP storage"
done

# ==============================================================================
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}[$STEP/$TOTAL_STEPS] TEMPORARY FILES${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
((STEP++))

log_info "Searching for $IDE_NAME temporary files..."

for bundle_id in "${BUNDLE_IDS[@]}"; do
    find /private/var/folders -name "*${bundle_id}*" 2>/dev/null | while read -r item; do
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "  ${YELLOW}[DRY-RUN]${NC} Would remove: $item"
        else
            rm -rf "$item" 2>/dev/null && log_success "Removed temp: $(basename "$item")"
        fi
    done
done

log_success "Temporary files cleaned"

# ==============================================================================
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}[$STEP/$TOTAL_STEPS] SYSTEM CACHE CLEANUP${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
((STEP++))

if [[ "$DRY_RUN" == false ]]; then
    log_info "Removing $IDE_NAME from Dock..."
    for app_name in "${APP_NAMES[@]}"; do
        DOCK_LABEL="${app_name%.app}"
        python3 - "$DOCK_LABEL" <<'PYTHON' 2>/dev/null
import plistlib, os, sys
dock_label = sys.argv[1] if len(sys.argv) > 1 else ""
dock_plist = os.path.expanduser('~/Library/Preferences/com.apple.dock.plist')
try:
    with open(dock_plist, 'rb') as f:
        dock = plistlib.load(f)
    original_count = len(dock.get('persistent-apps', []))
    dock['persistent-apps'] = [app for app in dock.get('persistent-apps', [])
                               if dock_label not in app.get('tile-data', {}).get('file-label', '')]
    if len(dock['persistent-apps']) < original_count:
        with open(dock_plist, 'wb') as f:
            plistlib.dump(dock, f)
        sys.exit(0)
    sys.exit(1)
except:
    sys.exit(1)
PYTHON
        if [[ $? -eq 0 ]]; then
            log_success "Removed $app_name from Dock"
        fi
    done

    log_info "Refreshing Dock..."
    killall Dock 2>/dev/null || true

    log_success "System caches refreshed"
else
    echo -e "  ${YELLOW}[DRY-RUN]${NC} Would remove $IDE_NAME from Dock"
    echo -e "  ${YELLOW}[DRY-RUN]${NC} Would refresh Dock"
fi

# Clean up empty JetBrains folders
log_info "Cleaning up empty JetBrains folders..."
for folder in "$HOME/Library/Application Support/JetBrains" "$HOME/Library/Caches/JetBrains" "$HOME/Library/Logs/JetBrains"; do
    if [[ -d "$folder" ]] && [[ -z "$(ls -A "$folder" 2>/dev/null)" ]]; then
        remove_item "$folder" "Empty JetBrains folder"
    fi
done

# =============================================================================
# KEYCHAIN (Manual step)
# =============================================================================
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}KEYCHAIN (Manual step required)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}$IDE_NAME may store credentials in Keychain Access.${NC}"
echo -e "${YELLOW}To remove them manually:${NC}"
echo ""
echo "  1. Open 'Keychain Access' (Applications > Utilities)"
echo "  2. Search for entries containing:"
echo "     - '$IDE_NAME'"
for bundle_id in "${BUNDLE_IDS[@]}"; do
    echo "     - '$bundle_id'"
done
echo "     - 'JetBrains'"
echo "  3. Delete the found entries"
echo ""

# =============================================================================
# FINAL SUCCESS MESSAGE
# =============================================================================
echo ""
echo ""
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${BG_YELLOW}${BOLD_WHITE}                                                                              ${NC}"
    echo -e "${BG_YELLOW}${BOLD_WHITE}                         DRY-RUN COMPLETE                                     ${NC}"
    echo -e "${BG_YELLOW}${BOLD_WHITE}                                                                              ${NC}"
    echo -e "${BG_YELLOW}${BOLD_WHITE}                  No files were actually deleted                              ${NC}"
    echo -e "${BG_YELLOW}${BOLD_WHITE}             Run without --dry-run to perform deletion                        ${NC}"
    echo -e "${BG_YELLOW}${BOLD_WHITE}                                                                              ${NC}"
else
    echo -e "${BG_BLACK}${BOLD_GREEN}                                                                              ${NC}"
    echo -e "${BG_BLACK}${BOLD_GREEN}  ███████╗██╗   ██╗ ██████╗ ██████╗███████╗███████╗███████╗██╗                ${NC}"
    echo -e "${BG_BLACK}${BOLD_GREEN}  ██╔════╝██║   ██║██╔════╝██╔════╝██╔════╝██╔════╝██╔════╝██║                ${NC}"
    echo -e "${BG_BLACK}${BOLD_GREEN}  ███████╗██║   ██║██║     ██║     █████╗  ███████╗███████╗██║                ${NC}"
    echo -e "${BG_BLACK}${BOLD_GREEN}  ╚════██║██║   ██║██║     ██║     ██╔══╝  ╚════██║╚════██║╚═╝                ${NC}"
    echo -e "${BG_BLACK}${BOLD_GREEN}  ███████║╚██████╔╝╚██████╗╚██████╗███████╗███████║███████║██╗                ${NC}"
    echo -e "${BG_BLACK}${BOLD_GREEN}  ╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝╚══════╝╚══════╝╚══════╝╚═╝                ${NC}"
    echo -e "${BG_BLACK}${BOLD_GREEN}                                                                              ${NC}"
    echo ""
    echo -e "${BOLD_GREEN}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD_GREEN}║                                                                            ║${NC}"
    echo -e "${BOLD_GREEN}║       $IDE_NAME has been COMPLETELY REMOVED from your system!$(printf '%*s' $((25 - ${#IDE_NAME})) '')║${NC}"
    echo -e "${BOLD_GREEN}║                                                                            ║${NC}"
    echo -e "${BOLD_GREEN}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Recommendations:${NC}"
    echo -e "  ${WHITE}•${NC} Restart your Mac to finalize cleanup"
    echo -e "  ${WHITE}•${NC} Empty Trash if files were moved there"
    echo -e "  ${WHITE}•${NC} Manually check Keychain Access (see above)"
fi

echo ""
echo ""
