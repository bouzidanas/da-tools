#!/usr/bin/env bash
# Per-tool uninstaller for tarbox.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=../../lib/common.sh
source "$REPO_ROOT/lib/common.sh"

step "Uninstalling tarbox"

rm -f  "$DA_BIN_DIR/tarbox"   && success "Removed $DA_BIN_DIR/tarbox"   || true
rm -rf "$DA_DATA_DIR/tarbox"  && success "Removed $DA_DATA_DIR/tarbox"  || true

success "tarbox uninstalled."
