#!/usr/bin/env bash
# Per-tool installer for devc.
# Can be invoked directly (from a checkout) or via the main da-tools install.sh.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=../../lib/common.sh
source "$REPO_ROOT/lib/common.sh"

step "Installing devc"

mkdir -p "$DA_BIN_DIR"
mkdir -p "$DA_DATA_DIR/devc"

# Install executable
install -m 0755 "$SCRIPT_DIR/devc" "$DA_BIN_DIR/devc"
success "Installed binary → $DA_BIN_DIR/devc"

# Install template
TEMPLATE_DEST="$DA_DATA_DIR/devc/devcontainer-default"
rm -rf "$TEMPLATE_DEST"
cp -r "$SCRIPT_DIR/templates/devcontainer-default" "$TEMPLATE_DEST"
success "Installed template → $TEMPLATE_DEST"

ensure_path
print_platform_notes

FOUND_DEVC="$(command -v devc 2>/dev/null || true)"
if [ "$FOUND_DEVC" = "$DA_BIN_DIR/devc" ]; then
	success "devc is available in this shell: $FOUND_DEVC"
elif [ -n "$FOUND_DEVC" ]; then
	warn "A different devc is first on PATH: $FOUND_DEVC"
	info "New install is at: $DA_BIN_DIR/devc"
	info "Use now: export PATH=\"$DA_BIN_DIR:\$PATH\""
else
	warn "devc installed, but not yet in the current shell PATH."
	info "Use now: export PATH=\"$DA_BIN_DIR:\$PATH\""
	info "Then verify: command -v devc"
fi

success "devc installed. Try: ${C_BOLD}devc --help${C_RESET}"
