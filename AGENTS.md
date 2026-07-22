# AGENTS.md

This repo is a curated personal library of agent skills/plugins/configs, not
an application. There is no build/test/lint step.

## Working in this repo

- Read `README.md` first for the folder layout.
- New tool-agnostic content → `shared/`. Tool-specific format required
  (frontmatter, schema, naming convention) → that tool's own folder.
- Don't duplicate content between `shared/` and a tool folder — symlink
  instead (see README "Conventions").
- Don't invent new top-level categories or deep folder trees speculatively;
  add a folder only when there's real content for it.
- Each skill/config should be self-contained in its own subfolder (e.g.
  `pi/skills/foo/SKILL.md`) so it can be symlinked independently.
