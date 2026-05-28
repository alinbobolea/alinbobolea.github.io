#!/usr/bin/env bash
# sync-docs.sh
# Copies built Sphinx HTML from each project into static/docs/ so Hugo can
# serve them as plain static files at /docs/<project>/.
#
# Run from anywhere; the script resolves the site repo root relative to itself:
#   ./scripts/sync-docs.sh
#
# Requirements: the Sphinx docs must already be built in each project.
#   htcie:  cd /home/nick/projects/htcie && sphinx-build docs/source docs/build/html
#   pyGOTM: cd /home/nick/projects/pygotm && conda run -n pygotm sphinx-build -b html docs docs/build

set -euo pipefail

SITE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STATIC_DOCS="$SITE_ROOT/static/docs"

declare -A SOURCES=(
  [htcie]="/home/nick/projects/htcie/docs/build/html"
  [pygotm]="/home/nick/projects/pygotm/docs/build"
)

for project in "${!SOURCES[@]}"; do
  src="${SOURCES[$project]}"
  dst="$STATIC_DOCS/$project"

  if [[ ! -d "$src" ]]; then
    echo "SKIP $project — source not found: $src"
    continue
  fi

  echo "Syncing $project ..."
  mkdir -p "$dst"
  rsync -a --delete \
    --exclude='.doctrees' \
    --exclude='.buildinfo' \
    --exclude='.buildinfo.bak' \
    --exclude='.cache' \
    "$src/" "$dst/"
  echo "  -> $dst"
done

echo "Done. Review changes with: git status static/docs/"
