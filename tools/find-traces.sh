#!/bin/bash
# =============================================================================
# JetBrains IDE Traces Finder
# =============================================================================
#
# PLATFORM:     macOS only (uses macOS-specific paths and commands)
# SHELL:        Bash (tested with GNU bash 3.2+)
#
# DESCRIPTION:
#   Scans the entire macOS filesystem to find all remaining files and folders
#   associated with a specific JetBrains IDE. Useful for verifying a complete
#   uninstall or diagnosing issues with residual files.
#
# SUPPORTED IDEs:
#   IntelliJ IDEA, PyCharm, WebStorm, PhpStorm, RubyMine, DataGrip,
#   GoLand, Rider, CLion, AppCode, Fleet, JetBrains Toolbox
#
# USAGE:
#   bash find_traces.sh    # Interactive IDE selection
#
# OUTPUT:
#   - Displays results in the terminal with color highlighting
#   - Exports a plain text report (.txt) for easy sharing with LLMs
#
# NOTE:
#   This script prioritizes functionality over code elegance. It may be long,
#   repetitive, and not fully optimized. Code refactoring is planned for a
#   future version.
#
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# =============================================================================
# IDE SELECTION
# =============================================================================
clear
echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║                    JETBRAINS IDE TRACES FINDER                           ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Select an IDE to search for:${NC}"
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
echo "  13) All JetBrains products"
echo ""
read -p "Enter your choice (1-13): " ide_choice
echo ""

# Set IDE-specific variables based on selection
# CRITICAL: Each IDE has UNIQUE patterns to avoid cross-contamination
case "$ide_choice" in
    1)
        IDE_NAME="IntelliJ IDEA"
        # Patterns specifically for IntelliJ IDEA
        PATTERNS=(
            "*IntelliJ*"
            "*intellij*"
            "*IdeaIC*"
            "*com.jetbrains.intellij*"
            "*jetbrains.intellij*"
        )
        ;;
    2)
        IDE_NAME="PyCharm"
        PATTERNS=(
            "*PyCharm*"
            "*pycharm*"
            "*com.jetbrains.pycharm*"
            "*jetbrains.pycharm*"
        )
        ;;
    3)
        IDE_NAME="WebStorm"
        PATTERNS=(
            "*WebStorm*"
            "*webstorm*"
            "*com.jetbrains.WebStorm*"
            "*jetbrains.webstorm*"
        )
        ;;
    4)
        IDE_NAME="PhpStorm"
        PATTERNS=(
            "*PhpStorm*"
            "*phpstorm*"
            "*com.jetbrains.PhpStorm*"
            "*jetbrains.phpstorm*"
        )
        ;;
    5)
        IDE_NAME="RubyMine"
        PATTERNS=(
            "*RubyMine*"
            "*rubymine*"
            "*com.jetbrains.rubymine*"
            "*jetbrains.rubymine*"
        )
        ;;
    6)
        IDE_NAME="DataGrip"
        PATTERNS=(
            "*DataGrip*"
            "*datagrip*"
            "*com.jetbrains.datagrip*"
            "*jetbrains.datagrip*"
        )
        ;;
    7)
        IDE_NAME="GoLand"
        PATTERNS=(
            "*GoLand*"
            "*goland*"
            "*com.jetbrains.goland*"
            "*jetbrains.goland*"
        )
        ;;
    8)
        IDE_NAME="Rider"
        PATTERNS=(
            "*Rider*"
            "*rider*"
            "*com.jetbrains.rider*"
            "*jetbrains.rider*"
        )
        ;;
    9)
        IDE_NAME="CLion"
        PATTERNS=(
            "*CLion*"
            "*clion*"
            "*com.jetbrains.CLion*"
            "*jetbrains.clion*"
        )
        ;;
    10)
        IDE_NAME="AppCode"
        PATTERNS=(
            "*AppCode*"
            "*appcode*"
            "*com.jetbrains.AppCode*"
            "*jetbrains.appcode*"
        )
        ;;
    11)
        IDE_NAME="Fleet"
        PATTERNS=(
            "*Fleet*"
            "*fleet*"
            "*com.jetbrains.fleet*"
            "*jetbrains.fleet*"
        )
        ;;
    12)
        IDE_NAME="JetBrains Toolbox"
        PATTERNS=(
            "*JetBrains*Toolbox*"
            "*jetbrains-toolbox*"
            "*com.jetbrains.toolbox*"
            "*jetbrains.toolbox*"
        )
        ;;
    13)
        IDE_NAME="All JetBrains products"
        # All patterns combined
        PATTERNS=(
            # IntelliJ IDEA
            "*IntelliJ*"
            "*intellij*"
            "*IdeaIC*"
            "*com.jetbrains.intellij*"
            # PyCharm
            "*PyCharm*"
            "*pycharm*"
            "*com.jetbrains.pycharm*"
            # WebStorm
            "*WebStorm*"
            "*webstorm*"
            "*com.jetbrains.WebStorm*"
            # PhpStorm
            "*PhpStorm*"
            "*phpstorm*"
            "*com.jetbrains.PhpStorm*"
            # RubyMine
            "*RubyMine*"
            "*rubymine*"
            "*com.jetbrains.rubymine*"
            # DataGrip
            "*DataGrip*"
            "*datagrip*"
            "*com.jetbrains.datagrip*"
            # GoLand
            "*GoLand*"
            "*goland*"
            "*com.jetbrains.goland*"
            # Rider
            "*Rider*"
            "*rider*"
            "*com.jetbrains.rider*"
            # CLion
            "*CLion*"
            "*clion*"
            "*com.jetbrains.CLion*"
            # AppCode
            "*AppCode*"
            "*appcode*"
            "*com.jetbrains.AppCode*"
            # Fleet
            "*Fleet*"
            "*fleet*"
            "*com.jetbrains.fleet*"
            # Toolbox
            "*jetbrains-toolbox*"
            "*com.jetbrains.toolbox*"
            # Generic JetBrains
            "*JetBrains*"
            "*jetbrains*"
        )
        ;;
    *)
        echo -e "${RED}[ERROR]${NC} Invalid choice. Please run the script again and select 1-13."
        exit 1
        ;;
esac

echo -e "${GREEN}[OK]${NC} Selected: $IDE_NAME"
echo ""

# =============================================================================
# OUTPUT FILE SETUP
# =============================================================================

# Create output directory and file (save in current working directory)
OUTPUT_DIR="$(pwd)"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
IDE_SLUG=$(echo "$IDE_NAME" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')
OUTPUT_FILE="$OUTPUT_DIR/jetbrains_traces_${IDE_SLUG}_${TIMESTAMP}.txt"

# =============================================================================
# CONFIGURATION
# =============================================================================

# Directories to search
SEARCH_DIRS=(
    "/"
)

# Directories to exclude from search
EXCLUDE_DIRS=(
    "$HOME/Projects"
    "$HOME/.Trash"
)

# =============================================================================
# HEADER
# =============================================================================
echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║                         JETBRAINS TRACES FINDER                          ║${NC}"
echo -e "${CYAN}${BOLD}║            Searching for: ${IDE_NAME}$(printf '%*s' $((47 - ${#IDE_NAME})) '')║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# =============================================================================
# DISPLAY CONFIGURATION
# =============================================================================
echo -e "${BOLD}Configuration:${NC}"
echo ""
echo -e "  ${GREEN}${BOLD}Search locations:${NC}"
for dir in "${SEARCH_DIRS[@]}"; do
    if [[ "$dir" == "/" ]]; then
        echo -e "    ${GREEN}✓${NC} ${BOLD}/${NC} ${DIM}(entire system)${NC}"
    else
        echo -e "    ${GREEN}✓${NC} $dir"
    fi
done
echo ""
echo -e "  ${RED}${BOLD}Excluded locations:${NC}"
for dir in "${EXCLUDE_DIRS[@]}"; do
    echo -e "    ${RED}✗${NC} $dir"
done
echo ""
echo -e "  ${MAGENTA}${BOLD}Search patterns:${NC}"
for pattern in "${PATTERNS[@]}"; do
    echo -e "    ${MAGENTA}?${NC} $pattern"
done
echo ""

# =============================================================================
# BUILD EXCLUDE ARGUMENTS FOR FIND COMMAND
# =============================================================================
EXCLUDE_ARGS=""
for dir in "${EXCLUDE_DIRS[@]}"; do
    EXCLUDE_ARGS="$EXCLUDE_ARGS -path \"$dir\" -prune -o"
    EXCLUDE_ARGS="$EXCLUDE_ARGS -path \"/System/Volumes/Data$dir\" -prune -o"
done

# Build pattern arguments
PATTERN_ARGS=""
for i in "${!PATTERNS[@]}"; do
    if [[ $i -eq 0 ]]; then
        PATTERN_ARGS="-iname \"${PATTERNS[$i]}\""
    else
        PATTERN_ARGS="$PATTERN_ARGS -o -iname \"${PATTERNS[$i]}\""
    fi
done

# =============================================================================
# RUN SEARCH
# =============================================================================
echo -e "${YELLOW}${BOLD}Starting search...${NC}"
echo -e "${DIM}This may take several minutes depending on your disk size.${NC}"
echo ""

START=$(date +%s)

# Create temporary file for results
RESULTS_FILE=$(mktemp)

for search_dir in "${SEARCH_DIRS[@]}"; do
    eval "find \"$search_dir\" $EXCLUDE_ARGS \\( $PATTERN_ARGS \\) -print 2>/dev/null"
done | sort -u > "$RESULTS_FILE"

END=$(date +%s)
DURATION=$((END - START))

# =============================================================================
# DISPLAY RESULTS
# =============================================================================
RESULT_COUNT=$(wc -l < "$RESULTS_FILE" | tr -d ' ')
SCAN_DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Results:${NC}"
echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# =============================================================================
# WRITE TO OUTPUT FILE (plain text for LLM consumption)
# =============================================================================
{
    echo "==============================================================================="
    echo "JETBRAINS IDE TRACES FINDER - SCAN REPORT"
    echo "==============================================================================="
    echo ""
    echo "IDE:            $IDE_NAME"
    echo "Scan date:      $SCAN_DATE"
    echo "Scan duration:  ${DURATION}s"
    echo "Files found:    $RESULT_COUNT"
    echo ""
    echo "Search patterns used:"
    for pattern in "${PATTERNS[@]}"; do
        echo "  - $pattern"
    done
    echo ""
    echo "Excluded directories:"
    for dir in "${EXCLUDE_DIRS[@]}"; do
        echo "  - $dir"
    done
    echo ""
    echo "==============================================================================="
    echo "RESULTS"
    echo "==============================================================================="
    echo ""
    if [[ $RESULT_COUNT -eq 0 ]]; then
        echo "No $IDE_NAME traces found. The system is clean."
    else
        echo "Found $RESULT_COUNT file(s)/folder(s) related to $IDE_NAME:"
        echo ""
        while IFS= read -r line; do
            if [[ "$line" != /System/Volumes/Data/* ]]; then
                echo "$line"
            fi
        done < "$RESULTS_FILE"
    fi
    echo ""
    echo "==============================================================================="
    echo "END OF REPORT"
    echo "==============================================================================="
} > "$OUTPUT_FILE"

# =============================================================================
# DISPLAY TO SCREEN
# =============================================================================
if [[ $RESULT_COUNT -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}  ✓ No $IDE_NAME traces found!${NC}"
    echo -e "${GREEN}    Your system is clean.${NC}"
else
    echo -e "${YELLOW}${BOLD}  ⚠ Found $RESULT_COUNT file(s)/folder(s) related to $IDE_NAME:${NC}"
    echo ""

    while IFS= read -r line; do
        # Skip /System/Volumes/Data duplicates for cleaner output
        if [[ "$line" != /System/Volumes/Data/* ]]; then
            echo -e "    ${RED}→${NC} $line"
        fi
    done < "$RESULTS_FILE"
fi

echo ""
echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Summary:${NC}"
echo -e "${CYAN}${BOLD}══════════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BOLD}IDE:${NC}            $IDE_NAME"
echo -e "  ${BOLD}Files found:${NC}    $RESULT_COUNT"
echo -e "  ${BOLD}Scan duration:${NC}  ${DURATION}s"
echo -e "  ${BOLD}Scan completed:${NC} $SCAN_DATE"
echo ""
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  📄 Report saved to:${NC}"
echo -e "${GREEN}     $OUTPUT_FILE${NC}"
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Cleanup
rm -f "$RESULTS_FILE"
