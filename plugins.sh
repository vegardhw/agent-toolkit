#!/usr/bin/env bash
# Installs or updates the plugins listed in plugins.tsv. Safe to re-run:
# plugins that are already installed are skipped on install, and only
# installed ones are touched on update. New rows in plugins.tsv are picked up
# on the next run. Tools whose CLI isn't on PATH are skipped.
#
# Usage: ./plugins.sh [install|update] [--all] [--only NAME] [--dry-run]
#   (default)    ask Y/n for each plugin that applies
#   --all        no prompts; "remote" (curl | sh) plugins are still skipped
#   --only NAME  just that plugin (all tools); naming a remote plugin counts as consent
#   --dry-run    print commands instead of running them
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE=install; ALL=0; ONLY=""; DRY=0
while [ $# -gt 0 ]; do
  case "$1" in
    install|update) MODE=$1 ;;
    --all|-y) ALL=1 ;;
    --only) ONLY=${2:?--only needs a plugin name}; shift ;;
    --dry-run) DRY=1 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

DONE=(); SKIPPED=(); PRESENT=(); MANUAL=(); FAILED=()

# ask "<prompt>" <default y|n>: honors --all and non-interactive runs (-> default)
ask() {
  [ "$ALL" -eq 1 ] && return 0
  [ -t 0 ] || return 1
  local reply hint="[Y/n]"; [ "$2" = n ] && hint="[y/N]"
  read -r -p "$1 $hint " reply
  case "${reply:-$2}" in [Yy]*) return 0 ;; *) return 1 ;; esac
}

while IFS=$'\t' read -r name tool kind check install update; do
  case "$name" in ''|'#'*) continue ;; esac
  [ -n "$ONLY" ] && [ "$name" != "$ONLY" ] && continue
  label="$name ($tool)"
  if [ "$tool" != "-" ] && ! command -v "$tool" >/dev/null; then
    SKIPPED+=("$label: $tool not installed"); continue
  fi

  if [ "$kind" = manual ]; then
    [ "$MODE" = install ] && MANUAL+=("$label: $install"); continue
  fi

  bash -c "$check" >/dev/null 2>&1 && installed=1 || installed=0
  if [ "$MODE" = install ]; then
    [ "$installed" -eq 1 ] && { PRESENT+=("$label"); continue; }
    cmd=$install
  else
    [ "$installed" -eq 0 ] && continue
    cmd=$update
  fi
  [ "$cmd" = "-" ] && continue

  if [ "$kind" = remote ]; then
    if [ -n "$ONLY" ]; then :   # explicit name = consent
    elif [ "$ALL" -eq 1 ]; then SKIPPED+=("$label: runs a remote script, use --only $name"); continue
    elif ! ask "$MODE $label? (runs a remote script: $cmd)" n; then SKIPPED+=("$label: declined"); continue; fi
  elif [ -z "$ONLY" ] && ! ask "$MODE $label?" y; then
    SKIPPED+=("$label: declined"); continue
  fi

  echo "+ $cmd"
  if [ "$DRY" -eq 1 ]; then DONE+=("$label (dry run)")
  elif bash -c "$cmd"; then DONE+=("$label")
  else FAILED+=("$label"); fi
done < "$REPO_DIR/plugins.tsv"

echo; echo "== summary ($MODE)"
show() { local t=$1; shift; [ "$#" -gt 0 ] && { echo "$t:"; printf '  %s\n' "$@"; }; return 0; }
show "done" "${DONE[@]}"
show "already installed" "${PRESENT[@]}"
show "skipped" "${SKIPPED[@]}"
show "do by hand" "${MANUAL[@]}"
show "FAILED" "${FAILED[@]}"
[ "${#FAILED[@]}" -eq 0 ]
