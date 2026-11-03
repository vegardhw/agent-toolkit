# Plugins

What the toolkit installs beyond plain skills, and which agents each one
supports. Plugins can't be symlinked, so [`plugins.sh`](plugins.sh) installs
them from [`plugins.tsv`](plugins.tsv). That file is the source of truth for
the actual commands; this page is the human-readable overview.

```sh
./plugins.sh                 # install: asks Y/n per missing plugin
./plugins.sh --all           # install everything without prompts (not curl | sh ones)
./plugins.sh update          # update what's installed
./plugins.sh --only cship    # one plugin (also how you opt in to curl | sh ones)
./plugins.sh --dry-run       # show commands, change nothing
```

Re-running is safe: installed plugins are skipped, and rows added to
`plugins.tsv` later are picked up on the next run.

## Overview

| Plugin | What it is | pi | Claude Code | Codex | Copilot |
|---|---|:-:|:-:|:-:|:-:|
| [ponytail](https://github.com/DietrichGebert/ponytail) | Lazy-senior-dev mode: smallest change that solves the task | auto | auto | by hand | by hand |
| [azure-skills](https://github.com/microsoft/azure-skills) | Azure MCP integration and Kusto graph skills | n/a | auto | by hand | by hand |
| [cship](https://cship.dev) | Starship-compatible statusline binary | n/a | auto* | n/a | n/a |
| [no-mistakes](https://github.com/kunchenguid/no-mistakes) | Gates `git push` behind an AI validation pipeline | n/a | auto* | n/a | n/a |

**auto** = `plugins.sh` installs and updates it. **by hand** = `plugins.sh`
prints the instructions when that CLI is present, you run them (Codex and
Copilot commands aren't verified or scriptable yet). **n/a** = not supported
upstream. **\*** = pipes a remote script into a shell, so it always asks first
and is never covered by `--all`.

## Notes per plugin

### ponytail

Coding-style mode for agents. Installed per tool from the
`DietrichGebert/ponytail` repo.

### azure-skills

A marketplace with two plugins: `azure` (Azure MCP integration for cloud
resources and deployments) and `azure-kusto-graph-skills` (Kusto graph
analysis, IRQL security hunting, graph visualisation for Azure Data
Explorer). Codex has no non-interactive install: add the marketplace, then
browse and install through `/plugins` inside Codex.

### cship

Rust statusline for Claude Code. Its config (`claude-code/statusline/cship.toml`)
is symlinked to `~/.config/cship.toml` by `link.sh`. The upstream installer
also wires `statusLine` into `~/.claude/settings.json`. If you installed it
with `cargo install cship` instead, add this yourself:

```json
{ "statusLine": { "type": "command", "command": "cship" } }
```

Verify with `cship explain` or `cship --version`.

### no-mistakes

Go CLI that runs review, tests, docs and lint in a disposable worktree before
a push goes through. It installs its own binary to `~/.no-mistakes/bin/`
(symlinked into `~/.local/bin/`) and a `/no-mistakes` skill to
`~/.claude/skills/no-mistakes/`.

## Vendored skills

`frontend-design` and `swiftui-expert-skill` are copied into `shared/skills/`
and symlinked per tool, so they need no install step. Their upstream repo,
path and ref are in [`sources.tsv`](sources.tsv); `./sync-skills.sh`
re-fetches them.
