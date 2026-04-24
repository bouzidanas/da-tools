#!/usr/bin/env bash
set -euo pipefail

OS_NAME="$(uname -s 2>/dev/null || true)"

is_windows_shell() {
    case "$OS_NAME" in
        MINGW*|MSYS*|CYGWIN*) return 0 ;;
        *) return 1 ;;
    esac
}

if is_windows_shell; then
    echo "ERROR: Native Windows shells are not supported by this setup script." >&2
    echo "Run this workflow in WSL or inside the Linux dev container instead." >&2
    exit 1
fi

echo "========================================"
echo "  Dev Container Setup"
echo "========================================"

# ── User choices (set by devc, with fallbacks) ─────────────
DEVC_AI_CLIS="${DEVC_AI_CLIS:-claude}"
DEVC_TRACE_URL="${DEVC_TRACE_URL:-https://projects-uploaded-files.s3.us-east-2.amazonaws.com/production/item_response_files/_ef924544-553f-48cf-a580-082777d34242_26c4a446-e585-43e0-86c9-830f649a30de.zip}"

want_cli() {
    case ",${DEVC_AI_CLIS}," in
        *",$1,"*) return 0 ;;
        *) return 1 ;;
    esac
}
echo "  AI CLIs to install: ${DEVC_AI_CLIS:-<none>}"
echo "  Trace Extractor URL: ${DEVC_TRACE_URL}"

# ── System tools (tmux, git) ────────────────────────────────
echo ""
echo "[1/9] Installing system tools (tmux, git)..."
if [ "$OS_NAME" = "Darwin" ]; then
    if ! command -v brew >/dev/null 2>&1; then
        echo "ERROR: Homebrew is required on macOS for tmux installation." >&2
        echo "Install Homebrew first: https://brew.sh/" >&2
        exit 1
    fi

    brew install tmux
    if ! command -v git >/dev/null 2>&1; then
        brew install git
    fi
else
    sudo apt-get update && sudo apt-get install -y --no-install-recommends \
        tmux \
        git \
        && sudo rm -rf /var/lib/apt/lists/*
fi

# Configure tmux: mouse support + large scrollback
echo -e "set-option -g history-limit 100000\nset -g mouse on" > ~/.tmux.conf

# ── uv (Python package manager) ─────────────────────────────
echo ""
echo "[2/9] Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
# Add uv to PATH for this script
export PATH="$HOME/.local/bin:$PATH"

# ── AI CLIs (user-selected) ─────────────────────────────────
echo ""
echo "[3/9] Installing AI CLIs (${DEVC_AI_CLIS:-none})..."
if want_cli claude; then
    echo "  • Claude Code"
    curl -fsSL https://claude.ai/install.sh | bash
    export PATH="$HOME/.claude/bin:$PATH"
fi
if want_cli gemini; then
    echo "  • Gemini CLI"
    npm install -g @google/gemini-cli
fi
if want_cli codex; then
    echo "  • Codex CLI"
    npm install -g @openai/codex
fi
if [ -z "${DEVC_AI_CLIS}" ]; then
    echo "  (no AI CLIs selected)"
fi

# ── Python packages ──────────────────────────────────────────
echo ""
echo "[4/9] Installing Python packages..."
pip install --upgrade pip

pip install \
    streamlit \
    pytest \
    pytest-cov \
    pytest-asyncio \
    httpx \
    requests \
    aiohttp \
    beautifulsoup4 \
    lxml \
    selenium \
    webdriver-manager \
    playwright \
    fastapi \
    uvicorn \
    flask \
    python-dotenv \
    pydantic \
    openai \
    anthropic \
    langchain \
    langchain-community \
    langchain-openai

# ── Playwright browsers ─────────────────────────────────────
echo ""
echo "[5/9] Installing Playwright browsers..."
playwright install chromium
playwright install-deps chromium 2>/dev/null || true

# ── ChromeDriver for Selenium ───────────────────────────────
echo ""
echo "[6/9] Verifying Chrome & ChromeDriver..."
if command -v google-chrome >/dev/null 2>&1; then
    google-chrome --version || true
elif command -v chromium >/dev/null 2>&1; then
    chromium --version || true
else
    echo "  Chrome binary not preinstalled on this architecture; Playwright Chromium was installed in step [5/9]."
fi
# webdriver-manager handles chromedriver automatically at runtime

# ── Node.js global tools ────────────────────────────────────
echo ""
echo "[7/9] Installing Node.js global packages..."
npm install -g \
    vite \
    create-vite \
    typescript \
    ts-node \
    nodemon \
    live-server

# ── Claude Code settings ────────────────────────────────────
echo ""
echo "[8/9] Configuring Claude Code settings..."
if want_cli claude; then
    mkdir -p ~/.claude
    python - << 'PY'
import json
from pathlib import Path

settings_path = Path.home() / ".claude" / "settings.json"
data = {}
if settings_path.exists():
    try:
        data = json.loads(settings_path.read_text())
    except json.JSONDecodeError:
        data = {}

data["showThinkingSummaries"] = True
settings_path.write_text(json.dumps(data, indent=4) + "\n")
print(f"  Updated {settings_path} with showThinkingSummaries=true")
PY
else
    echo "  Skipped (Claude Code not selected)."
fi

# ── Trace Extractor ─────────────────────────────────────────
echo ""
echo "[9/9] Installing Trace Extractor..."
TRACE_ZIP_URL="$DEVC_TRACE_URL"
TRACE_ZIP="/tmp/trace-extractor.zip"

if [ ! -d "$HOME/cli-trace-extractor" ]; then
    curl -fsSL -o "$TRACE_ZIP" "$TRACE_ZIP_URL"
    unzip -o "$TRACE_ZIP" -d "$HOME/"
    rm -f "$TRACE_ZIP"
    echo "  Extracted cli-trace-extractor to ~/cli-trace-extractor"
else
    echo "  ~/cli-trace-extractor already exists, skipping download."
fi

cd "$HOME/cli-trace-extractor"
uv sync

# Generate mitmproxy certificates (auto-exit after startup)
echo "  Generating mitmproxy certificates..."
if command -v timeout >/dev/null 2>&1; then
    timeout 3 uv run mitmdump || true
else
    uv run mitmdump &
    MITMDUMP_PID=$!
    sleep 3
    kill "$MITMDUMP_PID" 2>/dev/null || true
fi

# Install cert to system trusted store
if [ -f "$HOME/.mitmproxy/mitmproxy-ca-cert.pem" ]; then
    if [ "$OS_NAME" = "Darwin" ]; then
        sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$HOME/.mitmproxy/mitmproxy-ca-cert.pem"
        echo "  Installed mitmproxy certificate to macOS system keychain."
    else
        sudo cp "$HOME/.mitmproxy/mitmproxy-ca-cert.pem" /usr/local/share/ca-certificates/mitmproxy.crt
        sudo update-ca-certificates
        echo "  Installed mitmproxy certificate to Linux trust store."
    fi
else
    echo "  WARNING: mitmproxy cert not found — run 'uv run mitmproxy' manually to generate."
fi

cd -

CHROME_VERSION="N/A"
if command -v google-chrome >/dev/null 2>&1; then
    CHROME_VERSION="$(google-chrome --version 2>/dev/null || echo 'N/A')"
elif command -v chromium >/dev/null 2>&1; then
    CHROME_VERSION="$(chromium --version 2>/dev/null || echo 'N/A')"
fi

echo ""
echo "========================================"
echo "  Setup complete!"
echo "  - Python: $(python --version)"
echo "  - Node:   $(node --version)"
echo "  - npm:    $(npm --version)"
echo "  - tmux:   $(tmux -V)"
echo "  - uv:     $(uv --version 2>/dev/null || echo 'N/A')"
want_cli claude && echo "  - claude: $(claude --version 2>/dev/null || echo 'N/A')"
want_cli gemini && echo "  - gemini: $(gemini --version 2>/dev/null || echo 'N/A')"
want_cli codex  && echo "  - codex:  $(codex --version 2>/dev/null || echo 'N/A')"
echo "  - git:    $(git --version)"
echo "  - Chrome: $CHROME_VERSION"
echo "========================================"
