#!/usr/bin/env bash
# Re-vendors the skills listed in sources.tsv into shared/skills/ from their
# upstream repos (latest of each ref), then re-runs link.sh. Never commits:
# review `git diff`, then commit what you want to keep.
# Flags: --dry-run   print what would be fetched, change nothing
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY=0
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    *) echo "unknown flag: $a" >&2; exit 2 ;;
  esac
done

sync_skills() {
  local name repo path ref tmp
  while read -r name repo path ref; do
    case "$name" in ''|'#'*) continue ;; esac
    echo "== skill $name ($repo@$ref)"
    [ "$DRY" -eq 1 ] && continue
    tmp="$(mktemp -d)"
    # init+fetch (not clone) so a commit SHA works as ref, not just a branch/tag
    git -C "$tmp" init -q
    git -C "$tmp" fetch -q --depth 1 "https://github.com/$repo.git" "$ref"
    git -C "$tmp" checkout -q FETCH_HEAD
    [ -f "$tmp/$path/SKILL.md" ] || { echo "no SKILL.md at $path, skipping" >&2; rm -rf "$tmp"; continue; }
    rm -rf "$REPO_DIR/shared/skills/$name"
    cp -a "$tmp/$path" "$REPO_DIR/shared/skills/$name"
    # some repos keep the license at the root instead of in the skill folder
    compgen -G "$REPO_DIR/shared/skills/$name/LICENSE*" >/dev/null ||
      cp "$tmp"/LICENSE* "$REPO_DIR/shared/skills/$name/" 2>/dev/null || true
    rm -rf "$tmp"
  done < "$REPO_DIR/sources.tsv"
  git -C "$REPO_DIR" --no-pager diff --stat -- shared/skills
  git -C "$REPO_DIR" status --short -- shared/skills | grep '^??' || true
}

sync_skills
if [ "$DRY" -eq 0 ]; then "$REPO_DIR/link.sh"; else echo "+ ./link.sh"; fi
echo "done. review with 'git diff' and commit what you want to keep."
