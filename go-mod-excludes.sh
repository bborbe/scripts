#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Add standard exclusions and replacements to go.mod
# Usage: go-mod-excludes.sh [directory]
#   directory: optional path to project with go.mod (defaults to current directory)

DIR="${1:-.}"

if [[ ! -f "${DIR}/go.mod" ]]; then
  echo "Error: go.mod not found in ${DIR}" >&2
  exit 1
fi

echo "Adding excludes and replaces for ${DIR}"

cd "${DIR}"

# Exclude problematic versions
go mod edit -exclude cloud.google.com/go@v0.26.0
go mod edit -exclude github.com/go-logr/glogr@v1.0.0
go mod edit -exclude github.com/go-logr/glogr@v1.0.0-rc1
go mod edit -exclude github.com/go-logr/logr@v1.0.0
go mod edit -exclude github.com/go-logr/logr@v1.0.0-rc1
go mod edit -exclude go.yaml.in/yaml/v3@v3.0.3
go mod edit -exclude go.yaml.in/yaml/v3@v3.0.4
go mod edit -exclude golang.org/x/tools@v0.38.0
go mod edit -exclude golang.org/x/tools@v0.39.0
go mod edit -exclude k8s.io/api@v0.34.0
go mod edit -exclude k8s.io/api@v0.34.1
go mod edit -exclude k8s.io/api@v0.34.2
go mod edit -exclude k8s.io/api@v0.34.3
go mod edit -exclude k8s.io/api@v0.35.0
go mod edit -exclude k8s.io/apiextensions-apiserver@v0.34.0
go mod edit -exclude k8s.io/apiextensions-apiserver@v0.34.1
go mod edit -exclude k8s.io/apiextensions-apiserver@v0.34.2
go mod edit -exclude k8s.io/apiextensions-apiserver@v0.34.3
go mod edit -exclude k8s.io/apiextensions-apiserver@v0.35.0
go mod edit -exclude k8s.io/apimachinery@v0.34.0
go mod edit -exclude k8s.io/apimachinery@v0.34.1
go mod edit -exclude k8s.io/apimachinery@v0.34.2
go mod edit -exclude k8s.io/apimachinery@v0.34.3
go mod edit -exclude k8s.io/apimachinery@v0.35.0
go mod edit -exclude k8s.io/client-go@v0.34.0
go mod edit -exclude k8s.io/client-go@v0.34.1
go mod edit -exclude k8s.io/client-go@v0.34.2
go mod edit -exclude k8s.io/client-go@v0.34.3
go mod edit -exclude k8s.io/client-go@v0.35.0
go mod edit -exclude k8s.io/code-generator@v0.34.0
go mod edit -exclude k8s.io/code-generator@v0.34.1
go mod edit -exclude k8s.io/code-generator@v0.34.2
go mod edit -exclude k8s.io/code-generator@v0.34.3
go mod edit -exclude k8s.io/code-generator@v0.35.0
go mod edit -exclude sigs.k8s.io/structured-merge-diff/v6@v6.0.0
go mod edit -exclude sigs.k8s.io/structured-merge-diff/v6@v6.1.0
go mod edit -exclude sigs.k8s.io/structured-merge-diff/v6@v6.2.0
go mod edit -exclude sigs.k8s.io/structured-merge-diff/v6@v6.3.0

# Add replacements
go mod edit -replace k8s.io/kube-openapi=k8s.io/kube-openapi@v0.0.0-20250701173324-9bd5c66d9911

cd - >/dev/null

echo "Done"
