# Plugins Checklist

Plugins/extensions usually need a marketplace install or manual step, so they
aren't symlinked by `install.sh`. Track them here so a new machine can be
brought up to parity by working the checklist.

## ponytail

### pi

`pi install git:github.com/DietrichGebert/ponytail`

### Claude Code

`/plugin marketplace add DietrichGebert/ponytail`
`/plugin install ponytail@ponytail`

### Codex

`codex plugin marketplace add DietrichGebert/ponytail`

### GitHub Copilot

`copilot plugin install ponytail@ponytail`

## azure-skills ([microsoft/azure-skills](https://github.com/microsoft/azure-skills))

Marketplace with two plugins: `azure` (Azure MCP integration for cloud
resource management/deployments) and `azure-kusto-graph-skills` (Kusto graph
analysis, IRQL security hunting, graph viz for Azure Data Explorer).

### Claude Code

`/plugin marketplace add microsoft/azure-skills`
`/plugin install azure@azure-skills`
`/plugin install azure-kusto-graph-skills@azure-skills`

## no-mistakes ([kunchenguid/no-mistakes](https://github.com/kunchenguid/no-mistakes))

Go CLI that gates `git push` behind an AI-driven validation pipeline (review,
test, docs, lint) run in a disposable worktree; installs its own binary and
Claude Code skill, so it can't be symlinked from this repo. Claude Code only
today — no pi/Codex/Copilot support upstream.

### Claude Code (and any shell)

`curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | sh`

Installs the `no-mistakes` binary to `~/.no-mistakes/bin/` (symlinked into
`~/.local/bin/`) and its `/no-mistakes` skill to `~/.claude/skills/no-mistakes/`.
