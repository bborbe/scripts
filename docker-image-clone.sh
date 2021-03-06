#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

SOURCE="$1"
TARGET="$2"

echo "clone ${SOURCE} to ${TARGET}"

docker pull ${SOURCE} || true
sleep 2
docker tag `docker images ${SOURCE} -q` ${TARGET}
docker push ${TARGET}
