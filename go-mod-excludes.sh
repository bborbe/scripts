#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Drop standard exclusions and add replacements/upgrades to go.mod
# Usage: go-mod-excludes.sh [directories...]
#   directories: optional paths to search for go.mod files (defaults to current directory)
#   Finds all go.mod files recursively (excluding vendor/)

# Default to current directory if no args provided
DIRS=("${@:-.}")

apply_excludes() {
    local gomod_dir="$1"

    echo "-> $gomod_dir/go.mod"

    cd "$gomod_dir"

    # Drop previously-excluded versions
    go mod edit -dropexclude cloud.google.com/go@v0.26.0
    go mod edit -dropexclude github.com/go-logr/glogr@v1.0.0
    go mod edit -dropexclude github.com/go-logr/glogr@v1.0.0-rc1
    go mod edit -dropexclude github.com/go-logr/logr@v1.0.0
    go mod edit -dropexclude github.com/go-logr/logr@v1.0.0-rc1
    go mod edit -dropexclude go.yaml.in/yaml/v3@v3.0.3
    go mod edit -dropexclude go.yaml.in/yaml/v3@v3.0.4
    go mod edit -dropexclude golang.org/x/tools@v0.38.0
    go mod edit -dropexclude golang.org/x/tools@v0.39.0
    go mod edit -dropexclude k8s.io/api@v0.34.0
    go mod edit -dropexclude k8s.io/api@v0.34.1
    go mod edit -dropexclude k8s.io/api@v0.34.2
    go mod edit -dropexclude k8s.io/api@v0.34.3
    go mod edit -dropexclude k8s.io/api@v0.35.0
    go mod edit -dropexclude k8s.io/apiextensions-apiserver@v0.34.0
    go mod edit -dropexclude k8s.io/apiextensions-apiserver@v0.34.1
    go mod edit -dropexclude k8s.io/apiextensions-apiserver@v0.34.2
    go mod edit -dropexclude k8s.io/apiextensions-apiserver@v0.34.3
    go mod edit -dropexclude k8s.io/apiextensions-apiserver@v0.35.0
    go mod edit -dropexclude k8s.io/apimachinery@v0.34.0
    go mod edit -dropexclude k8s.io/apimachinery@v0.34.1
    go mod edit -dropexclude k8s.io/apimachinery@v0.34.2
    go mod edit -dropexclude k8s.io/apimachinery@v0.34.3
    go mod edit -dropexclude k8s.io/apimachinery@v0.35.0
    go mod edit -dropexclude k8s.io/client-go@v0.34.0
    go mod edit -dropexclude k8s.io/client-go@v0.34.1
    go mod edit -dropexclude k8s.io/client-go@v0.34.2
    go mod edit -dropexclude k8s.io/client-go@v0.34.3
    go mod edit -dropexclude k8s.io/client-go@v0.35.0
    go mod edit -dropexclude k8s.io/code-generator@v0.34.0
    go mod edit -dropexclude k8s.io/code-generator@v0.34.1
    go mod edit -dropexclude k8s.io/code-generator@v0.34.2
    go mod edit -dropexclude k8s.io/code-generator@v0.34.3
    go mod edit -dropexclude k8s.io/code-generator@v0.35.0
    go mod edit -dropexclude sigs.k8s.io/structured-merge-diff/v6@v6.0.0
    go mod edit -dropexclude sigs.k8s.io/structured-merge-diff/v6@v6.1.0
    go mod edit -dropexclude sigs.k8s.io/structured-merge-diff/v6@v6.2.0
    go mod edit -dropexclude sigs.k8s.io/structured-merge-diff/v6@v6.3.0
    go mod edit -dropexclude github.com/go-git/go-git/v5@v5.17.0

    # Drop replacements
    go mod edit -dropreplace k8s.io/kube-openapi
    go mod edit -dropreplace github.com/charmbracelet/x/cellbuf

    # Add replacements
    go mod edit -replace github.com/anthropics/anthropic-sdk-go=github.com/anthropics/anthropic-sdk-go@v1.26.0
    go mod edit -replace github.com/denis-tingaikin/go-header=github.com/denis-tingaikin/go-header@v0.5.0
    go mod edit -replace github.com/diskfs/go-diskfs=github.com/diskfs/go-diskfs@v1.7.0
    go mod edit -replace github.com/nunnatsa/ginkgolinter/types=github.com/nunnatsa/ginkgolinter@v0.19.1
    go mod edit -replace github.com/opencontainers/runtime-spec=github.com/opencontainers/runtime-spec@v1.2.0

    # Upgrade specific modules
    go get -u \
        github.com/go-git/go-git/v5 \
        github.com/moby/buildkit \
        github.com/modelcontextprotocol/go-sdk \
        google.golang.org/grpc || true

    cd - >/dev/null
}

echo "=== Updating go.mod files (excluding vendor/) ==="

for dir in "${DIRS[@]}"; do
    find "$dir" -path "*/vendor/*" -prune -o -name "go.mod" -type f -print | while read -r gomod; do
        gomod_dir=$(dirname "$gomod")
        apply_excludes "$gomod_dir"
    done
done

echo "✔ Done"
