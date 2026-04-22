#!/usr/bin/env bash
# Per-tool uninstaller for devc.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=../../lib/common.sh
source "$REPO_ROOT/lib/common.sh"

step "Uninstalling devc"

rm -f "$DA_BIN_DIR/devc"            && success "Removed $DA_BIN_DIR/devc"        || true
rm -rf "$DA_DATA_DIR/devc"          && success "Removed $DA_DATA_DIR/devc"       || true

success "devc uninstalled."
