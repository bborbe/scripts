#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

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
