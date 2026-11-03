#!/usr/bin/env bash
# Pulls the latest versions of everything this repo tracks, then re-runs install.sh.
#   skills   re-vendors the skills listed in sources.tsv into shared/skills/ (never commits)
#   plugins  updates marketplace plugins in the tools that are installed
#   bins     re-runs upstream installers for cship / no-mistakes (runs remote code, opt-in)
# Flags: --skills --plugins --bins  pick steps (default: skills + plugins)
#        --dry-run                  print what would run, change nothing
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEPS=(); DRY=0
for a in "$@"; do
  case "$a" in
    --skills) STEPS+=(skills) ;; --plugins) STEPS+=(plugins) ;; --bins) STEPS+=(bins) ;;
    --dry-run) DRY=1 ;;
    *) echo "unknown flag: $a" >&2; exit 2 ;;
  esac
done
[ "${#STEPS[@]}" -eq 0 ] && STEPS=(skills plugins)
has() { printf '%s\n' "${STEPS[@]}" | grep -qx "$1"; }
run() { echo "+ $*"; [ "$DRY" -eq 1 ] || "$@"; }

update_skills() {
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

update_plugins() {
  # keep in sync with PLUGINS.md
  if command -v pi >/dev/null; then run pi update --extensions; else echo "skip pi (not installed)"; fi
  if command -v claude >/dev/null; then
    run claude plugin marketplace update
    local p installed
    installed="$(claude plugin list 2>/dev/null || true)"
    for p in ponytail@ponytail azure@azure-skills azure-kusto-graph-skills@azure-skills; do
      grep -q "$p" <<<"$installed" && run claude plugin update "$p" || echo "skip $p (not installed)"
    done
  else echo "skip claude (not installed)"; fi
  # shortcut: codex/copilot update commands unverified (CLIs not on this machine), add when checked
  echo "skip codex, copilot (update commands not wired up yet)"
}

update_bins() {
  command -v cship >/dev/null && run bash -c 'curl -fsSL https://cship.dev/install.sh | bash' || echo "skip cship (not installed)"
  command -v no-mistakes >/dev/null && run sh -c 'curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | sh' || echo "skip no-mistakes (not installed)"
}

has skills && update_skills
has plugins && update_plugins
has bins && update_bins
if [ "$DRY" -eq 0 ]; then "$REPO_DIR/install.sh"; else echo "+ ./install.sh"; fi
echo "done. review with 'git diff' and commit what you want to keep."
