#!/bin/bash
#
# Compare two git versions (branches, tags, commits) using Meld or Diffuse.
# Optionally compare only a specific subdirectory.
#
# NOTE: This script is READ-ONLY with respect to your repo. It checks out each
# version into temporary directories and launches a GUI diff tool on those.
# Any edits you make in the GUI apply only to the temp copies and are deleted
# when you close the tool.
#
# Usage:
#   ./compare-two-versions.sh [-n] [-t meld|diffuse] <VERSION_A> <VERSION_B> [SUBDIR]
#
# Examples:
#   ./compare-two-versions.sh next-ver next-ver-dedi10
#   ./compare-two-versions.sh -t diffuse next-ver next-ver-dedi10
#   ./compare-two-versions.sh next-ver next-ver-dedi10 lib
#   ./compare-two-versions.sh -n main next-ver src/tools     # dry-run, show diffstat only
#

set -e

# --- Colors (only if stdout is a terminal) ---
if [ -t 1 ]; then
    C_RED=$'\033[31m'
    C_GREEN=$'\033[32m'
    C_YELLOW=$'\033[33m'
    C_BLUE=$'\033[34m'
    C_MAGENTA=$'\033[35m'
    C_CYAN=$'\033[36m'
    C_BOLD=$'\033[1m'
    C_RESET=$'\033[0m'
else
    C_RED=""
    C_GREEN=""
    C_YELLOW=""
    C_BLUE=""
    C_MAGENTA=""
    C_CYAN=""
    C_BOLD=""
    C_RESET=""
fi

usage() {
    echo "Usage: $0 [-n] [-t meld|diffuse] <VERSION_A> <VERSION_B> [SUBDIR]"
    echo
    echo "  -n           Dry run (show info + diffstat only, no GUI)"
    echo "  -t TOOL      Choose tool: 'meld' (default) or 'diffuse'"
    exit 1
}

DRY_RUN=0
TOOL="meld"

# --- Parse options ---
while getopts ":nt:" opt; do
    case "$opt" in
        n)
            DRY_RUN=1
            ;;
        t)
            TOOL="$OPTARG"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND - 1))

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    usage
fi

VERSION_A="$1"
VERSION_B="$2"
SUBDIR="$3"    # may be empty

# --- Ensure valid tool ---
if [ "$TOOL" != "meld" ] && [ "$TOOL" != "diffuse" ]; then
    echo "${C_RED}Error:${C_RESET} tool must be 'meld' or 'diffuse'."
    exit 1
fi

if ! command -v "$TOOL" >/dev/null 2>&1; then
    echo "${C_RED}Error:${C_RESET} '$TOOL' not found in PATH."
    exit 1
fi

# --- Ensure we’re in a git repo ---
if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "${C_RED}Error:${C_RESET} this script must be run inside a git repository."
    exit 1
fi

# --- Verify the versions exist ---
if ! git rev-parse --verify "$VERSION_A^{object}" >/dev/null 2>&1; then
    echo "${C_RED}Error:${C_RESET} version '$VERSION_A' not found."
    exit 1
fi

if ! git rev-parse --verify "$VERSION_B^{object}" >/dev/null 2>&1; then
    echo "${C_RED}Error:${C_RESET} version '$VERSION_B' not found."
    exit 1
fi

echo "${C_BOLD}${C_CYAN}Comparing git versions:${C_RESET}"
echo "  ${C_GREEN}A${C_RESET}: $VERSION_A"
echo "  ${C_GREEN}B${C_RESET}: $VERSION_B"
if [ -n "$SUBDIR" ]; then
    echo "  ${C_YELLOW}Subdirectory only${C_RESET}: $SUBDIR"
fi
echo "  ${C_YELLOW}Tool${C_RESET}: $TOOL"
echo

# --- Show diffstat first ---
echo "${C_BOLD}${C_BLUE}Diffstat:${C_RESET}"
if [ -n "$SUBDIR" ]; then
    if ! git diff --stat "$VERSION_A" "$VERSION_B" -- "$SUBDIR"; then
        echo "${C_RED}Error:${C_RESET} failed to compute diffstat."
        exit 1
    fi
else
    if ! git diff --stat "$VERSION_A" "$VERSION_B"; then
        echo "${C_RED}Error:${C_RESET} failed to compute diffstat."
        exit 1
    fi
fi
echo

if [ "$DRY_RUN" -eq 1 ]; then
    echo "${C_BOLD}${C_MAGENTA}Dry run enabled.${C_RESET} No GUI will be launched and no temp trees created."
    exit 0
fi

# --- Create secure temporary directories ---
TMPDIR_A=$(mktemp -d "/tmp/${VERSION_A//\//_}-XXXXXX")
TMPDIR_B=$(mktemp -d "/tmp/${VERSION_B//\//_}-XXXXXX")

cleanup() {
    echo
    echo "${C_BLUE}Cleaning up temporary directories...${C_RESET}"
    rm -rf "$TMPDIR_A" "$TMPDIR_B"
    echo "${C_GREEN}Done.${C_RESET}"
}
trap cleanup EXIT

echo "${C_BOLD}Temp directories:${C_RESET}"
echo "  A -> $TMPDIR_A"
echo "  B -> $TMPDIR_B"
echo

# --- Extract trees ---
if [ -z "$SUBDIR" ]; then
    echo "${C_BLUE}Extracting full tree for ${C_GREEN}$VERSION_A${C_RESET}..."
    git --work-tree="$TMPDIR_A" checkout "$VERSION_A" -- .

    echo "${C_BLUE}Extracting full tree for ${C_GREEN}$VERSION_B${C_RESET}..."
    git --work-tree="$TMPDIR_B" checkout "$VERSION_B" -- .
else
    # Ensure SUBDIR exists in both versions (as any path under that prefix)
    if ! git ls-tree -r --name-only "$VERSION_A" -- "$SUBDIR" | grep -q .; then
        echo "${C_RED}Error:${C_RESET} subdirectory '$SUBDIR' not found in version '$VERSION_A'."
        exit 1
    fi

    if ! git ls-tree -r --name-only "$VERSION_B" -- "$SUBDIR" | grep -q .; then
        echo "${C_RED}Error:${C_RESET} subdirectory '$SUBDIR' not found in version '$VERSION_B'."
        exit 1
    fi

    echo "${C_BLUE}Extracting subdirectory '$SUBDIR' from ${C_GREEN}$VERSION_A${C_RESET}..."
    git --work-tree="$TMPDIR_A" checkout "$VERSION_A" -- "$SUBDIR"

    echo "${C_BLUE}Extracting subdirectory '$SUBDIR' from ${C_GREEN}$VERSION_B${C_RESET}..."
    git --work-tree="$TMPDIR_B" checkout "$VERSION_B" -- "$SUBDIR"
fi

echo
echo "${C_BOLD}${C_CYAN}Launching $TOOL...${C_RESET}"
$TOOL "$TMPDIR_A" "$TMPDIR_B"

# When the tool closes, cleanup() runs via trap.
