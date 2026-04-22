#!/usr/bin/env bash
set -euo pipefail

echo "========================================"
echo "  Dev Container Setup"
echo "========================================"

# ── System tools (tmux, git) ────────────────────────────────
echo ""
echo "[1/9] Installing system tools (tmux, git)..."
sudo apt-get update && sudo apt-get install -y --no-install-recommends \
    tmux \
    git \
    && sudo rm -rf /var/lib/apt/lists/*

# Configure tmux: mouse support + large scrollback
echo -e "set-option -g history-limit 100000\nset -g mouse on" > ~/.tmux.conf

# ── uv (Python package manager) ─────────────────────────────
echo ""
echo "[2/9] Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
# Add uv to PATH for this script
export PATH="$HOME/.local/bin:$PATH"

# ── Claude Code CLI ─────────────────────────────────────────
echo ""
echo "[3/9] Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash
# Add claude to PATH for this script
export PATH="$HOME/.claude/bin:$PATH"

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
google-chrome --version || true
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
echo "[8/9] Creating Claude Code settings..."
mkdir -p ~/.claude
if [ ! -f ~/.claude/settings.json ]; then
    cat > ~/.claude/settings.json << 'CLAUDEEOF'
{
    "showThinkingSummaries": true
}
CLAUDEEOF
    echo "  Created ~/.claude/settings.json"
else
    echo "  ~/.claude/settings.json already exists, skipping."
fi

# ── Trace Extractor ─────────────────────────────────────────
echo ""
echo "[9/9] Installing Trace Extractor..."
TRACE_ZIP_URL="https://projects-uploaded-files.s3.us-east-2.amazonaws.com/production/item_response_files/_ef924544-553f-48cf-a580-082777d34242_26c4a446-e585-43e0-86c9-830f649a30de.zip"
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
timeout 3 uv run mitmdump || true

# Install cert to system trusted store
if [ -f "$HOME/.mitmproxy/mitmproxy-ca-cert.pem" ]; then
    sudo cp "$HOME/.mitmproxy/mitmproxy-ca-cert.pem" /usr/local/share/ca-certificates/mitmproxy.crt
    sudo update-ca-certificates
    echo "  Installed mitmproxy certificate to system trust store."
else
    echo "  WARNING: mitmproxy cert not found — run 'uv run mitmproxy' manually to generate."
fi

cd -

echo ""
echo "========================================"
echo "  Setup complete!"
echo "  - Python: $(python --version)"
echo "  - Node:   $(node --version)"
echo "  - npm:    $(npm --version)"
echo "  - tmux:   $(tmux -V)"
echo "  - uv:     $(uv --version 2>/dev/null || echo 'N/A')"
echo "  - claude: $(claude --version 2>/dev/null || echo 'N/A')"
echo "  - git:    $(git --version)"
echo "  - Chrome: $(google-chrome --version 2>/dev/null || echo 'N/A')"
echo "========================================"
