#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

go get -u $(go list -mod=mod -f 'if not (or .Main .Indirect).Pathend' -m all)
go mod tidy
go mod vendor