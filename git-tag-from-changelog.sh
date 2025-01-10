#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

if ! git diff-index --quiet HEAD --; then
  echo "There are uncommitted changes => commit first"
  exit 1
fi

# Check if the current HEAD has an exact match with any tag
if ! git describe --tags --exact-match HEAD > /dev/null 2>&1; then
  # Extract the first version line from CHANGELOG.md
  new_tag=$(grep -E '^## v[0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md | head -n 1 | sed 's/^## //')

  # Tag the current HEAD with the extracted version, if a version was found
  if [ -n "$new_tag" ]; then
    git tag -a $new_tag -m "add version $new_tag"
    echo "Tagged HEAD with: $new_tag"
  else
    echo "No valid version found in CHANGELOG.md"
  fi
else
  echo "HEAD is already tagged."
fi
