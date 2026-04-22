# devc

Launch any folder as a [VS Code Dev Container](https://code.visualstudio.com/docs/devcontainers/containers) using a sensible default configuration.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/bouzidanas/da-tools/main/install.sh | bash -s -- devc
```

## Usage

```bash
devc                    # current directory
devc ~/some/project     # any directory
devc --help
```

What it does:

1. Copies the default `.devcontainer/` template into the target directory
2. Opens the directory in VS Code
3. You then run **F1 → Dev Containers: Reopen in Container**

If `.devcontainer/` already exists in the target, you'll be asked whether to overwrite it.

## What's in the default container

- **OS**: Ubuntu 24.04
- **Languages**: Python 3.12, Node.js LTS, C/C++ toolchain
- **Browser automation**: Google Chrome, Playwright (with Chromium), Selenium, webdriver-manager
- **Python**: streamlit, pytest, fastapi, uvicorn, flask, requests/httpx/aiohttp, beautifulsoup4, openai, anthropic, langchain, etc.
- **Node**: vite, create-vite, typescript, ts-node, nodemon, live-server
- **Other**: tmux, git, uv, Claude Code CLI
- **Forwarded ports**: 3000, 3001, 4173, 4174, 5173, 5174, 8000, 8080, 8501, 8502
- **Resource limits**: 8GB memory, 4 CPUs, 1024 PID limit
- **VS Code extensions** auto-installed inside the container: Python, C++, ESLint, Prettier, Tailwind CSS, Playwright, Streamlit, Live Server

## Customizing the template

The template lives at `~/.local/share/da-tools/devc/devcontainer-default/`. Edit those files and every future `devc <dir>` invocation will use the updated template.

To override the template path for a single invocation:

```bash
DEVC_TEMPLATE=/path/to/my-template devc .
```

## Requirements

- VS Code with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension
- Docker (Docker Desktop on Windows/macOS, or Docker Engine on Linux/WSL2)
- The `code` command available on PATH (VS Code → *Shell Command: Install 'code' command in PATH*)

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/bouzidanas/da-tools/main/install.sh | bash -s -- --uninstall devc
```
