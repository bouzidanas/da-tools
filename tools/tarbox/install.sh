#!/usr/bin/env bash
# Per-tool installer for tarbox.
# Can be invoked directly (from a checkout) or via the main da-tools install.sh.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=../../lib/common.sh
source "$REPO_ROOT/lib/common.sh"

step "Installing tarbox"

# ── Requirements ───────────────────────────────────────────
if ! command -v node >/dev/null 2>&1; then
    error "node is required but was not found on PATH."
    info  "Install Node.js (LTS) from https://nodejs.org/ or via your package manager."
    exit 1
fi
if ! command -v npm >/dev/null 2>&1; then
    error "npm is required but was not found on PATH."
    info  "Install Node.js (which provides npm) from https://nodejs.org/."
    exit 1
fi

mkdir -p "$DA_BIN_DIR"

# ── Stage source files into the data dir ───────────────────
DEST="$DA_DATA_DIR/tarbox"
rm -rf "$DEST"
mkdir -p "$DEST"
cp -r "$SCRIPT_DIR/bin"            "$DEST/bin"
cp    "$SCRIPT_DIR/package.json"   "$DEST/package.json"
if [ -f "$SCRIPT_DIR/package-lock.json" ]; then
    cp "$SCRIPT_DIR/package-lock.json" "$DEST/package-lock.json"
fi
chmod 0755 "$DEST/bin/cli.js"
success "Installed source → $DEST"

# ── Install production dependencies ────────────────────────
info "Installing npm dependencies (production only)..."
if [ -f "$DEST/package-lock.json" ]; then
    (cd "$DEST" && npm ci --omit=dev --no-audit --no-fund --silent)
else
    (cd "$DEST" && npm install --omit=dev --no-audit --no-fund --silent)
fi
success "Installed dependencies → $DEST/node_modules"

# ── Write launcher to bin dir ──────────────────────────────
LAUNCHER="$DA_BIN_DIR/tarbox"
cat > "$LAUNCHER" <<EOF
#!/usr/bin/env bash
# tarbox launcher — installed by da-tools.
exec node "$DEST/bin/cli.js" "\$@"
EOF
chmod 0755 "$LAUNCHER"
success "Installed launcher → $LAUNCHER"

ensure_path
print_platform_notes

FOUND_TARBOX="$(command -v tarbox 2>/dev/null || true)"
if [ "$FOUND_TARBOX" = "$LAUNCHER" ]; then
    success "tarbox is available in this shell: $FOUND_TARBOX"
elif [ -n "$FOUND_TARBOX" ]; then
    warn "A different tarbox is first on PATH: $FOUND_TARBOX"
    info "New install is at: $LAUNCHER"
    info "Use now: export PATH=\"$DA_BIN_DIR:\$PATH\""
else
    warn "tarbox installed, but not yet in the current shell PATH."
    info "Use now: export PATH=\"$DA_BIN_DIR:\$PATH\""
    info "Then verify: command -v tarbox"
fi

success "tarbox installed. Try: ${C_BOLD}tarbox${C_RESET}"
