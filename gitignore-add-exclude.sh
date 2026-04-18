#!/usr/bin/env bash
set -euo pipefail

# Add a line to .gitignore in every dark-factory project under ~/Documents/workspaces.
# Usage: gitignore-add-exclude.sh <entry>
#   gitignore-add-exclude.sh '/.dark-factory.log'

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <entry>" >&2
  exit 1
fi

ENTRY="$1"
WORKSPACES="${HOME}/Documents/workspaces"
added=0
skipped=0
no_gitignore=0

while IFS= read -r yaml; do
  dir=$(dirname "$yaml")
  gitignore="$dir/.gitignore"

  if [[ ! -f "$gitignore" ]]; then
    echo "SKIP (no .gitignore): ${dir#"$WORKSPACES"/}"
    no_gitignore=$((no_gitignore + 1))
    continue
  fi

  if grep -qF "$ENTRY" "$gitignore"; then
    skipped=$((skipped + 1))
    continue
  fi

  echo "$ENTRY" >> "$gitignore"
  echo "added: ${dir#"$WORKSPACES"/}"
  added=$((added + 1))

done < <(find "$WORKSPACES" -maxdepth 3 -type f -name ".dark-factory.yaml" -not -path "*/vendor/*")

echo ""
echo "Done: $added added, $skipped already present, $no_gitignore no .gitignore"
