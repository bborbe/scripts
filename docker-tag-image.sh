#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

SOURCE="$1"
TARGET="$2"

echo "tag ${SOURCE} with ${TARGET}"
docker tag $(docker images ${SOURCE} -q) ${TARGET}
