#!/usr/bin/env bash
# Idempotent installer: symlinks this repo's skills/extensions/themes/commands
# into the real config directories each agent tool reads from.
# Safe to re-run anytime (Linux and macOS) — existing correct symlinks are
# left alone. Real (non-symlink) files/dirs already there are never touched
# silently: they're listed as conflicts and you're asked once whether to
# back them up (as *.bak) before installing.
#
# Flags: -y / --yes   auto-confirm backup of conflicts (for automation)
set -euo pipefail
shopt -s nullglob

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTO_YES=0
[ "${1:-}" = "-y" ] || [ "${1:-}" = "--yes" ] && AUTO_YES=1

MAPPINGS=(
  "shared/skills:$HOME/.agents/skills"
  "pi/skills:$HOME/.pi/agent/skills"
  "pi/extensions:$HOME/.pi/agent/extensions"
  "pi/themes:$HOME/.pi/agent/themes"
  "claude-code/skills:$HOME/.claude/skills"
  "claude-code/commands:$HOME/.claude/commands"
  "codex/skills:$HOME/.codex/skills"
)

CONFLICTS=()

# Pass 1: find conflicts (real file/dir already at the target, not our symlink).
for mapping in "${MAPPINGS[@]}"; do
  src="$REPO_DIR/${mapping%%:*}"; dst="${mapping#*:}"
  [ -d "$src" ] || continue
  for item in "$src"/*; do
    name="$(basename "$item")"
    [ "$name" = ".gitkeep" ] && continue  # placeholder for empty dirs, not real content
    target="$dst/$name"
    # a conflict is real content sitting where our symlink would go:
    # exists AND is not already a symlink (our own links are never conflicts)
    [ -e "$target" ] && [ ! -L "$target" ] && CONFLICTS+=("$target")
  done
done

BACKUP=$AUTO_YES
if [ "${#CONFLICTS[@]}" -gt 0 ]; then
  echo "Found existing local content that would be replaced by a symlink:"
  printf '  %s\n' "${CONFLICTS[@]}"
  if [ "$AUTO_YES" -eq 1 ]; then
    echo "-y given: backing up all of the above to *.bak"
  else
    read -r -p "Back these up (as *.bak) and install symlinks? [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]] && BACKUP=1 || BACKUP=0
  fi
fi

# Pass 2: link everything, honoring the conflict decision.
for mapping in "${MAPPINGS[@]}"; do
  src="$REPO_DIR/${mapping%%:*}"; dst="${mapping#*:}"
  [ -d "$src" ] || continue
  mkdir -p "$dst"
  for item in "$src"/*; do
    name="$(basename "$item")"
    [ "$name" = ".gitkeep" ] && continue
    target="$dst/$name"
    if [ -L "$target" ]; then
      # already a symlink (ours or stale) — always safe to overwrite
      ln -sfn "$item" "$target"
      echo "linked $target -> $item"
    elif [ -e "$target" ]; then
      # real content: only touch it if the conflict pass got a yes
      if [ "$BACKUP" -eq 1 ]; then
        backup="$target.bak"
        # avoid clobbering a previous .bak from an earlier run
        [ -e "$backup" ] && backup="$target.bak.$(date +%s)"
        mv "$target" "$backup"
        ln -s "$item" "$target"
        echo "backed up to $backup, linked $target -> $item"
      else
        echo "skipped $target (local content kept, not backed up)"
      fi
    else
      # nothing there yet — plain link
      ln -s "$item" "$target"
      echo "linked $target -> $item"
    fi
  done
done

echo "done. see PLUGINS.md for plugins that need manual install."
