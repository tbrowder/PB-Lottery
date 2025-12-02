#!/bin/bash
#
# Compare two branches using Meld, with automatic cleanup.
# Branches: next-ver  and  next-ver-dedi10
#
# Usage: ./compare-next-ver-meld.sh
#

set -e

BRANCH_A="next-ver"
BRANCH_B="next-ver-dedi10"

# Create secure temporary directories
TMPDIR_A=$(mktemp -d "/tmp/${BRANCH_A}-XXXXXX")
TMPDIR_B=$(mktemp -d "/tmp/${BRANCH_B}-XXXXXX")

cleanup() {
    echo
    echo "Cleaning up temporary directories..."
    rm -rf "$TMPDIR_A" "$TMPDIR_B"
    echo "Done."
}
trap cleanup EXIT

echo "Temp directories created:"
echo "  $TMPDIR_A"
echo "  $TMPDIR_B"
echo

echo "Extracting branch $BRANCH_A..."
git --work-tree="$TMPDIR_A" checkout "$BRANCH_A" -- .

echo "Extracting branch $BRANCH_B..."
git --work-tree="$TMPDIR_B" checkout "$BRANCH_B" -- .

echo "Launching Meld..."
meld "$TMPDIR_A" "$TMPDIR_B"

# When Meld closes, the trap runs and removes the temp dirs.
