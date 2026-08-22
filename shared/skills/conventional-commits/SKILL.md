---
name: conventional-commits
description: "Writes git commit messages following the Conventional Commits spec (type(scope): summary). Use whenever the user asks to commit changes or write a commit message."
---

# Conventional Commits

## Format

```
<type>(<optional scope>): <summary, imperative mood, no trailing period>

<optional body: what and why, not how>

<optional footer: BREAKING CHANGE:, Refs:, Closes:>
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `build`, `ci`, `perf`, `style`.

## Steps

1. Run `git diff --staged` (or `git diff` if nothing staged) to see the real change.
2. Pick the smallest accurate type. Prefer `fix`/`feat` over `chore` when the
   change affects behavior.
3. Summary ≤ 72 chars, imperative ("add", not "added"/"adds").
4. Only add a body if the diff isn't self-explanatory from the summary.
5. Run `git commit -m "..."` (or `-m` + `-m` for a body).

## Example

```
fix(auth): reject expired refresh tokens

Previously an expired token silently fell back to anonymous access.
```
