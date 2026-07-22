# agent-toolkit

Personal library of skills, plugins, and configs for coding agents (pi, Claude
Code, Codex, GitHub Copilot, ...).

## Layout

```
shared/           Tool-agnostic content — write once, symlink/copy into a tool dir
  skills/         Reusable skill definitions (plain instructions, no tool-specific format)
  prompts/        Reusable prompt templates / snippets
  configs/        Generic config fragments (e.g. lint rules, editorconfig)

pi/               Content specific to pi (github.com/earendil-works/pi-coding-agent)
  skills/         SKILL.md packages (docs/skills.md format)
  extensions/     pi extensions
  themes/         pi themes

claude-code/      Content specific to Claude Code
  skills/         Claude Code skills
  commands/       Slash commands

codex/            Content specific to OpenAI Codex CLI
  skills/         Codex-style prompt/skill files

copilot/          Content specific to GitHub Copilot
  instructions/   .github/copilot-instructions.md style files
```

## Conventions

- If a skill works the same everywhere, it lives in `shared/` and the
  tool-specific folder gets a symlink to it, not a copy.
- If a skill needs a tool's own format (e.g. pi's `SKILL.md` + frontmatter,
  Claude Code's skill schema), it lives directly under that tool's folder.
- Each subfolder can grow its own `README.md` once it has enough content to
  need an index; don't pre-build one for an empty folder.

## Using this repo (dotfiles-style)

This repo works like a dotfiles repo, but for coding agents: clone it once
per machine, run the installer, get all your skills everywhere.

```sh
git clone https://github.com/vegardhw/agent-toolkit.git
agent-toolkit/install.sh
```

`install.sh` is idempotent (Linux and macOS) — it symlinks each folder's
contents into the directory the corresponding tool reads from, and can be
re-run anytime after adding new content:

| Repo folder                | Symlinked into            |
|-----------------------------|----------------------------|
| `shared/skills/`            | `~/.agents/skills/`        |
| `pi/skills/`                | `~/.pi/agent/skills/`      |
| `pi/extensions/`             | `~/.pi/agent/extensions/`  |
| `pi/themes/`                | `~/.pi/agent/themes/`      |
| `claude-code/skills/`       | `~/.claude/skills/`        |
| `claude-code/commands/`     | `~/.claude/commands/`      |
| `codex/skills/`             | `~/.codex/skills/`         |

`copilot/instructions/` isn't symlinked — Copilot instructions are per-project
(`.github/copilot-instructions.md`), so copy the relevant file into a
project's `.github/` directory instead.

Plugins/marketplace extensions can't be symlinked (they need an install
command), so track those in [`PLUGINS.md`](PLUGINS.md) as a checklist instead.

### Example

[`shared/skills/conventional-commits/`](shared/skills/conventional-commits/SKILL.md)
is a generic skill written once. `pi/skills/`, `claude-code/skills/`, and
`codex/skills/` each contain a symlink to it — that's the write-once,
link-everywhere pattern to copy for your own skills.
