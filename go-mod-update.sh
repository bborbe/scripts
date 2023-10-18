#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# old version
# go get -u $(go list -mod=mod -f '{{if not (or .Main .Indirect)}}{{.Path}}{{end}}' -m all)

while true
do
    notupdated=true;
    for i in $(go list -mod=mod -m -u all | grep ']$'| awk '{print $1}'); do
        go get -u ${i};
        notupdated=false;
    done
    if [ $notupdated ]; then
        echo "update completed";
        break;
    fi
done

go mod tidy
go mod vendor