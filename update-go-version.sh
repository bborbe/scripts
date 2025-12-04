#!/usr/bin/env bash
set -euo pipefail

#
# Portable sed -i compatible with macOS and Linux
#
sed_i() {
    if sed --version >/dev/null 2>&1; then
        # GNU sed (Linux)
        sed -i "$@"
    else
        # BSD sed (macOS) → requires empty suffix
        sed -i '' "$@"
    fi
}

echo "Detecting latest Go version..."
LATEST=$(curl -s https://go.dev/VERSION?m=text | head -n1 | sed 's/go//')
if [[ ! "$LATEST" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Error: Failed to fetch valid Go version (got: '$LATEST')" >&2
    exit 1
fi
echo "Latest stable Go: $LATEST"

echo
echo "=== Updating go.mod files (excluding vendor/) ==="
find . -path "*/vendor/*" -prune -o -name "go.mod" -type f -print | while read -r gomod; do
    echo "-> $gomod"

    # Update `go` directive
    sed_i -E "s/^go [0-9]+\.[0-9]+(\.[0-9]+)?/go $LATEST/" "$gomod"

    # Update toolchain directive (Go 1.22+)
    sed_i -E "s/^toolchain go[0-9]+\.[0-9]+(\.[0-9]+)?/toolchain go$LATEST/" "$gomod"
done

echo
echo "=== Updating Dockerfiles (excluding vendor/) ==="
find . -path "*/vendor/*" -prune -o -name "Dockerfile" -type f -print | while read -r df; do
    echo "-> $df"
    sed_i -E "s|(FROM golang:)[0-9]+\.[0-9]+(\.[0-9]+)?|\1$LATEST|g" "$df"
done

echo
echo "=== Updating GitHub workflows ==="
if [ -d .github/workflows ]; then
    find .github/workflows -name "*.yml" -type f | while read -r wf; do
        echo "-> $wf"
        sed_i -E "s/go-version: ['\"][0-9]+\.[0-9]+(\.[0-9]+)?['\"]/go-version: '$LATEST'/" "$wf"
    done
else
    echo "No .github/workflows directory found."
fi

echo
echo "✔ Done! All services updated to Go $LATEST"
