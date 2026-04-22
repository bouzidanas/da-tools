# Common helpers for da-tools install scripts.
# Source this file: source "$(dirname "$0")/../../lib/common.sh"

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────
if [ -t 1 ]; then
    C_RESET=$'\033[0m'
    C_BOLD=$'\033[1m'
    C_DIM=$'\033[2m'
    C_RED=$'\033[31m'
    C_GREEN=$'\033[32m'
    C_YELLOW=$'\033[33m'
    C_BLUE=$'\033[34m'
    C_CYAN=$'\033[36m'
else
    C_RESET=""; C_BOLD=""; C_DIM=""; C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_CYAN=""
fi

info()    { printf "%b\n" "${C_CYAN}==>${C_RESET} $*"; }
success() { printf "%b\n" "${C_GREEN}✓${C_RESET} $*"; }
warn()    { printf "%b\n" "${C_YELLOW}!${C_RESET} $*"; }
error()   { printf "%b\n" "${C_RED}✗${C_RESET} $*" >&2; }
step()    { printf "\n%b\n" "${C_BOLD}${C_BLUE}▸ $*${C_RESET}"; }

# ── Standard install paths (XDG-compliant) ─────────────────
DA_BIN_DIR="${DA_BIN_DIR:-$HOME/.local/bin}"
DA_DATA_DIR="${DA_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/da-tools}"

# ── PATH check ──────────────────────────────────────────────
ensure_path() {
    if [[ ":$PATH:" != *":$DA_BIN_DIR:"* ]]; then
        warn "$DA_BIN_DIR is not in your PATH."

        local export_line="export PATH=\"$DA_BIN_DIR:\$PATH\""
        local updated=0

        # Update shell-appropriate startup files only.
        # macOS defaults to zsh; Linux/WSL often use bash.
        local rc_candidates=()
        case "${SHELL:-}" in
            */zsh)
                rc_candidates=("$HOME/.zshrc" "$HOME/.zprofile")
                ;;
            */bash)
                rc_candidates=("$HOME/.bashrc")
                if [ "$(uname -s 2>/dev/null || true)" = "Darwin" ]; then
                    rc_candidates+=("$HOME/.bash_profile")
                fi
                ;;
            *)
                rc_candidates=("$HOME/.profile")
                ;;
        esac

        local rc
        for rc in "${rc_candidates[@]}"; do
            if [ -f "$rc" ] || [ "$rc" = "$HOME/.bashrc" ] || [ "$rc" = "$HOME/.zshrc" ] || [ "$rc" = "$HOME/.profile" ]; then
                if ! grep -qF "$export_line" "$rc" 2>/dev/null; then
                    echo "$export_line" >> "$rc"
                    success "Added PATH export to $rc"
                    updated=1
                fi
            fi
        done

        if [ "$updated" -eq 0 ]; then
            info "PATH export already present in startup files."
        fi

        info "Current shell PATH is unchanged until reload."
        info "Run now: export PATH=\"$DA_BIN_DIR:\$PATH\""
    fi
}

is_windows_shell() {
    case "$(uname -s 2>/dev/null || true)" in
        MINGW*|MSYS*|CYGWIN*) return 0 ;;
        *) return 1 ;;
    esac
}

print_platform_notes() {
    if is_windows_shell; then
        info "Windows shell detected (Git Bash/MSYS)."
        info "If VS Code cannot open folders from this shell, run from WSL or open VS Code first."
    fi
}

# ── Installer source detection ─────────────────────────────
# Returns the directory where da-tools source lives. If running via
# `curl | bash`, downloads a tarball to a temp dir and returns that path.
DA_REPO="${DA_REPO:-bouzidanas/da-tools}"
DA_REF="${DA_REF:-main}"

resolve_source_dir() {
    # If invoked from a real file in a checkout, use that.
    if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
        local script_dir
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        # lib/common.sh → repo root is one level up
        if [ -d "$script_dir/../tools" ]; then
            echo "$(cd "$script_dir/.." && pwd)"
            return 0
        fi
        if [ -d "$script_dir/tools" ]; then
            echo "$script_dir"
            return 0
        fi
    fi

    # Otherwise, download tarball.
    local tmp
    tmp="$(mktemp -d)"
    info "Downloading da-tools ($DA_REPO@$DA_REF)..." >&2
    curl -fsSL "https://github.com/$DA_REPO/archive/refs/heads/$DA_REF.tar.gz" \
        | tar -xz -C "$tmp"
    echo "$tmp/da-tools-$DA_REF"
}
