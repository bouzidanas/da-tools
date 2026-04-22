#!/usr/bin/env bash
# da-tools installer
#
# Install everything (default):
#   curl -fsSL https://raw.githubusercontent.com/bouzidanas/da-tools/main/install.sh | bash
#
# Install specific tools:
#   curl -fsSL https://raw.githubusercontent.com/bouzidanas/da-tools/main/install.sh | bash -s -- devc
#
# List available tools:
#   curl -fsSL https://raw.githubusercontent.com/bouzidanas/da-tools/main/install.sh | bash -s -- --list

set -euo pipefail

# ── Bootstrap: source common.sh from local checkout or download ────
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ] \
   && [ -f "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh" ]; then
    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # shellcheck source=lib/common.sh
    source "$REPO_ROOT/lib/common.sh"
else
    # Running via `curl | bash` — fetch the repo to a temp dir.
    DA_REPO="${DA_REPO:-bouzidanas/da-tools}"
    DA_REF="${DA_REF:-main}"
    TMP="$(mktemp -d)"
    trap 'rm -rf "$TMP"' EXIT
    echo "==> Downloading da-tools ($DA_REPO@$DA_REF)..."
    curl -fsSL "https://github.com/$DA_REPO/archive/refs/heads/$DA_REF.tar.gz" \
        | tar -xz -C "$TMP"
    REPO_ROOT="$TMP/da-tools-$DA_REF"
    # shellcheck source=lib/common.sh
    source "$REPO_ROOT/lib/common.sh"
fi

usage() {
    cat <<EOF
${C_BOLD}da-tools installer${C_RESET}

Usage:
  install.sh [TOOL...]      Install specific tools (or all if none given)
  install.sh --list         List available tools
  install.sh --uninstall    Uninstall everything (or named tools)
  install.sh -h | --help    Show this help

Examples:
  install.sh                 # install all tools
  install.sh devc            # install only devc
  install.sh --uninstall devc

Environment:
  DA_BIN_DIR   Where executables are installed (default: ~/.local/bin)
  DA_DATA_DIR  Where data files live (default: ~/.local/share/da-tools)
EOF
}

list_tools() {
    info "Available tools:"
    for d in "$REPO_ROOT/tools"/*/; do
        [ -d "$d" ] || continue
        printf "  • %s\n" "$(basename "$d")"
    done
}

run_tool_action() {
    local action="$1"; shift
    local tool="$1"
    local script="$REPO_ROOT/tools/$tool/$action.sh"
    if [ ! -f "$script" ]; then
        error "Unknown tool or missing $action script: $tool"
        return 1
    fi
    bash "$script"
}

# ── Parse args ─────────────────────────────────────────────
ACTION="install"
TOOLS=()

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)      usage; exit 0 ;;
        --list)         list_tools; exit 0 ;;
        --uninstall)    ACTION="uninstall" ;;
        -*)             error "Unknown flag: $1"; usage; exit 1 ;;
        *)              TOOLS+=("$1") ;;
    esac
    shift
done

# Default to all tools if none specified
if [ ${#TOOLS[@]} -eq 0 ]; then
    for d in "$REPO_ROOT/tools"/*/; do
        [ -d "$d" ] || continue
        TOOLS+=("$(basename "$d")")
    done
fi

if [ ${#TOOLS[@]} -eq 0 ]; then
    error "No tools found in $REPO_ROOT/tools"
    exit 1
fi

# Capitalize first letter of ACTION (portable across bash versions)
ACTION_TITLE="$(printf '%s' "${ACTION:0:1}" | tr '[:lower:]' '[:upper:]')${ACTION:1}ing"

step "$ACTION_TITLE: ${TOOLS[*]}"

for tool in "${TOOLS[@]}"; do
    run_tool_action "$ACTION" "$tool"
done

step "Done."
