# tarbox

Quick interactive CLI for creating start/end tarballs of repo folders.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/bouzidanas/da-tools/master/install.sh | bash -s -- tarbox
```

## Usage

Run inside a directory that contains one or more repo folders:

```bash
tarbox
```

You'll be walked through three prompts:

1. **Mode** — `Start` or `End`.
2. **Modifier** *(End mode only)* — optional suffix appended to the filename. Press <kbd>Enter</kbd> to skip.
3. **Repo folder** — pick which subdirectory of the current folder to archive.

The resulting tarball is written to:

| Mode  | Output path                                     |
|-------|-------------------------------------------------|
| Start | `./<repo>-start.tar`                            |
| End   | `~/<repo>-end-model.tar` (or `…-model-<modifier>.tar`) |

The underlying command is just `tar -cf <path> ./<repo>`; the script prints it before running.

Press <kbd>Ctrl</kbd>+<kbd>C</kbd> at any prompt to exit cleanly.

## Requirements

- Node.js (LTS) and `npm` on `PATH` — used at install time to fetch the small set of dependencies (`@inquirer/prompts`, `chalk`) and at runtime to execute the CLI.
- `tar` available on `PATH`.

## How it's installed

- Source + `node_modules` go to `~/.local/share/da-tools/tarbox/`
- A small bash launcher is placed at `~/.local/bin/tarbox` that `exec`s `node` on the installed `cli.js`

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/bouzidanas/da-tools/master/install.sh | bash -s -- --uninstall tarbox
```
