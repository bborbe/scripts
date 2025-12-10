#!/bin/bash

set -euo pipefail

# Check for required argument
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 \"<changelog entry text>\""
    echo "Example: $0 \"fix bug in validation\""
    exit 1
fi

changelog_entry="$1"
changelog_file="CHANGELOG.md"

# Check if CHANGELOG.md exists
if [[ ! -f "$changelog_file" ]]; then
    echo "Error: CHANGELOG.md not found in current directory"
    exit 1
fi

# Find the first version line (starts with ## v)
current_version=$(grep -m1 '^## v' "$changelog_file" | sed 's/^## //' || echo "")

if [[ -z "$current_version" ]]; then
    echo "Error: No version found in $changelog_file"
    exit 1
fi

echo "Current version: $current_version"

# Increment patch version (e.g., v1.2.3 -> v1.2.4)
version_no_v="${current_version#v}"
major="${version_no_v%%.*}"
rest="${version_no_v#*.}"
minor="${rest%%.*}"
patch="${rest#*.}"
patch=$((patch + 1))
new_version="v${major}.${minor}.${patch}"

echo "New version: $new_version"

# Create temporary file with new content
temp_file=$(mktemp)

# Read file until the first version line, then insert new entry
found_first_version=false
while IFS= read -r line; do
    if [[ "$line" =~ ^##[[:space:]]+v && "$found_first_version" == false ]]; then
        # Insert new version entry before the first existing version
        echo "## $new_version" >> "$temp_file"
        echo "" >> "$temp_file"
        echo "- $changelog_entry" >> "$temp_file"
        echo "" >> "$temp_file"
        found_first_version=true
    fi
    echo "$line" >> "$temp_file"
done < "$changelog_file"

# Replace original file
mv "$temp_file" "$changelog_file"
echo "Updated $changelog_file successfully"
