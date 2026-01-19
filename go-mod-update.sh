#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Update direct dependencies in go.mod to latest versions
# Usage: go-mod-update.sh [directories...]
#   directories: optional paths to search for go.mod files (defaults to current directory)
#   Finds all go.mod files recursively (excluding vendor/)

# Default to current directory if no args provided
DIRS=("${@:-.}")

update_module() {
    local gomod_dir="$1"

    echo "-> $gomod_dir/go.mod"

    cd "$gomod_dir"

    while true
    do
        notupdated=true;
        for i in $(go list -mod=mod -m -u -f '{{if not (or .Main .Indirect)}}{{.Path}}{{end}}' all | grep -v '^$'); do
            if go list -mod=mod -m -u "$i" | grep -q '\['; then
                echo "go get ${i}@latest";
                go get "${i}@latest";
                notupdated=false;
            fi
        done
        if [ $notupdated = true ]; then
            echo "update completed";
            break;
        fi
    done

    go mod tidy
    go mod vendor

    cd - >/dev/null
}

echo "=== Updating go.mod files (excluding vendor/) ==="

for dir in "${DIRS[@]}"; do
    find "$dir" -path "*/vendor/*" -prune -o -name "go.mod" -type f -print | while read -r gomod; do
        gomod_dir=$(dirname "$gomod")
        update_module "$gomod_dir"
    done
done

echo "✔ Done"
