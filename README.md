# da-tools

A small collection of developer-experience tools.

## Quick install

Install everything with one command:

```bash
curl -fsSL https://raw.githubusercontent.com/bouzidanas/da-tools/main/install.sh | bash
```

Install only specific tools:

```bash
curl -fsSL https://raw.githubusercontent.com/bouzidanas/da-tools/main/install.sh | bash -s -- devc
```

List available tools:

```bash
curl -fsSL https://raw.githubusercontent.com/bouzidanas/da-tools/main/install.sh | bash -s -- --list
```

Uninstall:

```bash
curl -fsSL https://raw.githubusercontent.com/bouzidanas/da-tools/main/install.sh | bash -s -- --uninstall
# or a single tool:
curl -fsSL https://raw.githubusercontent.com/bouzidanas/da-tools/main/install.sh | bash -s -- --uninstall devc
```

> Executables go to `~/.local/bin`. Data files (templates, etc.) go to `~/.local/share/da-tools/`. The installer adds `~/.local/bin` to your `PATH` if needed.

### macOS

Run in Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/bouzidanas/da-tools/main/install.sh | bash -s -- devc
```

If `devc` is not found immediately after install, run:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then open a new terminal tab/window.

### Windows

Recommended: run install in **WSL** (Ubuntu) and use VS Code Remote - WSL.

```bash
curl -fsSL https://raw.githubusercontent.com/bouzidanas/da-tools/main/install.sh | bash -s -- devc
```

Alternative: use Git Bash. If `devc` is not found right away, run:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Install from a local checkout

```bash
git clone https://github.com/bouzidanas/da-tools.git
cd da-tools
./install.sh              # all tools
./install.sh devc         # one tool
```

## Tools

| Tool | Description |
|------|-------------|
| [`devc`](tools/devc/README.md) | Launch any folder as a VS Code dev container with a sensible default config (Python, Node, Chrome, Playwright, Streamlit, etc.) |

More tools coming.

## Requirements

- `bash`, `curl`, `tar`
- For `devc`: VS Code with the **Dev Containers** extension, plus Docker (Docker Desktop on Windows/Mac, or native Docker on Linux/WSL2).

## Repository layout

```
da-tools/
├── install.sh              # main installer (one-command setup)
├── lib/
│   └── common.sh           # shared helpers (colors, paths, PATH check)
└── tools/
    └── <tool>/
        ├── install.sh      # per-tool installer
        ├── uninstall.sh    # per-tool uninstaller
        └── ...             # tool files
```

Each tool is self-contained — its `install.sh` can be invoked directly or via the top-level installer.

## License

[MIT](LICENSE)
