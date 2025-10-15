#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

while true
do
    notupdated=true;
    for i in $(go list -mod=mod -m all | awk '{print $1}'); do
        go get -u ${i};
        notupdated=false;
    done
    if [ $notupdated = true ]; then
        echo "update completed";
        break;
    fi
done

go mod tidy
go mod vendor